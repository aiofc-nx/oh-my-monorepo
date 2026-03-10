"""
Spec Kit 扩展管理器

负责 Spec Kit 扩展的安装、移除与管理。
扩展是模块化包，可为 spec-kit 增加命令与功能，
同时避免核心框架变得臃肿。
"""

import json
import hashlib
import tempfile
import zipfile
import shutil
from pathlib import Path
from typing import Optional, Dict, List, Any
from datetime import datetime, timezone
import re

import yaml
from packaging import version as pkg_version
from packaging.specifiers import SpecifierSet, InvalidSpecifier


class ExtensionError(Exception):
    """扩展相关错误的基类异常。"""
    pass


class ValidationError(ExtensionError):
    """当扩展清单校验失败时抛出。"""
    pass


class CompatibilityError(ExtensionError):
    """当扩展与当前环境不兼容时抛出。"""
    pass


class ExtensionManifest:
    """表示并校验扩展清单（extension.yml）。"""

    SCHEMA_VERSION = "1.0"
    REQUIRED_FIELDS = ["schema_version", "extension", "requires", "provides"]

    def __init__(self, manifest_path: Path):
        """加载并校验扩展清单。

        参数:
            manifest_path: extension.yml 文件路径

        异常:
            ValidationError: 当清单无效时
        """
        self.path = manifest_path
        self.data = self._load_yaml(manifest_path)
        self._validate()

    def _load_yaml(self, path: Path) -> dict:
        """安全加载 YAML 文件。"""
        try:
            with open(path, 'r') as f:
                return yaml.safe_load(f) or {}
        except yaml.YAMLError as e:
            raise ValidationError(f"Invalid YAML in {path}: {e}")
        except FileNotFoundError:
            raise ValidationError(f"Manifest not found: {path}")

    def _validate(self):
        """校验清单结构与必填字段。"""
        # 检查必需的顶层字段
        for field in self.REQUIRED_FIELDS:
            if field not in self.data:
                raise ValidationError(f"Missing required field: {field}")

        # 校验 schema 版本
        if self.data["schema_version"] != self.SCHEMA_VERSION:
            raise ValidationError(
                f"Unsupported schema version: {self.data['schema_version']} "
                f"(expected {self.SCHEMA_VERSION})"
            )

        # 校验扩展元数据
        ext = self.data["extension"]
        for field in ["id", "name", "version", "description"]:
            if field not in ext:
                raise ValidationError(f"Missing extension.{field}")

        # 校验扩展 ID 格式
        if not re.match(r'^[a-z0-9-]+$', ext["id"]):
            raise ValidationError(
                f"Invalid extension ID '{ext['id']}': "
                "must be lowercase alphanumeric with hyphens only"
            )

        # 校验语义化版本
        try:
            pkg_version.Version(ext["version"])
        except pkg_version.InvalidVersion:
            raise ValidationError(f"Invalid version: {ext['version']}")

        # 校验 requires 部分
        requires = self.data["requires"]
        if "speckit_version" not in requires:
            raise ValidationError("Missing requires.speckit_version")

        # 校验 provides 部分
        provides = self.data["provides"]
        if "commands" not in provides or not provides["commands"]:
            raise ValidationError("Extension must provide at least one command")

        # 校验命令列表
        for cmd in provides["commands"]:
            if "name" not in cmd or "file" not in cmd:
                raise ValidationError("Command missing 'name' or 'file'")

            # 校验命令名格式
            if not re.match(r'^speckit\.[a-z0-9-]+\.[a-z0-9-]+$', cmd["name"]):
                raise ValidationError(
                    f"Invalid command name '{cmd['name']}': "
                    "must follow pattern 'speckit.{extension}.{command}'"
                )

    @property
    def id(self) -> str:
        """获取扩展 ID。"""
        return self.data["extension"]["id"]

    @property
    def name(self) -> str:
        """获取扩展名称。"""
        return self.data["extension"]["name"]

    @property
    def version(self) -> str:
        """获取扩展版本。"""
        return self.data["extension"]["version"]

    @property
    def description(self) -> str:
        """获取扩展描述。"""
        return self.data["extension"]["description"]

    @property
    def requires_speckit_version(self) -> str:
        """获取所需 spec-kit 版本范围。"""
        return self.data["requires"]["speckit_version"]

    @property
    def commands(self) -> List[Dict[str, Any]]:
        """获取扩展提供的命令列表。"""
        return self.data["provides"]["commands"]

    @property
    def hooks(self) -> Dict[str, Any]:
        """获取 hook 定义。"""
        return self.data.get("hooks", {})

    def get_hash(self) -> str:
        """计算清单文件的 SHA256 哈希值。"""
        with open(self.path, 'rb') as f:
            return f"sha256:{hashlib.sha256(f.read()).hexdigest()}"


class ExtensionRegistry:
    """管理已安装扩展的注册表。"""

    REGISTRY_FILE = ".registry"
    SCHEMA_VERSION = "1.0"

    def __init__(self, extensions_dir: Path):
        """初始化注册表。

        参数:
            extensions_dir: `.specify/extensions/` 目录路径
        """
        self.extensions_dir = extensions_dir
        self.registry_path = extensions_dir / self.REGISTRY_FILE
        self.data = self._load()

    def _load(self) -> dict:
        """从磁盘加载注册表。"""
        if not self.registry_path.exists():
            return {
                "schema_version": self.SCHEMA_VERSION,
                "extensions": {}
            }

        try:
            with open(self.registry_path, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, FileNotFoundError):
            # 注册表损坏或缺失，从空状态开始
            return {
                "schema_version": self.SCHEMA_VERSION,
                "extensions": {}
            }

    def _save(self):
        """将注册表保存到磁盘。"""
        self.extensions_dir.mkdir(parents=True, exist_ok=True)
        with open(self.registry_path, 'w') as f:
            json.dump(self.data, f, indent=2)

    def add(self, extension_id: str, metadata: dict):
        """将扩展添加到注册表。

        参数:
            extension_id: 扩展 ID
            metadata: 扩展元数据（版本、来源等）
        """
        self.data["extensions"][extension_id] = {
            **metadata,
            "installed_at": datetime.now(timezone.utc).isoformat()
        }
        self._save()

    def remove(self, extension_id: str):
        """从注册表移除扩展。

        参数:
            extension_id: 扩展 ID
        """
        if extension_id in self.data["extensions"]:
            del self.data["extensions"][extension_id]
            self._save()

    def get(self, extension_id: str) -> Optional[dict]:
        """从注册表获取扩展元数据。

        参数:
            extension_id: 扩展 ID

        返回:
            扩展元数据；若未找到则为 None
        """
        return self.data["extensions"].get(extension_id)

    def list(self) -> Dict[str, dict]:
        """获取所有已安装扩展。

        返回:
            `extension_id -> metadata` 的字典
        """
        return self.data["extensions"]

    def is_installed(self, extension_id: str) -> bool:
        """检查扩展是否已安装。

        参数:
            extension_id: 扩展 ID

        返回:
            若扩展已安装则为 True
        """
        return extension_id in self.data["extensions"]


