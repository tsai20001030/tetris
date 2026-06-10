#!/bin/bash
set -euo pipefail

REPO="tsai20001030/tetris"
DIR="$(cd "$(dirname "$0")" && pwd)"
GH_BIN="$DIR/.tools/gh/bin/gh"
GH_VERSION="2.93.0"
GH_ZIP="gh_${GH_VERSION}_macOS_arm64.zip"
GH_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}/${GH_ZIP}"

cd "$DIR"

install_gh() {
  if command -v gh >/dev/null 2>&1; then
    GH_BIN="$(command -v gh)"
    return
  fi
  if [ -x "$GH_BIN" ]; then
    return
  fi
  echo "正在下載 GitHub CLI..."
  mkdir -p "$DIR/.tools"
  curl -sL -o "$DIR/.tools/$GH_ZIP" "$GH_URL"
  unzip -qo "$DIR/.tools/$GH_ZIP" -d "$DIR/.tools"
  mv "$DIR/.tools/gh_${GH_VERSION}_macOS_arm64" "$DIR/.tools/gh"
  rm -f "$DIR/.tools/$GH_ZIP"
}

run_gh() {
  "$GH_BIN" "$@"
}

install_gh

if ! run_gh auth status >/dev/null 2>&1; then
  echo ""
  echo "請先登入 GitHub（會開啟瀏覽器）..."
  run_gh auth login -h github.com -p https -w
fi

run_gh auth setup-git

if run_gh repo view "$REPO" >/dev/null 2>&1; then
  echo "儲存庫已存在： https://github.com/$REPO"
else
  echo "正在建立儲存庫 $REPO ..."
  run_gh repo create "$REPO" --public --description "單頁俄羅斯方塊遊戲（HTML/CSS/JS）"
fi

git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$REPO.git"
git branch -M main
git push -u origin main

echo ""
echo "發佈成功！"
echo "儲存庫： https://github.com/$REPO"
echo "啟用 Pages 後可於此遊玩： https://tsai20001030.github.io/tetris/tetris.html"
