# 一键推到 GitHub 并触发编译
# 用法：.\push.ps1 -User 你的GitHub用户名
# 前提：先在 https://github.com/new 建一个空仓库，名字 Gester-zh（别勾 README）

param(
    [Parameter(Mandatory=$true)][string]$User,
    [string]$Repo = "Gester-zh",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "[*] 仓库: https://github.com/$User/$Repo" -ForegroundColor Cyan
git remote remove origin 2>$null
git remote add origin "https://github.com/$User/$Repo.git"
git branch -M $Branch

Write-Host "[*] 推送中（会弹出 GitHub 登录窗口）..." -ForegroundColor Cyan
git push -u origin $Branch

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[+] 推送成功" -ForegroundColor Green
    Write-Host "    编译进度: https://github.com/$User/$Repo/actions" -ForegroundColor Yellow
    Write-Host "    约 3-5 分钟，跑完在页面底部下载 Gester-zh-ipa.zip" -ForegroundColor Yellow
} else {
    Write-Host "[!] 推送失败，检查仓库是否已建、用户名是否正确" -ForegroundColor Red
}
