# 示例项目

这些示例项目展示了如何使用超长篇小说AI创作系统。

## 项目列表

1. **xuanhuan-100chapters** - 玄幻小说示例（100章）
   - 类型：玄幻修仙
   - 主角：林轩
   - 简介：废材逆袭，修炼成神

2. **scifi-50chapters** - 科幻小说示例（50章）
   - 类型：末世科幻
   - 主角：陈默
   - 简介：AI统治下的反抗与觉醒

3. **romance-30chapters** - 言情小说示例（30章）
   - 类型：现代言情
   - 主角：苏晴、顾言
   - 简介：咖啡店邂逅的浪漫故事

## 使用方法

您可以基于这些示例项目来创建自己的小说项目：

```bash
cd novel-ai-system-v16
cp -r examples/xuanhuan-100chapters projects/我的新项目
# 然后编辑项目文件以适应您的设定
```

或者运行初始化脚本创建全新的项目：

```bash
./scripts/01-init-project.sh "我的新项目" 100
```