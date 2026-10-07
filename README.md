# androidemu-gms

飞牛NAS安卓模拟器（androidemu）GMS服务的文件载体镜像构建仓库。

本仓库用于构建和维护GMS（Google Mobile Services）文件载体镜像。**普通用户无需关注本仓库的技术内容**，直接使用 androidemu FPK 安装包，在安装向导中选择安装GMS即可。

---

## 给用户的注意事项

> 以下内容面向使用 androidemu 安装包并选择安装GMS服务的普通用户，请务必阅读。

1. **GMS是Google专有服务**：GMS（Google Mobile Services）包含Google Play商店、Google Play服务、Google服务框架等组件，是Google LLC的专有软件，受版权法和相关国际条约保护。

2. **本项目未获Google授权**：本项目及GMS镜像未获得Google的官方授权或MADA认证，GMS的分发和使用可能存在法律风险，仅限个人学习和研究目的使用。

3. **使用GMS需要网络条件**：Google Play商店、账号登录、应用下载、推送通知等功能需要能够正常访问Google服务器的网络环境，否则可能无法登录或下载应用。

4. **安装后初期可能不稳定**：GMS安装完成后，安卓容器会重启，重启后GMS核心组件需要进行首次启动优化（dex编译、服务注册、权限初始化等），此过程通常持续1-3分钟，期间投屏可能出现反复连接/断开，属于正常现象，请耐心等待。

5. **GMS不影响基础功能**：不安装GMS时，安卓模拟器的基础功能（投屏、安装APK、ADB调试、文件管理等）完全正常可用；GMS仅提供Google相关服务，属于可选组件。

6. **数据与隐私**：登录Google账号后，账号数据、应用数据、位置信息等将由Google按照其隐私政策处理。请自行评估隐私风险，本项目不对Google服务的数据处理行为承担责任。

7. **卸载与重装**：卸载androidemu应用时GMS服务会随容器一并移除；重新安装时如需GMS，需在安装向导中再次选择，安装脚本会重新拉取镜像并安装。

## 给用户的法律声明

GMS（Google Mobile Services）是 Google LLC 的专有软件，受中华人民共和国著作权法、相关国际条约及其他适用法律保护。

- 本项目（androidemu及androidemu-gms）不获得Google的任何官方授权、认证或许可
- GMS镜像的构建、分发和使用仅供个人学习、研究和技术交流目的
- 使用者需自行承担使用GMS带来的一切风险，包括但不限于法律风险、账号封禁风险、数据安全风险
- 本项目不对GMS服务的可用性、稳定性、安全性或合法性作出任何担保
- 如因使用GMS导致任何纠纷或损失，由使用者自行承担全部责任
- 商业用途、大规模分发或其他可能侵犯Google权益的行为，必须事先获得Google的正式授权

---

## 这是什么

安卓模拟器安装GMS时，需要从独立镜像中提取GMS文件安装到标准版redroid容器。本仓库维护这些镜像的构建文件和构建脚本。

- **安卓容器**：始终使用官方标准版 redroid 镜像，不替换容器
- **GMS服务**：从本仓库构建的独立镜像中提取，安装时自动检测系统架构（x86_64/arm64）
- **安装包本身**：不包含任何GMS二进制文件，仅在用户主动选择后运行时下载提取

## 镜像地址

| 架构 | 镜像 | 大小 |
|------|------|------|
| x86_64 | `ghcr.io/lin1740/androidemu-gms:x86_64-1.0.0` | ~698MB |
| arm64 | `ghcr.io/lin1740/androidemu-gms:arm64-1.0.0` | ~563MB |

- 镜像采用固定版本号（如1.0.0），与androidemu FPK安装包版本对应，可复现、可回滚
- 镜像内GMS文件位于 `/gms/` 目录，安装时通过 `docker create` + `docker export` 提取到安卓容器的系统分区
- x86_64版本GMS文件从第三方redroid衍生镜像（whojk/redroid:12.0.0_mindthegapps）提取
- arm64版本GMS文件从MindTheGapps 12.1.0-arm64官方发布包提取

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
docker build -t ghcr.io/lin1740/androidemu-gms:x86_64-1.0.0 \
  --label "org.opencontainers.image.source=https://github.com/lin1740/androidemu-gms" .
