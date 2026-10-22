@echo off
chcp 65001 >nul
echo ========================================================
echo   🏫 林口國中 717 班・每日課後複習勇者學園
echo   🚀 一鍵打包與上傳至 GitHub 免費空間小幫手
echo ========================================================
echo.

cd /d "%~dp0"

if not exist ".git" (
    echo [步驟 1] 正在初始化本地 Git 儲存庫...
    git init
    git branch -M main
)

echo [步驟 2] 正在執行安全防護檢查與檔案打包...
call npm run build
if %errorlevel% neq 0 (
    echo ❌ 專案打包失敗，請檢查錯誤訊息！
    pause
    exit /b 1
)

echo [步驟 3] 正在將所有最新程式碼加入版本控制...
git add .
git commit -m "Update: 林口國中717班每日複習勇者學園 (1-12月月曆與擴充題庫版)"

echo.
git remote -v | findstr "origin" >nul
if %errorlevel% neq 0 (
    echo 💡 請先在 https://github.com/new 建立一個公開儲存庫 (Repository)
    set /p REPO_URL="請貼上您的 GitHub 儲存庫網址 (例如 https://github.com/帳號/lkjh-717.git): "
    git remote add origin "%REPO_URL%"
)

echo [步驟 4] 正在推送到 GitHub (main 分支)...
git push -u origin main

echo.
echo ========================================================
echo 🎉 上傳完成！
echo ・若使用 GitHub Pages：請至 GitHub 儲存庫的 Settings -^> Pages，
echo   將 Source 改為「GitHub Actions」，等待 1 分鐘即可取得免費網址！
echo ・若使用 Vercel：請至 https://vercel.com 點選 Import 該儲存庫即可！
echo ========================================================
pause
