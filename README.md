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

## 镜像清单（以 ghcr 实际 tag 为准）

镜像地址：`ghcr.io/lin1740/androidemu-gms:<tag>`

| tag | 状态 | 来源 |
|-----|------|------|
| `10-arm64` | ✅ | MindTheGapps 10.0.0-arm64-20230922 |
| `10-x86_64` | ✅ | OpenGApps x86_**64** 10.0 **pico** 20200918（AndroidFileHost 存档） |
| `11-arm64` | ✅ | MindTheGapps 11.0.0-arm64-20230922 |
| `11-x86_64` | ✅ | OpenGApps x86_64 11.0 stock 20220503 |
| `arm64`（旧 tag） | ✅ | Android 12：MindTheGapps 12.1.0-arm64-20231025 |
| `x86_64`（旧 tag） | ✅ | Android 12：MindTheGapps 12.1.0-x86_64-20231025 |
| `13-arm64` | ✅ | MindTheGapps 13.0.0-arm64-20231025 |
| `13-x86_64` | ✅ | MindTheGapps 13.0.0-x86_64-20231025 |
| `14-arm64` | ✅ | MindTheGapps 14.0.0-arm64-20250203 |
| `14-x86_64` | ✅ | MindTheGapps 14.0.0-x86_64-20250202（MustardChef 构建） |
| `15-arm64` | ✅ | MindTheGapps 15.0.0-arm64-20260915 |
| `15-x86_64` | ✅ | **自行组装**：GitLab `vendor_gapps` `vic` 分支（官方无成品发布） |
| `16-arm64` | ✅ | MindTheGapps 16.0.0-arm64-20261023 |
| `16-x86_64` | ✅ | **自行组装**：GitLab `vendor_gapps` `baklava` 分支（官方无成品发布） |

**tag 规则**：`<主版本>-<架构>`（如 `15-x86_64`）。

**Android 12 的历史兼容**：额外维护无版本前缀的旧 tag `x86_64` / `arm64`，供 3.9.1/3.9.2 时期的 `install_gms.sh` 使用。

**未提供**：Android 8.1 / 9（无需求）；Android 17（尚未验证）。

> ⚠️ 关于 Android 10 的 x86_64：MindTheGapps 官方**从未构建过**该组合（其 `qoppa` 分支只有 `x86/`，没有 `x86_64/`）。只能用 OpenGApps 的 x86_64 包，且官方 20220503 版本部分镜像长期不可用，本仓库用的是 AndroidFileHost 存档的 20200918 pico 版。

## 关键结论：哪些组合"官方本来就没有"

| 组合 | 官方是否有 | 说明 |
|------|-----------|------|
| 10 / x86_64 | ❌ | MindTheGapps 分支只有 x86（32 位）→ 用 OpenGApps |
| 11 / x86_64 | ❌ | 同上 → 用 OpenGApps |
| 12 / x86_64 | ✅ | MindTheGapps 官方最后支持的 x86_64 之一 |
| 13 / x86_64 | ✅ | 官方 x86_64 的终点（14+ 官方只做 arm/arm64） |
| 14 / x86_64 | ❌ 官方 | 社区（MustardChef）基于官方源码构建 |
| 15 / x86_64 | ❌ 官方 | 源文件在 GitLab `vic` 分支，**可自行组装** |
| 16 / x86_64 | ❌ 官方 | 源文件在 GitLab `baklava` 分支，**可自行组装** |

**所以 15/16 的 x86_64 并非"不存在"，而是官方从未发布成品。** 源文件（GmsCore / Phonesky / Velvet / SetupWizard 等真 APK）都在 GitLab 仓库里，按下面的方法可以自己产出。

## 载体镜像的格式

所有镜像均为：

```dockerfile
FROM scratch
COPY gms/ /gms/
```

容器内结构：

```
/gms/system/product/{app,etc,framework,lib64,priv-app,overlay}/
/gms/system/system_ext/{etc,priv-app}/
```

`install_gms.sh` 用 `docker create` + `docker export` 提取 `/gms/system/...`，拷进 redroid 容器的系统分区（容器本身始终用官方 redroid 镜像，**不替换系统镜像**）。

## 构建与推送

```bash
echo $GHCR_TOKEN | docker login ghcr.io -u lin1740 --password-stdin
./build_gms_images.sh lin1740 --push              # 全部（按本仓库内的目录）
./build_gms_images.sh lin1740 --push --only 11    # 只构建 Android 11
```

