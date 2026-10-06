#!/bin/bash
### build_gms_images.sh — 构建GMS文件载体镜像并推送到GHCR
### build_gms_images.sh — Build GMS file carrier images and push to GHCR
###
### 用法 / Usage:
###   ./build_gms_images.sh <github-username> [--push]
###
### 示例 / Example:
###   ./build_gms_images.sh myusername          # 仅本地构建 / Build only
###   ./build_gms_images.sh myusername --push   # 构建并推送 / Build and push
###
### 前置条件 / Prerequisites:
###   - Docker 已安装并运行 / Docker installed and running
###   - x86_64/gms_files.tar.gz 和 arm64/gms_files.tar.gz 已存在
###   - 推送需先登录GHCR: echo $GHCR_TOKEN | docker login ghcr.io -u <username> --password-stdin

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USERNAME="${1:-}"
PUSH="${2:-}"

if [ -z "$USERNAME" ]; then
    echo "错误 / Error: 请提供GitHub用户名 / Please provide GitHub username"
    echo "用法 / Usage: $0 <github-username> [--push]"
    exit 1
fi

IMAGE_BASE="ghcr.io/${USERNAME}/androidemu-gms"

echo "=========================================="
echo "GMS镜像构建 / GMS Image Build"
echo "镜像基名 / Image base: $IMAGE_BASE"
echo "=========================================="

### 构建x86_64镜像 / Build x86_64 image
echo ""
echo "[1/2] 构建x86_64镜像 / Building x86_64 image..."
cd "$SCRIPT_DIR/x86_64"

if [ ! -f "gms_files.tar.gz" ]; then
    echo "错误 / Error: x86_64/gms_files.tar.gz 不存在 / not found"
    exit 1
fi

docker build -t "${IMAGE_BASE}:x86_64-latest" .
echo "x86_64镜像构建完成 / x86_64 image built: ${IMAGE_BASE}:x86_64-latest"

### 构建arm64镜像 / Build arm64 image
echo ""
echo "[2/2] 构建arm64镜像 / Building arm64 image..."
cd "$SCRIPT_DIR/arm64"

if [ ! -f "gms_files.tar.gz" ]; then
    echo "错误 / Error: arm64/gms_files.tar.gz 不存在 / not found"
    exit 1
fi

# arm64镜像需要在arm64设备上构建，或用buildx交叉编译
# arm64 image must be built on arm64 device or via buildx
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    docker build -t "${IMAGE_BASE}:arm64-latest" .
    echo "arm64镜像构建完成 / arm64 image built: ${IMAGE_BASE}:arm64-latest"
else
    echo "警告 / Warning: 当前架构为 $ARCH，arm64镜像需在arm64设备上构建"
    echo "  Current arch is $ARCH, arm64 image must be built on arm64 device"
    echo "  或使用buildx: docker buildx build --platform linux/arm64 -t ${IMAGE_BASE}:arm64-latest ."
fi

### 推送 / Push
if [ "$PUSH" = "--push" ]; then
    echo ""
    echo "=========================================="
    echo "推送镜像到GHCR / Pushing to GHCR"
    echo "=========================================="

    echo "推送x86_64 / Pushing x86_64..."
    docker push "${IMAGE_BASE}:x86_64-latest"

    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        echo "推送arm64 / Pushing arm64..."
        docker push "${IMAGE_BASE}:arm64-latest"
    fi

    echo ""
    echo "推送完成 / Push complete!"
    echo "x86_64: ${IMAGE_BASE}:x86_64-latest"
    echo "arm64:  ${IMAGE_BASE}:arm64-latest"
else
    echo ""
    echo "本地构建完成 / Local build complete (未推送 / not pushed)"
    echo "加 --push 参数可推送到GHCR / Add --push to push to GHCR"
fi
