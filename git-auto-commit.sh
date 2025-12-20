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

echo "--- 🚀 正在执行【强力同步】模式 ---"

# 1. 环境初始化
git config --global user.name "$FIXED_USER"
git config --global user.email "$FIXED_EMAIL"
[ ! -d ".git" ] && git init && git remote add origin "$REMOTE_URL"
git remote set-url origin "$REMOTE_URL"

# 2. 强制添加所有变动 (解决路径输入无效的问题)
echo "正在扫描所有文件变动..."
git add . 

# 3. 提交变动
CHANGES=$(git status --porcelain)
if [ -z "$CHANGES" ]; then
    echo "ℹ️  没有新文件需要提交，准备直接同步远程..."
else
    echo "检测到变动，正在记录..."
    git commit -m "Auto-sync: $(date +'%Y-%m-%d %H:%M')"
fi

# 4. 获取分支名
BRANCH=$(git branch --show-current)
[ -z "$BRANCH" ] && BRANCH="main"

# 5. 核心修复：强力推送
echo "--- 📦 正在上传 (强制覆盖模式) ---"
echo "提示：正在解决远程冲突，请稍候..."

# 使用 -f 强制推送，解决 [rejected] non-fast-forward 问题
git push -u origin "$BRANCH" --force --progress

if [ $? -eq 0 ]; then
    echo "--- 🎉 【成功】文件已强制同步到 GitHub！ ---"
else
    echo "❌ 【失败】即便使用强制模式也无法上传。"
    echo "请检查：1. 网络是否通畅  2. GitHub 是否需要 Token 登录"
fi

pause_exit