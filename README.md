# GMS 镜像构建与推送指南 / GMS Image Build & Push Guide

## 中文

### 概述

本目录包含GMS（Google Mobile Services）文件载体镜像的构建文件。GMS镜像仅用于存储GMS文件，安装时通过 `docker cp` 提取到标准版redroid容器中，不运行任何服务。

**注意**：GMS是Google公司的专有软件，受版权保护。本项目不直接分发GMS二进制文件，仅供个人学习研究使用。

### 目录结构

```
gms-image/
├── x86_64/
│   ├── Dockerfile
│   └── gms_files.tar.gz    # x86_64架构GMS文件（需自行准备）
├── arm64/
│   ├── Dockerfile
│   └── gms_files.tar.gz    # arm64架构GMS文件（需自行准备）
├── build_gms_images.sh     # 构建脚本
└── README.md               # 本文档
```

### 前置条件

1. Docker 已安装并运行
2. `gms_files.tar.gz` 已放入对应架构目录
   - x86_64：从 `whojk/redroid:12.0.0_mindthegapps` 镜像提取
   - arm64：从 [MindTheGapps](https://github.com/MindTheGapps/12.1.0-arm64/releases) 下载

### 第一步：获取GitHub个人访问令牌（Token）

1. 登录 GitHub，进入 [Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. 点击 **Generate new token (classic)**
3. 填写 Note（如 `androidemu-gms-push`）
4. 勾选权限：
   - `write:packages`（上传包）
   - `read:packages`（读取包）
   - `delete:packages`（删除包，可选）
5. 点击 **Generate token**，复制生成的令牌（只显示一次，请保存好）

### 第二步：登录GHCR

```bash
echo "你的令牌" | docker login ghcr.io -u 你的GitHub用户名 --password-stdin
```

### 第三步：构建镜像

**x86_64架构（在x86_64机器上执行）：**

```bash
cd gms-image/x86_64
docker build -t ghcr.io/你的用户名/androidemu-gms:x86_64-latest .
```

**arm64架构（在arm64机器上执行）：**

```bash
cd gms-image/arm64
docker build -t ghcr.io/你的用户名/androidemu-gms:arm64-latest .
```

**或使用一键构建脚本：**

```bash
cd gms-image
chmod +x build_gms_images.sh
./build_gms_images.sh 你的用户名
```

### 第四步：推送镜像到GHCR

```bash
docker push ghcr.io/你的用户名/androidemu-gms:x86_64-latest
docker push ghcr.io/你的用户名/androidemu-gms:arm64-latest
```

**或一键构建并推送：**

```bash
./build_gms_images.sh 你的用户名 --push
```

### 第五步：设置镜像为公开（可选）

1. 进入 GitHub 仓库页面 → 右侧 **Packages**
2. 点击 `androidemu-gms` 包
3. 进入 **Package settings**
4. 在 **Danger Zone** 中点击 **Change visibility**
5. 选择 **Public** → 确认

> 设为公开后，任何人都可以 `docker pull` 该镜像，无需登录。

### 第六步：更新FPK中的镜像地址

编辑 `app/scripts/install_gms.sh`，修改：

```bash
GMS_IMAGE_BASE="${GMS_IMAGE_BASE:-ghcr.io/你的用户名/androidemu-gms}"
```

重新打包FPK即可。

### 验证镜像

```bash
# 拉取测试
docker pull ghcr.io/你的用户名/androidemu-gms:x86_64-latest

# 创建临时容器并查看文件
docker create --name gms_test ghcr.io/你的用户名/androidemu-gms:x86_64-latest
docker cp gms_test:/gms/. /tmp/gms_test/
docker rm gms_test
ls -la /tmp/gms_test/
```

---

## English

### Overview

This directory contains build files for GMS (Google Mobile Services) file carrier images. The GMS image only stores GMS files, extracted via `docker cp` into the standard redroid container during installation — it does not run any services.

**Note**: GMS is proprietary software of Google LLC, protected by copyright. This project does not directly distribute GMS binaries, for personal research only.

### Directory Structure

```
gms-image/
├── x86_64/
│   ├── Dockerfile
│   └── gms_files.tar.gz    # x86_64 GMS files (prepare yourself)
├── arm64/
│   ├── Dockerfile
│   └── gms_files.tar.gz    # arm64 GMS files (prepare yourself)
├── build_gms_images.sh     # Build script
└── README.md               # This document
```

### Prerequisites

1. Docker installed and running
2. `gms_files.tar.gz` placed in the corresponding architecture directory
   - x86_64: Extract from `whojk/redroid:12.0.0_mindthegapps` image
   - arm64: Download from [MindTheGapps](https://github.com/MindTheGapps/12.1.0-arm64/releases)

### Step 1: Get GitHub Personal Access Token

1. Log in to GitHub, go to [Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. Click **Generate new token (classic)**
3. Enter a Note (e.g., `androidemu-gms-push`)
4. Select scopes:
   - `write:packages` (upload packages)
   - `read:packages` (read packages)
   - `delete:packages` (delete packages, optional)
5. Click **Generate token**, copy the token (shown only once, save it)

### Step 2: Login to GHCR

```bash
echo "YOUR_TOKEN" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### Step 3: Build Images

**x86_64 (run on x86_64 machine):**

```bash
cd gms-image/x86_64
docker build -t ghcr.io/YOUR_USERNAME/androidemu-gms:x86_64-latest .
```

**arm64 (run on arm64 machine):**

```bash
cd gms-image/arm64
docker build -t ghcr.io/YOUR_USERNAME/androidemu-gms:arm64-latest .
```

**Or use the one-click build script:**

```bash
cd gms-image
chmod +x build_gms_images.sh
./build_gms_images.sh YOUR_USERNAME
```

### Step 4: Push Images to GHCR

```bash
docker push ghcr.io/YOUR_USERNAME/androidemu-gms:x86_64-latest
docker push ghcr.io/YOUR_USERNAME/androidemu-gms:arm64-latest
```

**Or build and push in one step:**

```bash
./build_gms_images.sh YOUR_USERNAME --push
```

### Step 5: Make Image Public (Optional)

1. Go to your GitHub repository → **Packages** on the right
2. Click the `androidemu-gms` package
3. Go to **Package settings**
4. In **Danger Zone**, click **Change visibility**
5. Select **Public** → Confirm

> Once public, anyone can `docker pull` the image without login.

### Step 6: Update Image Address in FPK

Edit `app/scripts/install_gms.sh`, modify:

```bash
GMS_IMAGE_BASE="${GMS_IMAGE_BASE:-ghcr.io/YOUR_USERNAME/androidemu-gms}"
```

Repackage the FPK.

### Verify Image

```bash
# Pull test
docker pull ghcr.io/YOUR_USERNAME/androidemu-gms:x86_64-latest

# Create temp container and inspect files
docker create --name gms_test ghcr.io/YOUR_USERNAME/androidemu-gms:x86_64-latest
docker cp gms_test:/gms/. /tmp/gms_test/
docker rm gms_test
ls -la /tmp/gms_test/
```

---

## 法律声明 / Legal Notice

GMS（Google Mobile Services）是 Google LLC 的专有软件，受版权保护。本项目不直接分发GMS二进制文件，构建和使用GMS镜像仅供个人学习研究使用。使用GMS需遵守Google服务条款，相关法律责任由使用者自行承担。

GMS (Google Mobile Services) is proprietary software of Google LLC, protected by copyright. This project does not directly distribute GMS binaries. Building and using GMS images is for personal research only. Use of GMS is subject to Google's Terms of Service, and legal responsibility rests with the user.