- x86_64 载体在 x86_64 宿主构建；arm64 载体在 arm64 宿主构建（或 `docker buildx build --platform linux/arm64`）。
- 仓库内的 `10/ 11/ 12/` 目录保存对应版本的 `gms_files.tar.gz`，脚本据此构建。
- 13~16 的镜像由各自源文件直接组装后推送（未在仓库内保留中间 tar，见下方"新增版本"）。

## 新增一个版本的流程

### A. arm64（官方有成品）

1. 去 GitHub `MindTheGapps/<版本>-arm64` 的 Releases 下载 `MindTheGapps-*.zip`；
2. 解压：ZIP 内 `system/` 目录即目标结构，重组为 `gms/system/...`；
3. `FROM scratch` + `COPY gms/ /gms/` 构建，打 tag `<版本>-arm64`，推送。

### B. x86_64 —— 官方有成品（仅 12 / 13）

同上，用 `MindTheGapps/<版本>-x86_64` 的 release。ZIP 内是 `system/product/...`、`system/system_ext/...`，直接映射到 `gms/system/`。

### C. x86_64 —— 官方无成品（14 / 15 / 16，可自行组装）

源文件在 MindTheGapps 官方 GitLab 仓库：

```
https://gitlab.com/MindTheGapps/vendor_gapps
分支名 = Android 代号：
  qoppa=10  rho=11  sigma=12  tau=13  upsilon=14  vic=15  baklava=16  cinnamonbun=17
```

步骤：

1. 取 `common/proprietary/` 与 `x86_64/proprietary/` 两棵目录树（GitLab API 或 `git clone` + **必须先装 git-lfs**，否则大 APK 只是指针）；
2. 合并：`<分支>/common/proprietary/*` 和 `<分支>/x86_64/proprietary/*` → `gms/system/`（去掉 `proprietary/` 这一层）；
3. 校验核心：`GmsCore.apk`（Play 服务）、`Phonesky.apk`（Play 商店）、`GoogleServicesFramework.apk`、`SetupWizard.apk`、`Velvet.apk`；
4. `FROM scratch` + `COPY gms/ /gms/` 构建，打 tag `<版本>-x86_64`，推送。

> 注意：`overlay/` 目录是需要 aapt 编译的资源覆盖（默认设置项），**未包含在上述组装中**，不影响 Play 商店核心功能。如需完全一致，用官方构建镜像 `registry.gitlab.com/mindthegapps/vendor_gapps:latest` 跑 `make gapps_x86_64`。

### D. x86_64 —— OpenGApps 路线（10 / 11）

1. 从 OpenGApps 下载 `open_gapps-x86_64-<版本>-<变体>-<日期>.zip`（注意文件名用**连字符**，不是下划线；pico/nano 体积最小，已含 GmsCore + Phonesky + GSF）；
2. 解压后 `Core/*.tar.lz` 是 **lzip** 压缩的 tar（需 `lzip` 工具，不是 lzma/gzip）；
3. 逐个解出，合并 `priv-app` / `app` / `etc` / `framework` / `lib` / `lib64` 到 `gms/system/`；
4. 同上构建推送。

> OpenGApps 官方已停止维护，SourceForge 镜像近年频繁故障；可用的替代源包括 AndroidFileHost 存档。

## 排障备忘（血泪经验）

- **GitLab API 有严格的速率限制**：批量拉几十个文件会 429。降到 1-2 并发、每个文件之间 sleep 2-5 秒、失败指数退避。
- **GitLab API `files/<path>/raw` 不支持 Range**：只能整体下载单个文件（约 1MB/s），不能分段。
- **`git clone` 不装 git-lfs 会拿到指针文件**（几百字节），APK 全部无效。先 `apt install git-lfs`。
- **SourceForge 的重定向会丢 Range 头**：`curl -r` 分段下载会卡死（每次都从 0 开始或被拒）。此外 SF 会整站故障（所有镜像 302 到一个挂掉的后端）。
- **GitHub release 大文件直连很慢**，可用 `https://ghfast.top/<原始URL>` 前缀加速（gh-proxy.com 已不可用）。
- **`FROM scratch` 镜像没有 shell**：`docker create` 需加 `--entrypoint /bin/true`；`docker export` 或 `docker save` 后解析 `blobs/sha256/` 可查看内容。

## 致谢

基于 [MindTheGapps](https://gitlab.com/MindTheGapps/vendor_gapps)（GMS 打包）与 [OpenGApps](https://opengapps.org)（Android 10/11 x86_64）构建。