class ExtensionManager:
    """管理扩展生命周期：安装、移除、更新。"""

    def __init__(self, project_root: Path):
        """初始化扩展管理器。

        参数:
            project_root: 项目根目录路径
        """
        self.project_root = project_root
        self.extensions_dir = project_root / ".specify" / "extensions"
        self.registry = ExtensionRegistry(self.extensions_dir)

    def check_compatibility(
        self,
        manifest: ExtensionManifest,
        speckit_version: str
    ) -> bool:
        """检查扩展是否与当前 spec-kit 版本兼容。

        参数:
            manifest: 扩展清单
            speckit_version: 当前 spec-kit 版本

        返回:
            兼容时返回 True

        异常:
            CompatibilityError: 当扩展不兼容时
        """
        required = manifest.requires_speckit_version
        current = pkg_version.Version(speckit_version)

        # 解析版本约束（例如 ">=0.1.0,<2.0.0"）
        try:
            specifier = SpecifierSet(required)
            if current not in specifier:
                raise CompatibilityError(
                    f"Extension requires spec-kit {required}, "
                    f"but {speckit_version} is installed.\n"
                    f"Upgrade spec-kit with: uv tool install specify-cli --force"
                )
        except InvalidSpecifier:
            raise CompatibilityError(f"Invalid version specifier: {required}")

        return True

    def install_from_directory(
        self,
        source_dir: Path,
        speckit_version: str,
        register_commands: bool = True
    ) -> ExtensionManifest:
        """从本地目录安装扩展。

        参数:
            source_dir: 扩展目录路径
            speckit_version: 当前 spec-kit 版本
            register_commands: 若为 True，则向 AI 代理注册命令

        返回:
            已安装扩展的清单对象

        异常:
            ValidationError: 当清单无效时
            CompatibilityError: 当扩展不兼容时
        """
        # 加载并校验清单
        manifest_path = source_dir / "extension.yml"
        manifest = ExtensionManifest(manifest_path)

        # 检查兼容性
        self.check_compatibility(manifest, speckit_version)

        # 检查是否已安装
        if self.registry.is_installed(manifest.id):
            raise ExtensionError(
                f"Extension '{manifest.id}' is already installed. "
                f"Use 'specify extension remove {manifest.id}' first."
            )

        # 安装扩展
        dest_dir = self.extensions_dir / manifest.id
        if dest_dir.exists():
            shutil.rmtree(dest_dir)

        shutil.copytree(source_dir, dest_dir)

        # 向 AI 代理注册命令
        registered_commands = {}
        if register_commands:
            registrar = CommandRegistrar()
            # 为所有已检测到的代理注册
            registered_commands = registrar.register_commands_for_all_agents(
                manifest, dest_dir, self.project_root
            )

        # 注册 hooks
        hook_executor = HookExecutor(self.project_root)
        hook_executor.register_hooks(manifest)

        # 更新注册表
        self.registry.add(manifest.id, {
            "version": manifest.version,
            "source": "local",
            "manifest_hash": manifest.get_hash(),
            "enabled": True,
            "registered_commands": registered_commands
        })

        return manifest

    def install_from_zip(
        self,
        zip_path: Path,
        speckit_version: str
    ) -> ExtensionManifest:
        """从 ZIP 文件安装扩展。

        参数:
            zip_path: 扩展 ZIP 文件路径
            speckit_version: 当前 spec-kit 版本

        返回:
            已安装扩展的清单对象

        异常:
            ValidationError: 当清单无效时
            CompatibilityError: 当扩展不兼容时
        """
        with tempfile.TemporaryDirectory() as tmpdir:
            temp_path = Path(tmpdir)

            # 安全解压 ZIP（防止 Zip Slip 攻击）
            with zipfile.ZipFile(zip_path, 'r') as zf:
                # 在解压前先校验所有路径
                temp_path_resolved = temp_path.resolve()
                for member in zf.namelist():
                    member_path = (temp_path / member).resolve()
                    # 使用 is_relative_to 做安全路径包含检查
                    try:
                        member_path.relative_to(temp_path_resolved)
                    except ValueError:
                        raise ValidationError(
                            f"Unsafe path in ZIP archive: {member} (potential path traversal)"
                        )
                # 仅在所有路径都校验通过后再解压
                zf.extractall(temp_path)

            # 查找扩展目录（可能存在嵌套）
            extension_dir = temp_path
            manifest_path = extension_dir / "extension.yml"

            # 检查清单是否位于子目录
            if not manifest_path.exists():
                subdirs = [d for d in temp_path.iterdir() if d.is_dir()]
                if len(subdirs) == 1:
                    extension_dir = subdirs[0]
                    manifest_path = extension_dir / "extension.yml"

            if not manifest_path.exists():
                raise ValidationError("No extension.yml found in ZIP file")

            # 从解压目录安装
            return self.install_from_directory(extension_dir, speckit_version)

    def remove(self, extension_id: str, keep_config: bool = False) -> bool:
        """移除已安装扩展。

        参数:
            extension_id: 扩展 ID
            keep_config: 若为 True，保留配置文件（不删除扩展目录）

        返回:
            若成功移除扩展则返回 True
        """
        if not self.registry.is_installed(extension_id):
            return False

        # 删除前先获取已注册命令
        metadata = self.registry.get(extension_id)
        registered_commands = metadata.get("registered_commands", {})

        extension_dir = self.extensions_dir / extension_id

        # 从所有 AI 代理中注销命令
        if registered_commands:
            registrar = CommandRegistrar()
            for agent_name, cmd_names in registered_commands.items():
                if agent_name not in registrar.AGENT_CONFIGS:
                    continue

                agent_config = registrar.AGENT_CONFIGS[agent_name]
                commands_dir = self.project_root / agent_config["dir"]

                for cmd_name in cmd_names:
                    cmd_file = commands_dir / f"{cmd_name}{agent_config['extension']}"
                    if cmd_file.exists():
                        cmd_file.unlink()

                    # 同时删除 Copilot 对应的 .prompt.md 文件
                    if agent_name == "copilot":
                        prompt_file = self.project_root / ".github" / "prompts" / f"{cmd_name}.prompt.md"
                        if prompt_file.exists():
                            prompt_file.unlink()

        if keep_config:
            # 保留配置文件，仅移除非配置文件
            if extension_dir.exists():
                for child in extension_dir.iterdir():
                    # 保留顶层 *-config.yml 与 *-config.local.yml 文件
                    if child.is_file() and (
                        child.name.endswith("-config.yml") or
                        child.name.endswith("-config.local.yml")
                    ):
                        continue
                    if child.is_dir():
                        shutil.rmtree(child)
                    else:
                        child.unlink()
        else:
            # 删除前备份配置文件
            if extension_dir.exists():
                # 每个扩展使用独立子目录，避免名称累积
                # （例如反复删除/安装后出现 jira-jira-config.yml）
                backup_dir = self.extensions_dir / ".backup" / extension_id
                backup_dir.mkdir(parents=True, exist_ok=True)

                # 同时备份主配置与本地覆盖配置文件
                config_files = list(extension_dir.glob("*-config.yml")) + list(
                    extension_dir.glob("*-config.local.yml")
                )
                for config_file in config_files:
                    backup_path = backup_dir / config_file.name
                    shutil.copy2(config_file, backup_path)

            # 删除扩展目录
            if extension_dir.exists():
                shutil.rmtree(extension_dir)

        # 注销 hooks
        hook_executor = HookExecutor(self.project_root)
        hook_executor.unregister_hooks(extension_id)

        # 更新注册表
        self.registry.remove(extension_id)

        return True

    def list_installed(self) -> List[Dict[str, Any]]:
        """列出所有已安装扩展及其元数据。

        返回:
            扩展元数据字典列表
        """
        result = []

        for ext_id, metadata in self.registry.list().items():
            ext_dir = self.extensions_dir / ext_id
            manifest_path = ext_dir / "extension.yml"

            try:
                manifest = ExtensionManifest(manifest_path)
                result.append({
                    "id": ext_id,
                    "name": manifest.name,
                    "version": metadata["version"],
                    "description": manifest.description,
                    "enabled": metadata.get("enabled", True),
                    "installed_at": metadata.get("installed_at"),
                    "command_count": len(manifest.commands),
                    "hook_count": len(manifest.hooks)
                })
            except ValidationError:
                # 扩展已损坏
                result.append({
                    "id": ext_id,
                    "name": ext_id,
                    "version": metadata.get("version", "unknown"),
                    "description": "⚠️ Corrupted extension",
                    "enabled": False,
                    "installed_at": metadata.get("installed_at"),
                    "command_count": 0,
                    "hook_count": 0
                })

        return result

    def get_extension(self, extension_id: str) -> Optional[ExtensionManifest]:
        """获取已安装扩展的清单。

        参数:
            extension_id: 扩展 ID

        返回:
            扩展清单；若未安装则返回 None
        """
        if not self.registry.is_installed(extension_id):
            return None

        ext_dir = self.extensions_dir / extension_id
        manifest_path = ext_dir / "extension.yml"

        try:
            return ExtensionManifest(manifest_path)
        except ValidationError:
            return None


