# androidemu-gms

飞牛NAS安卓模拟器（androidemu）GMS服务的文件载体镜像构建仓库。

本仓库仅用于构建和维护GMS镜像，**普通用户无需关注**，直接使用 androidemu FPK 安装包即可。

## 这是什么

安卓模拟器安装GMS（Google Mobile Services）时，需要从独立镜像中提取GMS文件安装到标准版redroid容器。本仓库维护这些镜像的构建文件。

- 安卓容器：始终使用官方标准版 redroid 镜像
- GMS服务：从本仓库构建的独立镜像中提取，安装时自动检测架构

## 镜像地址

| 架构 | 镜像 |
|------|------|
| x86_64 | `ghcr.io/lin1740/androidemu-gms:x86_64-latest` |
| arm64 | `ghcr.io/lin1740/androidemu-gms:arm64-latest` |

镜像内GMS文件位于 `/gms/` 目录，安装时通过 `docker create` + `docker cp` 提取。

## 构建前准备

### x86_64

GMS文件从 `whojk/redroid:12.0.0_mindthegapps` 第三方镜像提取：

```bash
# 拉取第三方镜像
docker pull whojk/redroid:12.0.0_mindthegapps

# 创建临时容器并提取GMS文件
docker create --name gms_extract whojk/redroid:12.0.0_mindthegapps
docker cp gms_extract:/system/priv-app ./gms_system_priv_app
docker cp gms_extract:/system/app ./gms_system_app
docker cp gms_extract:/product/priv-app ./gms_product_priv_app
docker cp gms_extract:/product/app ./gms_product_app
docker cp gms_extract:/system_ext/priv-app ./gms_system_ext_priv_app
docker cp gms_extract:/product/etc ./gms_product_etc
docker cp gms_extract:/product/overlay ./gms_product_overlay
docker cp gms_extract:/product/framework ./gms_product_framework
docker cp gms_extract:/product/lib64 ./gms_product_lib64
docker rm gms_extract

# 打包
mkdir -p gms
mv gms_* gms/
tar -czf gms_files.tar.gz gms/
```

### arm64

GMS文件从 MindTheGapps 官方包提取（注意正确仓库是 `12.1.0-arm64`，不是 `12.0.0-arm64`）：

```bash
# 下载（约230MB，国内建议用代理）
curl -L -o MindTheGapps.zip \
  https://github.com/MindTheGapps/12.1.0-arm64/releases/download/MindTheGapps-12.1.0-arm64-20231025_200924/MindTheGapps-12.1.0-arm64-20231025_200924.zip

# 解压并打包
mkdir -p gms
unzip MindTheGapps.zip -d mtg
# MindTheGapps内部结构为 system/ 子目录，需要调整
tar -czf gms_files.tar.gz -C mtg system/
```

## 构建并推送

### x86_64（在x86机器上）

```bash
cd x86_64/
docker build -t ghcr.io/lin1740/androidemu-gms:x86_64-latest \
  --label "org.opencontainers.image.source=https://github.com/lin1740/androidemu-gms" .
docker push ghcr.io/lin1740/androidemu-gms:x86_64-latest
```

### arm64（在ARM机器上）

注意：ARM设备如果配置了飞牛镜像加速器（docker.fnnas.com），会因认证问题拉不到busybox。Dockerfile使用 `scratch` 空镜像，构建前需提前解压：

```bash
cd arm64/
mkdir -p gms
tar -xzf gms_files.tar.gz -C gms
docker build -t ghcr.io/lin1740/androidemu-gms:arm64-latest .
docker push ghcr.io/lin1740/androidemu-gms:arm64-latest
```

### 一键脚本

```bash
bash build_gms_images.sh
```

## 目录结构

```
├── Dockerfile.x86_64       # x86_64构建文件（基于busybox）
├── Dockerfile.arm64        # arm64构建文件（基于scratch，需提前解压）
├── build_gms_images.sh     # 一键构建推送脚本
├── x86_64/
│   ├── Dockerfile
│   └── gms_files.tar.gz    # 不提交到git（.gitignore）
├── arm64/
│   ├── Dockerfile
│   └── gms_files.tar.gz    # 不提交到git（.gitignore）
└── README.md
```

## 注意事项

1. **GMS是Google专有软件**，本镜像仅供个人学习研究使用，不得用于商业用途
2. `gms_files.tar.gz` 不提交到git（体积过大，190MB+）
3. x86_64的GMS来自第三方redroid镜像，arm64来自MindTheGapps官方包
4. MindTheGapps官方无x86_64预编译包，所以x86_64必须从第三方镜像提取
5. 镜像设为公开后才能匿名pull，设置路径：Package settings → Danger Zone → Change visibility → Public

## 法律声明

GMS（Google Mobile Services）是 Google LLC 的专有软件，受版权法保护。本项目不获得Google授权，仅用于个人学习和研究目的。使用者需自行承担使用风险和法律责任。
