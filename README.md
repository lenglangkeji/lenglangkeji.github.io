# 冷狼电子工作室 · 官网（GitHub Pages）

嵌入式项目开发 & ROS2 智能车教具研发 —— 静态站点，纯 HTML/CSS/JS，无构建依赖，直接丢到 GitHub Pages 就能跑。

## 目录结构

```
.
├── index.html          首页
├── custom.html         承接外包定制（核心业务页）
├── teaching.html       ROS2 智能车教具（热狗01）
├── downloads.html      自研软件下载
├── shop.html           电子模块购买渠道
├── 404.html            错误页
├── robots.txt
├── .nojekyll           告诉 GitHub Pages 不要用 Jekyll 处理
├── favicon.ico
└── assets
    ├── css/style.css
    ├── js/app.js
    ├── img/            图标、二维码、工作室与现场照片
    └── video/          演示视频目录（需自行放入 demo.mp4）
```

## 本地预览

直接双击 `index.html` 即可。若要看视频和相对路径的完整效果，用本地服务器：

```bash
# 有 Python
python -m http.server 8080

# 有 Node
npx serve .
```

然后浏览器打开 http://localhost:8080

## 本机 Git 环境

这台机器上已经准备好 Git 2.55：

- **便携版（已可用）**：`C:\Users\user\Documents\Codex\tools\git\cmd\git.exe`
  这个在当前终端里已经可以直接调用，改 PATH 需要管理员权限，所以没有写入系统环境变量。
- **官方安装包**：`C:\Users\user\Downloads\Git-2.55.0.5-64-bit.exe`
  双击一路“下一步”即可完成标准安装（会自动配好 PATH、Git Bash、右键菜单）。
  安装包已校验数字签名，签署者 `CN=Johannes Schindelin`（Git for Windows 维护者），状态 Valid。

装好后在任意终端执行 `git --version` 能输出版本号即可。

### 关于「dubious ownership」报错

本目录的文件属主是沙箱账户，直接跑 git 可能提示：

```
fatal: detected dubious ownership in repository
```

两种解决办法，任选其一：

```bash
# 办法一：放行这一个目录（推荐）
git config --global --add safe.directory "本目录的绝对路径"

# 办法二：临时用命令行参数放行
git -c safe.directory="本目录的绝对路径" status
```

`deploy.ps1` 里已经内置了放行参数，用脚本跑不会有这个问题。

## 部署到 GitHub Pages

### 最快路径（不用装任何东西）

1. 打开 https://github.com/new
2. **Repository name** 填 `你的用户名.github.io`（例如 `lenglang.github.io`）
3. 可见性选 **Public**，下面三个初始化选项（README / .gitignore / license）**都不要勾**
4. 点 **Create repository**
5. 进入仓库后点 **Add file → Upload files**
6. 打开本目录，**选中里面的全部文件和 `assets` 文件夹**（Ctrl+A），拖进浏览器上传框
   - 注意：拖的是**文件夹里面的内容**，不要把 `lenglang-pages` 文件夹本身拖进去，否则网站会多一层目录打不开
7. 下方点 **Commit changes**
8. 进入 **Settings → Pages**，Source 选 `Deploy from a branch`，Branch 选 `main` + `/ (root)`，**Save**
9. 等 1~2 分钟，访问 `https://你的用户名.github.io`

### 一键脚本（推荐，装了 Git 之后）

右键 `deploy.ps1` → 使用 PowerShell 运行。

- 已装 **GitHub CLI (`gh`)**：脚本会自动建仓、推送、开启 Pages，全程无需手动点选
- 只装了 **Git**：脚本会初始化本地仓库并提交，然后打印出你还需要执行的两条命令

### 方式一：网页上传（最简单，不用装 Git）

1. 登录 GitHub，右上角 **New repository**
2. 仓库名填 `你的用户名.github.io`（例如 `lenglang.github.io`）
   - 这样访问地址就是 `https://你的用户名.github.io`，没有子目录
   - 也可以叫别的名字（如 `website`），那地址就是 `https://用户名.github.io/website/`
3. 可见性选 **Public**（Private 仓库的 Pages 需要付费套餐）
4. 创建后进入仓库 → **Add file → Upload files**，把本目录下**所有文件**（连同 `assets` 文件夹）拖进去
5. 提交后进入 **Settings → Pages**，Source 选 `Deploy from a branch`，Branch 选 `main` + `/ (root)`，保存
6. 等 1~2 分钟，访问 `https://你的用户名.github.io`

> 注意：`assets` 文件夹要一起上传，且上传后目录结构要和本目录一致。

### 方式二：Git 命令行

```bash
cd 本目录
git init
git add .
git commit -m "init: 冷狼电子工作室官网"
git branch -M main
git remote add origin https://github.com/你的用户名/你的用户名.github.io.git
git push -u origin main
```

推送完成后同样去 **Settings → Pages** 选择 `main` 分支根目录。

### 方式三：GitHub Desktop

把本目录添加为本地仓库 → Publish repository → 勾选 Public → 再按方式一的第 5 步开启 Pages。

## 绑定自定义域名（可选）

你已经有 `www.lenglang.xyz`，建议给新站挂一个子域名，比如 `pages.lenglang.xyz`：

1. 仓库根目录新建一个名为 `CNAME` 的文件（无扩展名），内容写一行：
   ```
   pages.lenglang.xyz
   ```
2. 到华为云 DNS 控制台给 `lenglang.xyz` 添加解析记录：
   - 记录类型 `CNAME`，主机记录 `pages`，记录值 `你的用户名.github.io`
3. 回到 **Settings → Pages → Custom domain** 填入 `pages.lenglang.xyz`，勾选 **Enforce HTTPS**
4. 证书签发通常几分钟到几小时

> 一个域名不要同时指到两个地方。GitHub Pages 和现有服务器只能二选一，或者用子域名分开。

## 上线前需要你补的内容

- **演示视频**：把实车演示视频命名为 `demo.mp4` 放进 `assets/video/`，`teaching.html` 里的播放器会自动生效（现在的封面图是车体照片）。
- **教学源码链接**：`teaching.html` 底部「教学源码下载」里标了「链接待补充」的三项，拿到网盘链接后替换掉 `href="#"` 并去掉该行的 `pending` 类。
- **CSDN 教程链接**：`teaching.html` 里的 CSDN 条目目前指向 `https://blog.csdn.net`，建议换成你自己文章的地址。
- **logo**：当前用的是老站 `logo_sharp.png`，需要矢量或高清版本可以换掉 `assets/img/logo.png`。

## 说明

- 全站相对路径引用，放在 `用户名.github.io` 根目录或 `用户名.github.io/仓库名/` 子目录都能正常访问（`404.html` 例外，里面用的是 `/` 开头的绝对路径，仅适用于根目录部署；子目录部署时把开头的 `/` 去掉即可）。
- 已移除保研相关内容，业务聚焦在**嵌入式项目开发**与**ROS2 智能车教具研发**，以及承接外部外包定制。
- 图片已统一压缩到宽 1400px 以内，整站资源约 4 MB。