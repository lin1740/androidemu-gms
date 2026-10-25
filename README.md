# androidemu-gms（多版本）

飞牛 NAS 安卓模拟器（androidemu）GMS 服务的文件载体镜像构建仓库 —— **按 Android 版本 × 架构 分门别类**。

> **普通用户无需关注本仓库**：直接使用 androidemu FPK 安装包，在安装向导中选择安卓系统版本与是否安装 GMS 即可，安装脚本自动拉取对应载体镜像。

## 给用户的法律与使用须知

1. **GMS 是 Google 专有服务**（Play 商店、Play 服务、服务框架），受版权法保护；本项目未获 Google 授权（MADA），分发与使用存在法律风险，**仅供个人学习研究**。
2. GMS 功能需要能访问 Google 服务器的网络环境。
3. 安装后 GMS 组件首次初始化（dex 编译、服务注册）约 1-3 分钟，期间投屏可能反复连接/断开，属正常现象。
4. 不安装 GMS 时基础功能（投屏、APK、ADB、文件管理）完全正常。
5. 卸载 androidemu 时 GMS 随容器移除；重装时在向导中重新选择即可。
6. 商业用途或大规模分发必须事先获得 Google 正式授权。

## 目录结构（目录即版本）

```
gms-image/<安卓主版本>/<架构>/gms_files.tar.gz
```

| 目录 | 载体 tag | 来源 | 状态 |
|------|----------|------|------|
| `10/arm64/` | `10-arm64` | MindTheGapps-10.0.0-arm64-20230922 | ✅ 已构建 |
| `11/x86_64/` | `11-x86_64` | OpenGApps x86_64 11.0 stock 20220503 | ✅ 已推送 |
| `12/arm64/` | `arm64`（旧版 tag）+ `12-arm64` | MindTheGapps-12.1.0-arm64-20231025 | ✅ 已推送 |
| `12/x86_64/` | `x86_64`（旧版 tag）+ `12-x86_64` | MindTheGapps-12.1.0-x86_64-20231025（官方源重建，替代早期 whojk 第三方提取） | ✅ 已推送 |
| `13/x86_64/` | `13-x86_64` | MindTheGapps-13.0.0-x86_64-20231025 | ⏳ 货源确认，下载中 |
| `13/arm64/` | `13-arm64` | MindTheGapps-13.0.0-arm64-20231025 | ⏳ 货源确认，下载中 |
| `10/x86_64/` | `10-x86_64` | OpenGApps x86_64 10.0 stock 20220503 | ⏳ 货源确认，下载中 |
| `11/arm64/` | `11-arm64` | MindTheGapps-11.0.0-arm64-20230922 | ⏳ 货源确认，下载中 |
| `14/arm64/` | `14-arm64` | MindTheGapps-14.0.0-arm64-20250203 | ⏳ 货源确认，下载中 |
| `15/arm64/` | `15-arm64` | MindTheGapps-15.0.0-arm64-20260915 | ⏳ 货源确认，下载中 |
| `16/arm64/` | `16-arm64` | MindTheGapps-16.0.0-arm64-20261023 | ⏳ 货源确认，下载中 |
| `14/x86_64/` | `14-x86_64` | BlissOS16 gapps ISO（2.4GB）提取 | 📋 待做 |
| `10/x86_64/` | `10-x86_64` | OpenGApps x86_64 10.0 stock | ⏳ 货源确认，下载中 |
| `15/x86_64/`、`16/x86_64/` | — | **社区无 x86_64 货源**（全行业缺口） | ❌ 暂无 |

**tag 规则**：`<主版本>-<架构>`（如 `13-x86_64`）；**Android 12 额外维护旧版 tag** `x86_64` / `arm64`（与 3.9.1/3.9.2 的 `install_gms.sh` 历史行为兼容）。

## 构建与推送

```bash
echo $GHCR_TOKEN | docker login ghcr.io -u lin1740 --password-stdin
./build_gms_images.sh lin1740 --push              # 全部
./build_gms_images.sh lin1740 --push --only 11    # 只构建 Android 11
```

- x86_64 载体在 x86_64 宿主构建；arm64 载体在 arm64 宿主构建（或 buildx `--platform linux/arm64`）。
- 构建时自动从 `gms_files.tar.gz` 解出 `gms/`，Dockerfile 均为 `FROM scratch`（载体不含 OS，仅 GMS 文件）。

## 新增一个版本的流程

1. 获取该版本对应架构的 GMS 文件源：
   - **arm64**：MindTheGapps 官方 release（GitHub `MindTheGapps/<版本>-arm64`，仓库名即版本号）；
   - **x86_64**：MindTheGapps x86_64（10~13 有官方）/ OpenGApps stock（10/11，SourceForge）/ BlissOS gapps ISO 提取（10~14）。
2. 解压并整理为 `gms/system/{priv-app,app,etc,framework,lib64,...}` 结构，打包 `gms_files.tar.gz`；
3. 放入 `<版本>/<架构>/`，写 Dockerfile（`FROM scratch` + `COPY gms/ /gms/`）；
4. `./build_gms_images.sh <用户名> --push --only <主版本>`。

## 载体镜像的用途

androidemu 安装 GMS 时：`docker create` + `docker export` 从载体镜像提取 `/gms/system/...` 的 GMS 文件，装入标准版 redroid 容器的系统分区（安卓容器始终使用官方 redroid 镜像，不替换）。3.9.2 起 `install_gms.sh` 按「安卓版本-架构」选择载体 tag；Android 12 回退旧版 tag。
