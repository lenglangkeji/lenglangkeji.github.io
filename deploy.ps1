<#
  冷狼电子工作室官网 · 一键发布到 GitHub Pages
  用法：右键本文件 -> 使用 PowerShell 运行
  说明：会自动查找 Git（PATH / 内置便携版 / 默认安装位置）
        若装了 GitHub CLI (gh) 则可全自动建仓、推送并开启 Pages
#>

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

function Write-Step([string]$msg) { Write-Host ""; Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok([string]$msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn([string]$msg) { Write-Host "    $msg" -ForegroundColor Yellow }

Write-Host "冷狼电子工作室官网 发布助手" -ForegroundColor White
Write-Host "目录：$PSScriptRoot" -ForegroundColor DarkGray

# ---------- 1. 查找 Git ----------
Write-Step "查找 Git"
$candidates = @()
$cmd = Get-Command git -ErrorAction SilentlyContinue
if ($cmd) { $candidates += $cmd.Source }
$candidates += (Join-Path $env:USERPROFILE 'Documents\Codex\tools\git\cmd\git.exe')
$candidates += 'C:\Program Files\Git\cmd\git.exe'
$candidates += 'C:\Program Files (x86)\Git\cmd\git.exe'

$gitExe = $null
foreach ($c in $candidates) {
  if ($c -and (Test-Path $c)) { $gitExe = $c; break }
}

if (-not $gitExe) {
  Write-Warn "没有找到 Git。"
  Write-Host "请先双击安装：下载文件夹里的 Git-2.55.0.5-64-bit.exe（一路下一步即可）" -ForegroundColor Yellow
  Read-Host "按回车退出"
  exit 1
}

# 沙箱/多账户环境下文件属主可能不是当前用户，git 会拒绝操作，这里显式放行本目录
$repoPath = ($PSScriptRoot -replace '\\', '/')
function Invoke-Git { & $gitExe -c "safe.directory=$repoPath" @args }
Write-Ok "Git: $gitExe"
Write-Ok "版本: $(& $gitExe --version)"

# ---------- 2. 初始化本地仓库并提交 ----------
Write-Step "初始化本地仓库"
if (-not (Test-Path '.git')) {
  Invoke-Git init -b main | Out-Null
  Write-Ok "已执行 git init"
} else {
  Write-Ok "已存在 .git，跳过"
}

Invoke-Git add -A
$changes = Invoke-Git status --porcelain
if ($changes) {
  Invoke-Git -c user.name="冷狼电子工作室" -c user.email="1583025349@qq.com" commit -m "feat: 冷狼电子工作室官网（嵌入式项目开发 / ROS2智能车教具）" | Out-Null
  Write-Ok "已提交本地改动"
} else {
  Write-Ok "没有新的改动需要提交"
}

try { Invoke-Git branch -M main } catch {}
Write-Ok "当前分支：main"

# ---------- 3. 有 gh 就全自动 ----------
$gh = Get-Command gh -ErrorAction SilentlyContinue

if ($gh) {
  Write-Step "检测到 GitHub CLI"
  & gh auth status *> $null
  if ($LASTEXITCODE -ne 0) {
    Write-Warn "需要先登录 GitHub，会打开浏览器让你授权"
    & gh auth login --web --git-protocol https
  }
  Write-Ok "GitHub 登录正常"

  $user = (& gh api user --jq .login).Trim()
  $tip = "仓库名（直接回车使用 $user.github.io）"
  $repo = Read-Host $tip
  if ([string]::IsNullOrWhiteSpace($repo)) { $repo = "$user.github.io" }

  Write-Step "创建仓库 $user/$repo 并推送"
  & gh repo create $repo --public --source=. --remote=origin --push
  if ($LASTEXITCODE -ne 0) {
    Write-Warn "gh 建仓失败，可能仓库已存在，改为直接推送"
    Invoke-Git remote remove origin 2>$null | Out-Null
    Invoke-Git remote add origin "https://github.com/$user/$repo.git"
    Invoke-Git push -u origin main
  }
  Write-Ok "代码已推送"

  Write-Step "开启 GitHub Pages"
  try {
    & gh api -X POST "repos/$user/$repo/pages" -f "source[branch]=main" -f "source[path]=/" *> $null
    Write-Ok "Pages 已开启"
  } catch {
    Write-Warn "自动开启失败，请手动操作 Settings -> Pages"
  }

  if ($repo -eq "$user.github.io") { $url = "https://$user.github.io" } else { $url = "https://$user.github.io/$repo/" }
  Write-Host ""
  Write-Host "完成！1~2 分钟后访问：$url" -ForegroundColor Green
}
else {
  # ---------- 没有 gh 时的手动引导 ----------
  Write-Step "没有检测到 GitHub CLI"
  $manual = @(
    '接下来手动操作（大约 2 分钟）：',
    '',
    '  1. 打开 https://github.com/new',
    '  2. Repository name 填：你的用户名.github.io',
    '     （例如用户名是 lenglang，就填 lenglang.github.io）',
    '  3. 可见性选 Public，下面三个初始化选项（README / .gitignore / license）都不要勾',
    '  4. 点 Create repository',
    '',
    '  5. 把下面两条命令里的【你的用户名】替换掉，逐条粘贴运行：',
    '',
    '     git remote add origin https://github.com/你的用户名/你的用户名.github.io.git',
    '     git push -u origin main',
    '',
    '  6. 回到仓库页面 -> Settings -> Pages',
    '     Source 选 Deploy from a branch，Branch 选 main + / (root)，Save',
    '',
    '  7. 等 1~2 分钟，访问 https://你的用户名.github.io'
  ) -join [Environment]::NewLine
  Write-Host $manual -ForegroundColor Gray
  Write-Ok "本地仓库已经准备好了，只差 push"
}

Write-Host ""
Read-Host "按回车退出"