def version_satisfies(current: str, required: str) -> bool:
    """检查当前版本是否满足所需版本约束。

    参数:
        current: 当前版本（例如 `"0.1.5"`）
        required: 所需版本约束（例如 `">=0.1.0,<2.0.0"`）

    返回:
        若满足约束则返回 True
    """
    try:
        current_ver = pkg_version.Version(current)
        specifier = SpecifierSet(required)
        return current_ver in specifier
    except (pkg_version.InvalidVersion, InvalidSpecifier):
        return False


class CommandRegistrar:
    """处理扩展命令在 AI 代理中的注册。"""

    # 代理配置：目录、格式与参数占位符
    AGENT_CONFIGS = {
        "claude": {
            "dir": ".claude/commands",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "gemini": {
            "dir": ".gemini/commands",
            "format": "toml",
            "args": "{{args}}",
            "extension": ".toml"
        },
        "copilot": {
            "dir": ".github/agents",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".agent.md"
        },
        "cursor": {
            "dir": ".cursor/commands",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "qwen": {
            "dir": ".qwen/commands",
            "format": "toml",
            "args": "{{args}}",
            "extension": ".toml"
        },
        "opencode": {
            "dir": ".opencode/command",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "windsurf": {
            "dir": ".windsurf/workflows",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "kilocode": {
            "dir": ".kilocode/rules",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "auggie": {
            "dir": ".augment/rules",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "roo": {
            "dir": ".roo/rules",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "codebuddy": {
            "dir": ".codebuddy/commands",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "qodercli": {
            "dir": ".qoder/commands",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "kiro-cli": {
            "dir": ".kiro/prompts",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "amp": {
            "dir": ".agents/commands",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "shai": {
            "dir": ".shai/commands",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        },
        "bob": {
            "dir": ".bob/commands",
            "format": "markdown",
            "args": "$ARGUMENTS",
            "extension": ".md"
        }
    }

    @staticmethod
    def parse_frontmatter(content: str) -> tuple[dict, str]:
        """从 Markdown 内容中解析 YAML frontmatter。

        参数:
            content: 带 YAML frontmatter 的 Markdown 内容

        返回:
            `(frontmatter_dict, body_content)` 元组
        """
        if not content.startswith("---"):
            return {}, content

        # 查找第二个 ---
        end_marker = content.find("---", 3)
        if end_marker == -1:
            return {}, content

        frontmatter_str = content[3:end_marker].strip()
        body = content[end_marker + 3:].strip()

        try:
            frontmatter = yaml.safe_load(frontmatter_str) or {}
        except yaml.YAMLError:
            frontmatter = {}

        return frontmatter, body

    @staticmethod
    def render_frontmatter(fm: dict) -> str:
        """将 frontmatter 字典渲染为 YAML。

        参数:
            fm: frontmatter 字典

        返回:
            包含分隔符的 YAML 格式 frontmatter
        """
        if not fm:
            return ""

        yaml_str = yaml.dump(fm, default_flow_style=False, sort_keys=False)
        return f"---\n{yaml_str}---\n"

    def _adjust_script_paths(self, frontmatter: dict) -> dict:
        """将脚本路径从扩展相对路径调整为仓库相对路径。

        参数:
            frontmatter: frontmatter 字典

        返回:
            调整路径后的 frontmatter
        """
        if "scripts" in frontmatter:
            for key in frontmatter["scripts"]:
                script_path = frontmatter["scripts"][key]
                if script_path.startswith("../../scripts/"):
                    frontmatter["scripts"][key] = f".specify/scripts/{script_path[14:]}"
        return frontmatter

    def _render_markdown_command(
        self,
        frontmatter: dict,
        body: str,
        ext_id: str
    ) -> str:
        """以 Markdown 格式渲染命令。

        参数:
            frontmatter: 命令 frontmatter
            body: 命令主体内容
            ext_id: 扩展 ID

        返回:
            格式化后的 Markdown 命令文件内容
        """
        context_note = f"\n<!-- Extension: {ext_id} -->\n<!-- Config: .specify/extensions/{ext_id}/ -->\n"
        return self.render_frontmatter(frontmatter) + "\n" + context_note + body

    def _render_toml_command(
        self,
        frontmatter: dict,
        body: str,
        ext_id: str
    ) -> str:
        """以 TOML 格式渲染命令。

        参数:
            frontmatter: 命令 frontmatter
            body: 命令主体内容
            ext_id: 扩展 ID

        返回:
            格式化后的 TOML 命令文件内容
        """
        # 面向 Gemini/Qwen 的 TOML 格式
        toml_lines = []

        # 若存在 description 则添加
        if "description" in frontmatter:
            # 转义 description 中的引号
            desc = frontmatter["description"].replace('"', '\\"')
            toml_lines.append(f'description = "{desc}"')
            toml_lines.append("")

        # 以注释形式加入扩展上下文
        toml_lines.append(f"# Extension: {ext_id}")
        toml_lines.append(f"# Config: .specify/extensions/{ext_id}/")
        toml_lines.append("")

        # 添加 prompt 内容
        toml_lines.append('prompt = """')
        toml_lines.append(body)
        toml_lines.append('"""')

        return "\n".join(toml_lines)

    def _convert_argument_placeholder(self, content: str, from_placeholder: str, to_placeholder: str) -> str:
        """转换参数占位符格式。

        参数:
            content: 命令内容
            from_placeholder: 源占位符（例如 `"$ARGUMENTS"`）
            to_placeholder: 目标占位符（例如 `"{{args}}"`）

        返回:
            占位符已转换后的内容
        """
        return content.replace(from_placeholder, to_placeholder)

    def register_commands_for_agent(
        self,
        agent_name: str,
        manifest: ExtensionManifest,
        extension_dir: Path,
        project_root: Path
    ) -> List[str]:
        """为指定代理注册扩展命令。

        参数:
            agent_name: 代理名称（claude、gemini、copilot 等）
            manifest: 扩展清单
            extension_dir: 扩展目录路径
            project_root: 项目根路径

        返回:
            已注册命令名称列表

        异常:
            ExtensionError: 当代理不受支持时
        """
        if agent_name not in self.AGENT_CONFIGS:
            raise ExtensionError(f"Unsupported agent: {agent_name}")

        agent_config = self.AGENT_CONFIGS[agent_name]
        commands_dir = project_root / agent_config["dir"]
        commands_dir.mkdir(parents=True, exist_ok=True)

        registered = []

        for cmd_info in manifest.commands:
            cmd_name = cmd_info["name"]
            cmd_file = cmd_info["file"]

            # 读取源命令文件
            source_file = extension_dir / cmd_file
            if not source_file.exists():
                continue

            content = source_file.read_text()
            frontmatter, body = self.parse_frontmatter(content)

            # 调整脚本路径
            frontmatter = self._adjust_script_paths(frontmatter)

            # 转换参数占位符
            body = self._convert_argument_placeholder(
                body, "$ARGUMENTS", agent_config["args"]
            )

            # 按代理专用格式渲染
            if agent_config["format"] == "markdown":
                output = self._render_markdown_command(frontmatter, body, manifest.id)
            elif agent_config["format"] == "toml":
                output = self._render_toml_command(frontmatter, body, manifest.id)
            else:
                raise ExtensionError(f"Unsupported format: {agent_config['format']}")

            # 写入命令文件
            dest_file = commands_dir / f"{cmd_name}{agent_config['extension']}"
            dest_file.write_text(output)

            # 为 Copilot 代理生成配套 .prompt.md 文件
            if agent_name == "copilot":
                self._write_copilot_prompt(project_root, cmd_name)

            registered.append(cmd_name)

            # 注册别名
            for alias in cmd_info.get("aliases", []):
                alias_file = commands_dir / f"{alias}{agent_config['extension']}"
                alias_file.write_text(output)
                # 为别名也生成配套 .prompt.md 文件
                if agent_name == "copilot":
                    self._write_copilot_prompt(project_root, alias)
                registered.append(alias)

        return registered

    @staticmethod
    def _write_copilot_prompt(project_root: Path, cmd_name: str) -> None:
        """为 Copilot 代理命令生成配套的 `.prompt.md` 文件。

        Copilot 要求在 `.github/prompts/` 下存在 `.prompt.md` 文件，
        并通过 frontmatter 中的 `agent:` 字段引用 `.github/agents/`
        下对应的 `.agent.md` 文件。

        参数:
            project_root: 项目根路径
            cmd_name: 命令名（作为文件名主体，例如 `'speckit.my-ext.example'`）
        """
        prompts_dir = project_root / ".github" / "prompts"
        prompts_dir.mkdir(parents=True, exist_ok=True)
        prompt_file = prompts_dir / f"{cmd_name}.prompt.md"
        prompt_file.write_text(f"---\nagent: {cmd_name}\n---\n")

    def register_commands_for_all_agents(
        self,
        manifest: ExtensionManifest,
        extension_dir: Path,
        project_root: Path
    ) -> Dict[str, List[str]]:
        """为所有检测到的代理注册扩展命令。

        参数:
            manifest: 扩展清单
            extension_dir: 扩展目录路径
            project_root: 项目根路径

        返回:
            代理名到已注册命令列表的映射字典
        """
        results = {}

        # 检测项目中有哪些代理
        for agent_name, agent_config in self.AGENT_CONFIGS.items():
            agent_dir = project_root / agent_config["dir"].split("/")[0]

            # 若代理目录存在则注册
            if agent_dir.exists():
                try:
                    registered = self.register_commands_for_agent(
                        agent_name, manifest, extension_dir, project_root
                    )
                    if registered:
                        results[agent_name] = registered
                except ExtensionError:
                    # 出错时跳过该代理
                    continue

        return results

    def register_commands_for_claude(
        self,
        manifest: ExtensionManifest,
        extension_dir: Path,
        project_root: Path
    ) -> List[str]:
        """为 Claude Code 代理注册扩展命令。

        参数:
            manifest: 扩展清单
            extension_dir: 扩展目录路径
            project_root: 项目根路径

        返回:
            已注册命令名称列表
        """
        return self.register_commands_for_agent("claude", manifest, extension_dir, project_root)


class ExtensionCatalog:
    """管理扩展目录的拉取、缓存与搜索。"""

    DEFAULT_CATALOG_URL = "https://raw.githubusercontent.com/github/spec-kit/main/extensions/catalog.json"
    CACHE_DURATION = 3600  # 1 hour in seconds

    def __init__(self, project_root: Path):
        """初始化扩展目录管理器。

        参数:
            project_root: spec-kit 项目的根目录
        """
        self.project_root = project_root
        self.extensions_dir = project_root / ".specify" / "extensions"
        self.cache_dir = self.extensions_dir / ".cache"
        self.cache_file = self.cache_dir / "catalog.json"
        self.cache_metadata_file = self.cache_dir / "catalog-metadata.json"

    def get_catalog_url(self) -> str:
        """从配置获取目录 URL，或使用默认值。

        检查顺序：
        1. `SPECKIT_CATALOG_URL` 环境变量
        2. 默认目录 URL

        返回:
            用于拉取目录的 URL

        异常:
            ValidationError: 当自定义 URL 非法（非 HTTPS）时
        """
        import os
        import sys
        from urllib.parse import urlparse

        # 环境变量覆盖（便于测试）
        if env_value := os.environ.get("SPECKIT_CATALOG_URL"):
            catalog_url = env_value.strip()
            parsed = urlparse(catalog_url)

            # 出于安全要求必须使用 HTTPS（防止中间人攻击）
            # 本地开发/测试允许 http://localhost
            is_localhost = parsed.hostname in ("localhost", "127.0.0.1", "::1")
            if parsed.scheme != "https" and not (parsed.scheme == "http" and is_localhost):
                raise ValidationError(
                    f"Invalid SPECKIT_CATALOG_URL: must use HTTPS (got {parsed.scheme}://). "
                    "HTTP is only allowed for localhost."
                )

            if not parsed.netloc:
                raise ValidationError(
                    "Invalid SPECKIT_CATALOG_URL: must be a valid URL with a host."
                )

            # 使用非默认目录时给出警告（每个实例仅一次）
            if catalog_url != self.DEFAULT_CATALOG_URL:
                if not getattr(self, "_non_default_catalog_warning_shown", False):
                    print(
                        "Warning: Using non-default extension catalog. "
                        "Only use catalogs from sources you trust.",
                        file=sys.stderr,
                    )
                    self._non_default_catalog_warning_shown = True

            return catalog_url

        # TODO: 支持从 .specify/extension-catalogs.yml 读取自定义目录
        return self.DEFAULT_CATALOG_URL

    def is_cache_valid(self) -> bool:
        """检查缓存的目录是否仍然有效。

        返回:
            缓存存在且未超过有效期时返回 True
        """
        if not self.cache_file.exists() or not self.cache_metadata_file.exists():
            return False

        try:
            metadata = json.loads(self.cache_metadata_file.read_text())
            cached_at = datetime.fromisoformat(metadata.get("cached_at", ""))
            age_seconds = (datetime.now(timezone.utc) - cached_at).total_seconds()
            return age_seconds < self.CACHE_DURATION
        except (json.JSONDecodeError, ValueError, KeyError):
            return False

    def fetch_catalog(self, force_refresh: bool = False) -> Dict[str, Any]:
        """从 URL 或缓存拉取扩展目录。

        参数:
            force_refresh: 若为 True，跳过缓存并从网络拉取

        返回:
            目录数据字典

        异常:
            ExtensionError: 当目录无法拉取时
        """
        # 除非强制刷新，否则优先检查缓存
        if not force_refresh and self.is_cache_valid():
            try:
                return json.loads(self.cache_file.read_text())
            except json.JSONDecodeError:
                pass  # Fall through to network fetch

        # 从网络获取
        catalog_url = self.get_catalog_url()

        try:
            import urllib.request
            import urllib.error

            with urllib.request.urlopen(catalog_url, timeout=10) as response:
                catalog_data = json.loads(response.read())

            # 校验目录结构
            if "schema_version" not in catalog_data or "extensions" not in catalog_data:
                raise ExtensionError("Invalid catalog format")

            # 保存到缓存
            self.cache_dir.mkdir(parents=True, exist_ok=True)
            self.cache_file.write_text(json.dumps(catalog_data, indent=2))

            # 保存缓存元数据
            metadata = {
                "cached_at": datetime.now(timezone.utc).isoformat(),
                "catalog_url": catalog_url,
            }
            self.cache_metadata_file.write_text(json.dumps(metadata, indent=2))

            return catalog_data

        except urllib.error.URLError as e:
            raise ExtensionError(f"Failed to fetch catalog from {catalog_url}: {e}")
        except json.JSONDecodeError as e:
            raise ExtensionError(f"Invalid JSON in catalog: {e}")

    def search(
        self,
        query: Optional[str] = None,
        tag: Optional[str] = None,
        author: Optional[str] = None,
        verified_only: bool = False,
    ) -> List[Dict[str, Any]]:
        """在目录中搜索扩展。

        参数:
            query: 搜索词（搜索名称、描述、标签）
            tag: 按指定标签筛选
            author: 按作者名筛选
            verified_only: 若为 True，仅显示已验证扩展

        返回:
            匹配的扩展元数据列表
        """
        catalog = self.fetch_catalog()
        extensions = catalog.get("extensions", {})

        results = []

        for ext_id, ext_data in extensions.items():
            # 应用筛选条件
            if verified_only and not ext_data.get("verified", False):
                continue

            if author and ext_data.get("author", "").lower() != author.lower():
                continue

            if tag and tag.lower() not in [t.lower() for t in ext_data.get("tags", [])]:
                continue

            if query:
                # 在名称、描述和标签中搜索
                query_lower = query.lower()
                searchable_text = " ".join(
                    [
                        ext_data.get("name", ""),
                        ext_data.get("description", ""),
                        ext_id,
                    ]
                    + ext_data.get("tags", [])
                ).lower()

                if query_lower not in searchable_text:
                    continue

            results.append({"id": ext_id, **ext_data})

        return results

    def get_extension_info(self, extension_id: str) -> Optional[Dict[str, Any]]:
        """获取指定扩展的详细信息。

        参数:
            extension_id: 扩展 ID

        返回:
            扩展元数据；若未找到则返回 None
        """
        catalog = self.fetch_catalog()
        extensions = catalog.get("extensions", {})

        if extension_id in extensions:
            return {"id": extension_id, **extensions[extension_id]}

        return None

    def download_extension(self, extension_id: str, target_dir: Optional[Path] = None) -> Path:
        """从目录下载扩展 ZIP。

        参数:
            extension_id: 要下载的扩展 ID
            target_dir: 保存 ZIP 文件的目录（默认临时目录）

        返回:
            已下载 ZIP 文件路径

        异常:
            ExtensionError: 当扩展不存在或下载失败时
        """
        import urllib.request
        import urllib.error

        # 从目录中获取扩展信息
        ext_info = self.get_extension_info(extension_id)
        if not ext_info:
            raise ExtensionError(f"Extension '{extension_id}' not found in catalog")

        download_url = ext_info.get("download_url")
        if not download_url:
            raise ExtensionError(f"Extension '{extension_id}' has no download URL")

        # 校验下载 URL 必须使用 HTTPS（防止中间人攻击）
        from urllib.parse import urlparse
        parsed = urlparse(download_url)
        is_localhost = parsed.hostname in ("localhost", "127.0.0.1", "::1")
        if parsed.scheme != "https" and not (parsed.scheme == "http" and is_localhost):
            raise ExtensionError(
                f"Extension download URL must use HTTPS: {download_url}"
            )

        # 确定目标路径
        if target_dir is None:
            target_dir = self.cache_dir / "downloads"
        target_dir.mkdir(parents=True, exist_ok=True)

        version = ext_info.get("version", "unknown")
        zip_filename = f"{extension_id}-{version}.zip"
        zip_path = target_dir / zip_filename

        # 下载 ZIP 文件
        try:
            with urllib.request.urlopen(download_url, timeout=60) as response:
                zip_data = response.read()

            zip_path.write_bytes(zip_data)
            return zip_path

        except urllib.error.URLError as e:
            raise ExtensionError(f"Failed to download extension from {download_url}: {e}")
        except IOError as e:
            raise ExtensionError(f"Failed to save extension ZIP: {e}")

    def clear_cache(self):
        """清空目录缓存。"""
        if self.cache_file.exists():
            self.cache_file.unlink()
        if self.cache_metadata_file.exists():
            self.cache_metadata_file.unlink()


class ConfigManager:
    """管理扩展的分层配置。

    配置层级（优先级由低到高）：
    1. 默认值（来自 extension.yml）
    2. 项目配置（`.specify/extensions/{ext-id}/{ext-id}-config.yml`）
    3. 本地配置（`.specify/extensions/{ext-id}/local-config.yml`，被 gitignore）
    4. 环境变量（`SPECKIT_{EXT_ID}_{KEY}`）
    """

    def __init__(self, project_root: Path, extension_id: str):
        """为某个扩展初始化配置管理器。

        参数:
            project_root: spec-kit 项目根目录
            extension_id: 扩展 ID
        """
        self.project_root = project_root
        self.extension_id = extension_id
        self.extension_dir = project_root / ".specify" / "extensions" / extension_id

    def _load_yaml_config(self, file_path: Path) -> Dict[str, Any]:
        """从 YAML 文件加载配置。

        参数:
            file_path: YAML 文件路径

        返回:
            配置字典
        """
        if not file_path.exists():
            return {}

        try:
            return yaml.safe_load(file_path.read_text()) or {}
        except (yaml.YAMLError, OSError):
            return {}

    def _get_extension_defaults(self) -> Dict[str, Any]:
        """从扩展清单获取默认配置。

        返回:
            默认配置字典
        """
        manifest_path = self.extension_dir / "extension.yml"
        if not manifest_path.exists():
            return {}

        manifest_data = self._load_yaml_config(manifest_path)
        return manifest_data.get("config", {}).get("defaults", {})

    def _get_project_config(self) -> Dict[str, Any]:
        """获取项目级配置。

        返回:
            项目配置字典
        """
        config_file = self.extension_dir / f"{self.extension_id}-config.yml"
        return self._load_yaml_config(config_file)

    def _get_local_config(self) -> Dict[str, Any]:
        """获取本地配置（被 gitignore、机器相关）。

        返回:
            本地配置字典
        """
        config_file = self.extension_dir / "local-config.yml"
        return self._load_yaml_config(config_file)

    def _get_env_config(self) -> Dict[str, Any]:
        """从环境变量获取配置。

        环境变量遵循以下模式：
        `SPECKIT_{EXT_ID}_{SECTION}_{KEY}`

        例如：
        - `SPECKIT_JIRA_CONNECTION_URL`
        - `SPECKIT_JIRA_PROJECT_KEY`

        返回:
            从环境变量解析出的配置字典
        """
        import os

        env_config = {}
        ext_id_upper = self.extension_id.replace("-", "_").upper()
        prefix = f"SPECKIT_{ext_id_upper}_"

        for key, value in os.environ.items():
            if not key.startswith(prefix):
                continue

            # 去掉前缀并拆分为多个部分
            config_path = key[len(prefix):].lower().split("_")

            # 构建嵌套字典
            current = env_config
            for part in config_path[:-1]:
                if part not in current:
                    current[part] = {}
                current = current[part]

            # 设置最终值
            current[config_path[-1]] = value

        return env_config

    def _merge_configs(self, base: Dict[str, Any], override: Dict[str, Any]) -> Dict[str, Any]:
        """递归合并两个配置字典。

        参数:
            base: 基础配置
            override: 要覆盖到上层的配置

        返回:
            合并后的配置
        """
        result = base.copy()

        for key, value in override.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                # 对嵌套字典进行递归合并
                result[key] = self._merge_configs(result[key], value)
            else:
                # 覆盖值
                result[key] = value

        return result

    def get_config(self) -> Dict[str, Any]:
        """获取扩展最终合并后的配置。

        配置层按以下顺序合并：
        `defaults -> project -> local -> env`

        返回:
            最终合并后的配置字典
        """
        # 从默认值开始
        config = self._get_extension_defaults()

        # 合并项目级配置
        config = self._merge_configs(config, self._get_project_config())

        # 合并本地配置
        config = self._merge_configs(config, self._get_local_config())

        # 合并环境变量配置
        config = self._merge_configs(config, self._get_env_config())

        return config

    def get_value(self, key_path: str, default: Any = None) -> Any:
        """通过点号路径获取指定配置值。

        参数:
            key_path: 配置值的点分路径（例如 `"connection.url"`）
            default: 未找到键时返回的默认值

        返回:
            配置值或默认值

        示例:
            >>> config = ConfigManager(project_root, "jira")
            >>> url = config.get_value("connection.url")
            >>> timeout = config.get_value("connection.timeout", 30)
        """
        config = self.get_config()
        keys = key_path.split(".")

        current = config
        for key in keys:
            if not isinstance(current, dict) or key not in current:
                return default
            current = current[key]

        return current

    def has_value(self, key_path: str) -> bool:
        """检查某个配置值是否存在。

        参数:
            key_path: 配置值的点分路径

        返回:
            若值存在（即使为 None）返回 True，否则返回 False
        """
        config = self.get_config()
        keys = key_path.split(".")

        current = config
        for key in keys:
            if not isinstance(current, dict) or key not in current:
                return False
            current = current[key]

        return True


class HookExecutor:
    """管理扩展 hook 的执行流程。"""

    def __init__(self, project_root: Path):
        """初始化 hook 执行器。

        参数:
            project_root: spec-kit 项目根目录
        """
        self.project_root = project_root
        self.extensions_dir = project_root / ".specify" / "extensions"
        self.config_file = project_root / ".specify" / "extensions.yml"

    def get_project_config(self) -> Dict[str, Any]:
        """加载项目级扩展配置。

        返回:
            扩展配置字典
        """
        if not self.config_file.exists():
            return {
                "installed": [],
                "settings": {"auto_execute_hooks": True},
                "hooks": {},
            }

        try:
            return yaml.safe_load(self.config_file.read_text()) or {}
        except (yaml.YAMLError, OSError):
            return {
                "installed": [],
                "settings": {"auto_execute_hooks": True},
                "hooks": {},
            }

    def save_project_config(self, config: Dict[str, Any]):
        """保存项目级扩展配置。

        参数:
            config: 要保存的配置字典
        """
        self.config_file.parent.mkdir(parents=True, exist_ok=True)
        self.config_file.write_text(
            yaml.dump(config, default_flow_style=False, sort_keys=False)
        )

    def register_hooks(self, manifest: ExtensionManifest):
        """在项目配置中注册扩展 hooks。

        参数:
            manifest: 包含待注册 hooks 的扩展清单
        """
        if not hasattr(manifest, "hooks") or not manifest.hooks:
            return

        config = self.get_project_config()

        # 确保 hooks 字典存在
        if "hooks" not in config:
            config["hooks"] = {}

        # 注册每个 hook
        for hook_name, hook_config in manifest.hooks.items():
            if hook_name not in config["hooks"]:
                config["hooks"][hook_name] = []

            # 添加 hook 条目
            hook_entry = {
                "extension": manifest.id,
                "command": hook_config.get("command"),
                "enabled": True,
                "optional": hook_config.get("optional", True),
                "prompt": hook_config.get(
                    "prompt", f"Execute {hook_config.get('command')}?"
                ),
                "description": hook_config.get("description", ""),
                "condition": hook_config.get("condition"),
            }

            # 检查是否已注册
            existing = [
                h
                for h in config["hooks"][hook_name]
                if h.get("extension") == manifest.id
            ]

            if not existing:
                config["hooks"][hook_name].append(hook_entry)
            else:
                # 更新已有条目
                for i, h in enumerate(config["hooks"][hook_name]):
                    if h.get("extension") == manifest.id:
                        config["hooks"][hook_name][i] = hook_entry

        self.save_project_config(config)

    def unregister_hooks(self, extension_id: str):
        """从项目配置中移除扩展 hooks。

        参数:
            extension_id: 要注销的扩展 ID
        """
        config = self.get_project_config()

        if "hooks" not in config:
            return

        # 移除此扩展的 hooks
        for hook_name in config["hooks"]:
            config["hooks"][hook_name] = [
                h
                for h in config["hooks"][hook_name]
                if h.get("extension") != extension_id
            ]

        # 清理空的 hook 数组
        config["hooks"] = {
            name: hooks for name, hooks in config["hooks"].items() if hooks
        }

        self.save_project_config(config)

    def get_hooks_for_event(self, event_name: str) -> List[Dict[str, Any]]:
        """获取某个事件已注册的所有 hooks。

        参数:
            event_name: 事件名称（例如 `'after_tasks'`）

        返回:
            hook 配置列表
        """
        config = self.get_project_config()
        hooks = config.get("hooks", {}).get(event_name, [])

        # 仅保留已启用的 hooks
        return [h for h in hooks if h.get("enabled", True)]

    def should_execute_hook(self, hook: Dict[str, Any]) -> bool:
        """根据条件判断 hook 是否应执行。

        参数:
            hook: hook 配置

        返回:
            应执行返回 True，否则返回 False
        """
        condition = hook.get("condition")

        if not condition:
            return True

        # 解析并计算条件
        try:
            return self._evaluate_condition(condition, hook.get("extension"))
        except Exception:
            # 条件计算失败时，默认不执行
            return False

    def _evaluate_condition(self, condition: str, extension_id: Optional[str]) -> bool:
        """计算 hook 条件表达式。

        支持的条件模式：
        - `"config.key.path is set"`：检查配置值是否存在
        - `"config.key.path == 'value'"`：检查配置值是否等于给定值
        - `"config.key.path != 'value'"`：检查配置值是否不等于给定值
        - `"env.VAR_NAME is set"`：检查环境变量是否存在
        - `"env.VAR_NAME == 'value'"`：检查环境变量是否等于给定值

        参数:
            condition: 条件表达式字符串
            extension_id: 用于查配置的扩展 ID

        返回:
            条件成立返回 True，否则返回 False
        """
        import os

        condition = condition.strip()

        # 模式："config.key.path is set"
        if match := re.match(r'config\.([a-z0-9_.]+)\s+is\s+set', condition, re.IGNORECASE):
            key_path = match.group(1)
            if not extension_id:
                return False

            config_manager = ConfigManager(self.project_root, extension_id)
            return config_manager.has_value(key_path)

        # 模式："config.key.path == 'value'" 或 "config.key.path != 'value'"
        if match := re.match(r'config\.([a-z0-9_.]+)\s*(==|!=)\s*["\']([^"\']+)["\']', condition, re.IGNORECASE):
            key_path = match.group(1)
            operator = match.group(2)
            expected_value = match.group(3)

            if not extension_id:
                return False

            config_manager = ConfigManager(self.project_root, extension_id)
            actual_value = config_manager.get_value(key_path)

            # 将布尔值标准化为小写后比较
            # （YAML True/False 与条件字符串 'true'/'false'）
            if isinstance(actual_value, bool):
                normalized_value = "true" if actual_value else "false"
            else:
                normalized_value = str(actual_value)

            if operator == "==":
                return normalized_value == expected_value
            else:  # !=
                return normalized_value != expected_value

        # 模式："env.VAR_NAME is set"
        if match := re.match(r'env\.([A-Z0-9_]+)\s+is\s+set', condition, re.IGNORECASE):
            var_name = match.group(1).upper()
            return var_name in os.environ

        # 模式："env.VAR_NAME == 'value'" 或 "env.VAR_NAME != 'value'"
        if match := re.match(r'env\.([A-Z0-9_]+)\s*(==|!=)\s*["\']([^"\']+)["\']', condition, re.IGNORECASE):
            var_name = match.group(1).upper()
            operator = match.group(2)
            expected_value = match.group(3)

            actual_value = os.environ.get(var_name, "")

            if operator == "==":
                return actual_value == expected_value
            else:  # !=
                return actual_value != expected_value

        # 未知条件格式，为安全起见默认 False
        return False

    def format_hook_message(
        self, event_name: str, hooks: List[Dict[str, Any]]
    ) -> str:
        """格式化 hook 执行消息，用于命令输出展示。

        参数:
            event_name: 事件名称
            hooks: 待执行 hook 列表

        返回:
            格式化后的消息字符串
        """
        if not hooks:
            return ""

        lines = ["\n## Extension Hooks\n"]
        lines.append(f"Hooks available for event '{event_name}':\n")

        for hook in hooks:
            extension = hook.get("extension")
            command = hook.get("command")
            optional = hook.get("optional", True)
            prompt = hook.get("prompt", "")
            description = hook.get("description", "")

            if optional:
                lines.append(f"\n**Optional Hook**: {extension}")
                lines.append(f"Command: `/{command}`")
                if description:
                    lines.append(f"Description: {description}")
                lines.append(f"\nPrompt: {prompt}")
                lines.append(f"To execute: `/{command}`")
            else:
                lines.append(f"\n**Automatic Hook**: {extension}")
                lines.append(f"Executing: `/{command}`")
                lines.append(f"EXECUTE_COMMAND: {command}")

        return "\n".join(lines)

    def check_hooks_for_event(self, event_name: str) -> Dict[str, Any]:
        """检查某个事件是否注册了 hooks。

        该方法设计为在核心命令执行完后由 AI 代理调用。

        参数:
            event_name: 事件名称（例如 `'after_spec'`、`'after_tasks'`）

        返回:
            包含 hook 信息的字典：
            - `has_hooks: bool`：该事件是否存在 hooks
            - `hooks: List[Dict]`：hook 列表（已应用条件判断）
            - `message: str`：用于展示的格式化消息
        """
        hooks = self.get_hooks_for_event(event_name)

        if not hooks:
            return {
                "has_hooks": False,
                "hooks": [],
                "message": ""
            }

        # 按条件筛选 hooks
        executable_hooks = []
        for hook in hooks:
            if self.should_execute_hook(hook):
                executable_hooks.append(hook)

        if not executable_hooks:
            return {
                "has_hooks": False,
                "hooks": [],
                "message": f"# No executable hooks for event '{event_name}' (conditions not met)"
            }

        return {
            "has_hooks": True,
            "hooks": executable_hooks,
            "message": self.format_hook_message(event_name, executable_hooks)
        }

    def execute_hook(self, hook: Dict[str, Any]) -> Dict[str, Any]:
        """执行单个 hook 命令。

        注意：该方法返回的是如何执行 hook 的信息。
        实际执行由 AI 代理负责。

        参数:
            hook: hook 配置

        返回:
            包含执行信息的字典：
            - `command: str`：要执行的命令
            - `extension: str`：扩展 ID
            - `optional: bool`：该 hook 是否可选
            - `description: str`：hook 描述
        """
        return {
            "command": hook.get("command"),
            "extension": hook.get("extension"),
            "optional": hook.get("optional", True),
            "description": hook.get("description", ""),
            "prompt": hook.get("prompt", "")
        }

    def enable_hooks(self, extension_id: str):
        """启用某个扩展的全部 hooks。

        参数:
            extension_id: 扩展 ID
        """
        config = self.get_project_config()

        if "hooks" not in config:
            return

        # 启用该扩展的全部 hooks
        for hook_name in config["hooks"]:
            for hook in config["hooks"][hook_name]:
                if hook.get("extension") == extension_id:
                    hook["enabled"] = True

        self.save_project_config(config)

    def disable_hooks(self, extension_id: str):
        """禁用某个扩展的全部 hooks。

        参数:
            extension_id: 扩展 ID
        """
        config = self.get_project_config()

        if "hooks" not in config:
            return

        # 禁用该扩展的全部 hooks
        for hook_name in config["hooks"]:
            for hook in config["hooks"][hook_name]:
                if hook.get("extension") == extension_id:
                    hook["enabled"] = False

        self.save_project_config(config)

