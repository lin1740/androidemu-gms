#!/bin/bash
### build_gms_images.sh — 多版本 GMS 载体镜像构建与推送（Android 10~16）
###
### 目录即版本：gms-image/<安卓主版本>/<架构>/gms_files.tar.gz
###   → 构建并推送 ghcr.io/lin1740/androidemu-gms:<主版本>-<架构>
###   例：12/x86_64 → ghcr.io/lin1740/androidemu-gms:12-x86_64
###
### Android 12 额外维护旧版 tag（:x86_64 / :arm64，与 3.9.1/3.9.2 的
### install_gms.sh 历史行为兼容）。
###
### 用法：
###   ./build_gms_images.sh <github用户名> [--push] [--only <主版本>]
### 示例：
###   ./build_gms_images.sh lin1740 --push            # 构建并推送全部
###   ./build_gms_images.sh lin1740 --push --only 11  # 只构建 Android 11
###
### 前置：echo $GHCR_TOKEN | docker login ghcr.io -u <用户名> --password-stdin
### 架构：x86_64 载体在 x86_64 宿主构建；arm64 载体在 arm64 宿主构建
###       （或用 docker buildx build --platform linux/arm64）

set +e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USERNAME="${1:-}"; shift || true
PUSH=0; ONLY=""
while [ -n "$1" ]; do
    case "$1" in
        --push) PUSH=1 ;;
        --only) shift; ONLY="$1" ;;
    esac
    shift
done
[ -z "$USERNAME" ] && { echo "用法: $0 <github用户名> [--push] [--only <主版本>]"; exit 1; }
IMAGE_BASE="ghcr.io/${USERNAME}/androidemu-gms"
HOST_ARCH=$(uname -m)

echo "GMS 多版本载体构建 → ${IMAGE_BASE}"
echo "宿主架构: ${HOST_ARCH}（构建对应架构的载体；跨架构用 buildx）"

built=0; skipped=0; failed=0
for VER_DIR in "$SCRIPT_DIR"/*/; do
    VER=$(basename "$VER_DIR")
    case "$VER" in 10|11|12|13|14|15|16) ;; *) continue ;; esac
    [ -n "$ONLY" ] && [ "$VER" != "$ONLY" ] && continue
    for ARCH_DIR in "$VER_DIR"/*/; do
        ARCH=$(basename "$ARCH_DIR")
        [ -f "$ARCH_DIR/gms_files.tar.gz" ] || { continue; }
        TAG="${VER}-${ARCH}"
        echo "------------------------------------------"
        echo "构建 ${IMAGE_BASE}:${TAG}"
        cd "$ARCH_DIR" || continue
        [ -d gms ] || tar -xzf gms_files.tar.gz -C . 2>/dev/null
        # 归档内为 system/... 时需放入 gms/ 下
        if [ -d system ] && [ ! -d gms ]; then mkdir -p gms && mv system gms/; fi
        docker build -q -t "${IMAGE_BASE}:${TAG}" . >/dev/null 2>&1 \
            && { echo "  ✅ 构建完成"; built=$((built+1)); } \
            || { echo "  ✗ 构建失败"; failed=$((failed+1)); continue; }
        if [ "$PUSH" = "1" ]; then
            if docker push "${IMAGE_BASE}:${TAG}" >/dev/null 2>&1; then
                echo "  ✅ 已推送 ${IMAGE_BASE}:${TAG}"
            else
                echo "  ✗ 推送失败"; failed=$((failed+1))
            fi
        fi
        # Android 12 额外维护旧版 tag（兼容 3.9.x install_gms.sh 历史行为）
        if [ "$VER" = "12" ]; then
            LEGACY="$ARCH"
            docker tag "${IMAGE_BASE}:${TAG}" "${IMAGE_BASE}:${LEGACY}" 2>/dev/null
            [ "$PUSH" = "1" ] && docker push "${IMAGE_BASE}:${LEGACY}" >/dev/null 2>&1 \
                && echo "  ✅ 旧版 tag 同步: ${IMAGE_BASE}:${LEGACY}"
        fi
        cd "$SCRIPT_DIR"
    done
done

echo "=========================================="
echo "完成：成功 $built，失败 $failed"
[ "$PUSH" != "1" ] && echo "（未推送；加 --push 推送到 GHCR）"
