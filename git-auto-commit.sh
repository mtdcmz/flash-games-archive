#!/bin/bash

# ================= 配置区 =================
FIXED_USER="mtdcmz"
FIXED_EMAIL="meitadechangmingzi@gmail.com" # 建议填真实的
REMOTE_URL="https://github.com/mtdcmz/flash-games-archive.git"
# ==========================================

pause_exit() {
    echo ""
    read -p "按回车键退出窗口..."
    exit
}

echo "--- 🚀 开始执行自动化 Git 配置 ---"

# 1. 基础配置
git config --global user.name "$FIXED_USER"
git config --global user.email "$FIXED_EMAIL"

# 2. 初始化与远程连接
[ ! -d ".git" ] && git init && echo "✅ 初始化仓库"
git remote set-url origin "$REMOTE_URL" 2>/dev/null || git remote add origin "$REMOTE_URL"

# 3. 选择路径
echo "------------------------------------------"
ls -F
echo "------------------------------------------"
read -p "请输入要提交的文件或路径 (直接回车代表全部): " TARGET
[ -z "$TARGET" ] && TARGET="."

# 💡 核心修复：检查路径是否存在
if [ ! -e "$TARGET" ]; then
    echo "⚠️ 警告: 路径 '$TARGET' 在当前目录下不存在。"
    echo "正在尝试创建文件夹并添加占位文件..."
    mkdir -p "$TARGET"
    touch "$TARGET/.gitkeep"
fi

# 4. 提交准备
git add "$TARGET"
# 额外：把发生变动的 index.html 和 play.html 也顺便加上（可选）
# git add index.html play.html 

# 检查是否有内容被 stage
if git diff --cached --quiet; then
    echo "❌ 错误: 暂存区为空。可能原因："
    echo "   1. 你输入的路径下没有新文件或修改。"
    echo "   2. 文件被 .gitignore 忽略了。"
    pause_exit
fi

read -p "请输入提交说明: " MESSAGE
[ -z "$MESSAGE" ] && MESSAGE="Upload: $TARGET"

git commit -m "$MESSAGE"

# 5. 推送并显示进度
CURRENT_BRANCH=$(git branch --show-current)
[ -z "$CURRENT_BRANCH" ] && git branch -M main && CURRENT_BRANCH="main"

echo "--- 📦 正在上传到 $CURRENT_BRANCH 分支... ---"
# 使用 --verbose 显示更多细节
git push -u origin "$CURRENT_BRANCH" --progress --verbose

if [ $? -eq 0 ]; then
    echo "--- 🎉 成功！请刷新 GitHub 页面查看 ---"
else
    echo "❌ 推送失败。请检查网络或 GitHub Token 权限。"
fi

pause_exit