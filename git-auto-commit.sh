#!/bin/bash

# ================= 配置区 =================
FIXED_USER="mtdcmz"
FIXED_EMAIL="meitadechangmingzi@gmail.com"
REMOTE_URL="https://github.com/mtdcmz/flash-games-archive.git"
# ==========================================

pause_exit() {
    echo ""
    read -p "按回车键退出窗口..."
    exit
}

echo "--- 🚀 正在启动 Git 强力同步脚本 ---"

# 0. 预防性清理：防止上次中途退出导致的 index 被锁定
if [ -f ".git/index.lock" ]; then
    rm -f .git/index.lock
    echo "清理了残留的 Git 锁定文件"
fi

# 1. 配置身份
git config --global user.name "$FIXED_USER"
git config --global user.email "$FIXED_EMAIL"

# 2. 初始化与远程检测
[ ! -d ".git" ] && git init && echo "✅ 初始化本地仓库"
git remote set-url origin "$REMOTE_URL" 2>/dev/null || git remote add origin "$REMOTE_URL"

# 3. 智能添加文件
echo "------------------------------------------"
echo "当前有变动的文件/文件夹："
git status -s  # 显示简短的状态列表，让你看清哪些变了
echo "------------------------------------------"
echo "💡 建议：如果你想提交所有变动（包含图片和游戏），请直接按【回车】"
read -p "请输入要提交的路径: " TARGET

if [ -z "$TARGET" ]; then
    echo "正在添加所有变动内容..."
    git add .
else
    # 尝试添加用户输入的路径
    git add "$TARGET"
    # 同时自动检查并添加关联的图片（如果存在同名的 thumb 图片）
    # 这是一个贴心的小逻辑：如果你输入 games/4/，它会尝试找 images/thumb/4.jpg
    IMAGE_PATH="images/thumb/${TARGET//[!0-9]/}.jpg"
    if [ -f "$IMAGE_PATH" ]; then
        echo "检测到配套图片，已自动添加: $IMAGE_PATH"
        git add "$IMAGE_PATH"
    fi
fi

# 4. 提交校验
if git diff --cached --quiet; then
    echo "⚠️  暂存区依然为空！"
    echo "可能原因：你输入的文件路径没有任何变化，或者文件已被提交过。"
    echo "尝试强制添加该路径..."
    git add -A "$TARGET"
    
    if git diff --cached --quiet; then
        echo "❌ 依然没有检测到任何更改。请确认路径是否正确。"
        pause_exit
    fi
fi

# 5. 执行提交
read -p "请输入本次提交的说明: " MESSAGE
[ -z "$MESSAGE" ] && MESSAGE="update games and assets"
git commit -m "$MESSAGE"

# 6. 推送
CURRENT_BRANCH=$(git branch --show-current)
[ -z "$CURRENT_BRANCH" ] && git branch -M main && CURRENT_BRANCH="main"

echo "--- 📦 正在上传至 $CURRENT_BRANCH 分支... ---"
# --verbose 会让你看到具体的上传速度和进度
git push -u origin "$CURRENT_BRANCH" --progress --verbose

if [ $? -eq 0 ]; then
    echo "--- 🎉 全部操作已成功完成！ ---"
else
    echo "❌ 推送失败，可能是网络问题或远程仓库冲突。"
    echo "提示：如果是远程有更新，请先手动执行 git pull"
fi

pause_exit