docker push ghcr.io/lin1740/androidemu-gms:x86_64-1.0.0
```

### arm64（在ARM机器上）

注意：ARM设备如果配置了飞牛镜像加速器（docker.fnnas.com），会因认证问题拉不到busybox。Dockerfile使用 `scratch` 空镜像，构建前需提前解压：

```bash
cd arm64/
mkdir -p gms
tar -xzf gms_files.tar.gz -C gms
docker build -t ghcr.io/lin1740/androidemu-gms:arm64-1.0.0 .
docker push ghcr.io/lin1740/androidemu-gms:arm64-1.0.0
```

### 一键脚本

```bash
bash build_gms_images.sh
```

## 目录结构

```
├── build_gms_images.sh     # 一键构建推送脚本
├── x86_64/
│   ├── Dockerfile
│   └── gms_files.tar.gz    # 不提交到git（.gitignore，体积过大）
├── arm64/
│   ├── Dockerfile
│   └── gms_files.tar.gz    # 不提交到git（.gitignore，体积过大）
└── README.md
```

---

## 给发布者与维护者的注意事项

> 以下内容面向维护本仓库、构建GMS镜像、或将本项目集成到其他发行版的维护者和发布者。

1. **GMS文件来源合规性**：
   - x86_64版本GMS文件提取自第三方redroid衍生镜像（whojk/redroid:12.0.0_mindthegapps），该镜像本身的GMS来源和合规性需自行评估
   - arm64版本GMS文件提取自MindTheGapps官方发布包，MindTheGapps的分发许可需遵守其项目规定
   - 重新构建镜像时，应记录GMS文件的来源、版本、提取时间，便于追溯

2. **版本管理**：
   - 镜像标签采用固定版本号（如1.0.0），不使用latest浮动标签
   - 每次GMS内容变更（更换来源、增删组件、更新版本）应发布新版本号，并在androidemu安装包中同步更新引用的版本号
   - 旧版本镜像应保留，便于用户回滚和问题定位

3. **镜像公开设置**：
   - 镜像需设为公开（Public）才能匿名拉取，设置路径：Package settings → Danger Zone → Change visibility → Public
   - 公开镜像意味着任何人都可以拉取和使用，需确保镜像内容不包含敏感信息、密钥、个人数据

4. **构建环境注意事项**：
   - `gms_files.tar.gz` 不提交到git（体积过大，190MB+），通过 `.gitignore` 排除
   - x86_64和arm64需在对应架构的机器上构建，Dockerfile使用 `scratch` 空镜像以减小体积
   - ARM设备如配置了飞牛镜像加速器，构建时可能因认证问题失败，需临时调整或在其他环境构建

5. **安装脚本兼容性**：
   - androidemu安装包中的 `install_gms.sh` 引用固定版本号的镜像，更新镜像版本后必须同步修改安装脚本
   - 安装脚本需支持多源fallback（国内镜像优先，GHCR官方兜底），应对国内网络环境
   - GMS安装成功后应自动清理镜像文件，避免占用用户磁盘空间

6. **与安卓容器的解耦**：
   - GMS镜像仅作为文件载体，不替换安卓容器镜像
   - 安卓容器始终使用官方标准版redroid，确保GPU模式、硬件加速等功能正常
   - GMS安装失败不应导致安卓容器无法启动，需有降级和回滚机制

## 给发布者与维护者的法律声明

1. **分发责任**：维护者和发布者对其构建、分发的GMS镜像内容承担法律责任，需确保镜像内容不侵犯第三方知识产权。

2. **Google专有软件声明**：GMS是Google的专有软件，其商业化分发和使用需获得Google正式授权。维护者在分发包含GMS的镜像或安装包时，应在所有分发渠道（包括但不限于GitHub、Docker Hub、应用商店、论坛）显著标注GMS的专有软件属性，并明确说明本项目仅提供技术集成方案，不代表获得Google授权，也不主张对GMS的任何知识产权。

3. **禁止误导性宣传**：不得声称本项目获得Google授权、认证或与Google有任何官方合作关系；不得使用Google的商标、Logo或品牌元素进行宣传。

4. **用户告知义务**：将本项目集成到其他发行版时，必须保留并向用户展示GMS相关的法律声明和风险提示，不得隐瞒GMS的专有软件属性和法律风险。

5. **版本追溯**：建议保留每个版本GMS镜像的构建记录、文件来源、校验值（SHA256），便于在出现法律争议时提供证据。

---

## 二次开发与商用声明

### 二次开发

欢迎基于本项目进行二次开发和技术研究，但需遵守以下条件：

1. 保留原项目的开源许可（如有）和法律声明，不得删除或修改GMS相关的免责声明
2. 二次开发后的版本如进行公开发布，需同样显著标注GMS的专有软件属性和使用限制
3. 不得将本项目或其衍生版本用于任何违反法律法规的用途
4. 建议将二次开发的成果以开源方式分享，回馈社区

### 什么是商用

简单来说，**只要涉及金钱利益或企业/组织经营用途，即属于商用**。具体界定如下：

**明确属于商用的情形：**
1. 将包含GMS的软件作为付费产品销售、订阅或按次收费
2. 对外提供云手机服务，按时间、设备数或功能收取费用
3. 企业、公司、个体工商户等经营主体内部部署使用（即使不直接收费，用于业务运营亦算商用）
4. 将包含GMS的系统预装到设备中一并销售（如NAS、机顶盒、开发板等硬件产品）
5. 通过软件或GMS服务进行广告投放、流量分成、数据变现等营利活动
6. 为客户提供定制开发、技术服务，并将包含GMS的软件作为交付物的一部分

**一般不属于商用的情形：**
1. 自然人个人学习、研究、技术探索目的的使用
2. 自然人个人家庭日常非经营性使用
3. 纯开源技术交流，不涉及任何费用收取

**灰色地带（存在争议，建议谨慎评估）：**
1. 学校、非盈利组织内部使用——部分授权协议视为非商用，部分不视为，需具体评估
2. 小范围免费分享给朋友使用——一般不视为商用，但分发规模较大时可能存在风险

> GMS是Google的专有软件，其分发、安装和使用受Google相关服务条款及适用法律法规约束。本项目仅提供GMS文件的提取、打包和集成技术方案，不主张对GMS的任何知识产权，也不代表获得Google授权。使用者在安装和使用GMS前，应自行评估法律风险并遵守Google的相关条款；商业用途或大规模分发需获得Google的正式授权（如MADA协议）。

### 商用限制

**本项目及GMS镜像禁止直接用于商业用途**，包括但不限于：

1. 将包含GMS的安卓模拟器作为付费产品销售或订阅
2. 在商业产品中集成GMS服务并向用户收取费用
3. 利用GMS服务进行广告投放、数据变现等商业活动
4. 大规模分发预装GMS的设备或系统镜像

如需商业使用，必须：
1. 获得Google的正式授权（如MADA协议）
2. 自行评估并承担所有法律风险和合规责任

### 免责

本项目按"现状"提供，不对任何因使用、复制、修改、分发本项目而导致的直接或间接损失承担责任。使用者和二次开发者需自行评估风险并承担全部责任。
