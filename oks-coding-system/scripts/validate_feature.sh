#!/bin/bash

# 功能名称验证脚本
# 用法: source oks-coding-system/scripts/validate_feature.sh && validate_feature "$ARGUMENTS" "命令名称"

validate_feature() {
    local feature="$1"
    local command="$2"
    
    # 1. 检查是否为空
    if [ -z "$feature" ]; then
        cat << 'ERROR'
❌ **错误: 缺少功能名称**

**用法**: /COMMAND <功能名称>

**示例**:
- /COMMAND 用户登录
- /COMMAND 购物车功能
- /COMMAND 订单管理

---
ERROR
        return 1
    fi
    
    # 2. 检查长度（至少 2 个字符）
    if [ ${#feature} -lt 2 ]; then
        cat << 'ERROR'
❌ **错误: 功能名称太短**

功能名称应该:
- 包含至少 2 个字符
- 描述具体的功能

**建议**: 使用更具体的名称，如"用户登录"、"购物车"

---
ERROR
        return 1
    fi
    
    # 3. 检查禁用词汇（常见的无意义词汇）
    case "$feature" in
        "继续"|"测试"|"开发"|"test"|"dev"|"debug"|"temp"|"tmp"|"xxx"|"yyy"|"todo")
            cat << 'ERROR'
❌ **错误: "$feature" 不是一个有效的功能名称**

功能名称应该:
- 描述具体的功能（如：用户登录、购物车）
- 不是通用词汇（如：继续、测试、开发）

**用法**: /COMMAND <功能名称>

**示例**:
- /COMMAND 用户登录
- /COMMAND 购物车功能
- /COMMAND 订单管理

---
ERROR
            return 1
            ;;
    esac
    
    # 验证通过
    return 0
}
