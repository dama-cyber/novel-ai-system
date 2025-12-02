# 问题排查

本文档提供常见问题的解决方案。

## 1. Token超限问题

**问题**: Qwen CLI提示Token数量超限

**解决方案**:
```bash
# 方法1: 手动压缩会话
qwen> /compress

# 方法2: 运行压缩脚本
./scripts/05-compress-session.sh

# 方法3: 检查当前Token使用情况
node tools/token-manager.js status
```

**预防措施**:
- 每5章主动压缩会话历史
- 使用智能上下文管理，避免携带过多无关信息
- 合理分批创作，避免单次创作过多章节

## 2. Qwen CLI未安装或未授权

**问题**: 命令行提示 qwen 命令不存在

**解决方案**:
```bash
# 1. 检查Node.js版本
node --version  # 确保 ≥ 20.0

# 2. 安装Qwen CLI
npm install -g @qwen-code/qwen-code@latest

# 3. 授权Qwen CLI
qwen auth
# 选择: Qwen OAuth (推荐)
# 浏览器授权后，每天2000次免费请求
```

## 3. 脚本执行权限问题

**问题**: 在Linux/macOS上提示Permission denied

**解决方案**:
```bash
# 1. 给脚本添加执行权限
chmod +x scripts/*.sh
chmod +x scripts/utils/*.sh

# 2. 或者使用bash命令运行
bash scripts/01-init-project.sh "项目名" 100
```

## 4. 项目初始化失败

**问题**: 运行 `01-init-project.sh` 失败

**常见原因和解决方案**:
- 检查项目名称是否包含特殊字符，建议使用中英文和数字
- 确保目标目录不存在或为空
- 检查是否有写入权限

## 5. 章节创作中断

**问题**: 批量创作章节时中断

**解决方案**:
- 记录中断的章节号，从下一部份重新开始
- 检查错误日志，确定中断原因
- 可以手动调整创作范围，如 `./scripts/03-batch-create.sh "./project" 25 30`

## 6. 设定文件加载失败

**问题**: 提示无法加载角色或世界观设定文件

**解决方案**:
```bash
# 1. 检查设定文件是否存在于settings目录
ls -la projects/你的项目/settings/

# 2. 验证JSON格式是否正确
node -e "console.log(JSON.parse(require('fs').readFileSync('./projects/你的项目/settings/characters.json', 'utf8')));"

# 3. 重新创建设定文件
./scripts/01-init-project.sh "项目名" 100  # 重新初始化
```

## 7. 依赖包安装问题

**问题**: 运行JavaScript工具时提示依赖缺失

**解决方案**:
```bash
# 1. 检查是否在正确的项目目录
cd novel-ai-system-v16

# 2. 确保Node.js环境正常
node --version
npm --version
```

## 8. 网络连接问题

**问题**: Qwen API调用失败

**解决方案**:
- 检查网络连接是否正常
- 确认Qwen账户授权是否有效
- 检查当日API调用次数是否已达上限

## 9. 环境诊断

运行环境诊断工具检查系统状态：

```bash
node tools/diagnostic.js
```

该工具会检查：
- Node.js版本
- Qwen CLI安装状态
- 磁盘空间
- 网络连接
- Git安装状态

## 10. 其他问题

如果遇到其他问题：
1. 检查详细的错误信息
2. 确保使用最新版本的系统
3. 参考文档和示例项目
4. 在GitHub上提交issue