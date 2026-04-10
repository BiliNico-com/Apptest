# 91Download 爬虫 API 文档

本文档整理自 `91DownWeb_src/_src/lib/__init__.py`，用于 Flutter 版本爬虫实现参考。

---

## 配置常量

### 列表类型配置 (Original CMS)

```python
LIST_TYPES = {
    "list":  "list-{page}.htm",       # 视频/Video list
    "top7":  "top7_list-{page}.htm",  # 周榜/Weekly top
    "top":   "top_list-{page}.htm",   # 月榜/Monthly top
    "5min":  "5min_list-{page}.htm",  # 5分钟+/5min+
    "long":  "long_list-{page}.htm",  # 10分钟+/10min+
}
```

### 列表类型配置 (Porn91 CMS)

```python
LIST_TYPES_V2 = {
    "list":   "v.php?next=watch&page={page}",            # 视频（首页）
    "ori":    "v.php?category=ori&viewtype=basic&page={page}",      # 91原创
    "hot":    "v.php?category=hot&viewtype=basic&page={page}",      # 当前最热
    "top":    "v.php?category=top&viewtype=basic&page={page}",      # 每月最热
    "topm":   "v.php?category=top&m=-1&viewtype=basic&page={page}", # 本月最热
    "long":   "v.php?category=long&viewtype=basic&page={page}",     # 20分钟以上
    "longer": "v.php?category=longer&viewtype=basic&page={page}",  # 10分钟以上
    "rf":     "v.php?category=rf&viewtype=basic&page={page}",      # 本月收藏
    "tf":     "v.php?category=tf&viewtype=basic&page={page}",      # 最近加精
    "hd":     "v.php?category=hd&viewtype=basic&page={page}",      # 高清
    "mf":     "v.php?category=mf&viewtype=basic&page={page}",     # 本月讨论
    "md":     "v.php?category=md&viewtype=basic&page={page}",     # 收藏最多
}
```

### 中文别名映射

```python
# Original CMS
LIST_TYPE_ALIASES = {
    "视频": "list", "周榜": "top7", "月榜": "top",
    "5分钟+": "5min", "10分钟+": "long",
}

# Porn91 CMS
LIST_TYPE_ALIASES_V2 = {
    "视频": "list", "91原创": "ori", "当前最热": "hot",
    "本月最热": "topm", "每月最热": "top",
    "10分钟以上": "longer", "20分钟以上": "long",
    "本月收藏": "rf", "最近加精": "tf",
    "高清": "hd", "本月讨论": "mf", "收藏最多": "md",
}
```

### 默认请求头

```python
DEFAULT_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
    "Referer": "",  # 运行时根据域名动态设置
}
```

### 广告域名黑名单

```python
_AD_DOMAINS = [
    'kwai.net', 'kuaishou',  # 快手广告
    '51dplus.cn',             # 广告跳转
]
```

---

## 公开方法

### CrawlerCore 类（爬虫核心）

#### `CrawlerCore.__init__`

- **功能**：初始化爬虫核心
- **参数**：
  - `config: dict` - 配置字典（包含 site, proxy, output_dir 等）
  - `base_url: str` - 站点基础 URL
  - `log_callback` - 日志回调
  - `progress_callback` - 下载进度回调
  - `info_callback` - 视频信息回调（封面等）
  - `confirm_callback` - 确认弹窗回调
  - `merge_progress_callback` - 合并进度回调
  - `speed_callback` - 实时速度回调
- **关键逻辑**：
  1. 设置 `Referer` 为站点域名
  2. 检测站点类型（`original` 或 `porn91`）
  3. Porn91 站点设置语言 Cookie: `language=cn_CN`
  4. 初始化 SQLite 数据库防重复记录

---

### `download_single`

- **功能**：下载单个视频
- **参数**：
  - `url: str` - 视频页面 URL
  - `title: str` - 视频标题
  - `video_id: str` - 视频 ID（用于防重复）
  - `upload_date: str` - 上传日期 YYYY-MM-DD
  - `output_dir: Path` - 输出目录
  - `author: str` - 作者名
- **返回**：`bool` - 是否成功
- **关键逻辑**：
  1. 防重复检查（查询 SQLite 历史记录）
  2. 调用 `_extract_m3u8_from_html()` 获取视频地址
  3. 判断是 m3u8 流还是直接 MP4
  4. m3u8 用 `TSDownloader` 并发下载，MP4 直接流式下载
  5. 按上传日期分类存储到 `downloads/{日期}/{标题}.mp4`

---

### `crawl_batch`

- **功能**：批量爬取指定页码范围
- **参数**：
  - `page_start: int` - 起始页
  - `page_end: int` - 结束页
  - `list_type: str` - 列表类型（如 "list", "hot", "top"）
- **返回**：`{'success': int, 'skipped': int}` - 新下载数/跳过数
- **关键逻辑**：
  1. 预扫描阶段：收集所有视频，预检已下载状态
  2. 逐个下载，每视频间隔 2 秒
  3. 支持暂停/恢复/停止

---

### `crawl_search`

- **功能**：按关键词搜索并批量下载
- **参数**：
  - `keyword: str` - 搜索关键词
  - `page_start: int` - 起始页
  - `page_end: int` - 结束页
  - `sort: str` - 排序方式（"new" 等）
- **返回**：`{'success': int, 'skipped': int}`
- **关键逻辑**：
  - Porn91 搜索只支持第 1 页（AVS CMS 限制）
  - Original CMS 支持多页分页

---

### `crawl_authors`

- **功能**：爬取指定作者的所有视频
- **参数**：
  - `authors: List[dict]` - 作者列表，每个含 `name`, `param`, `url`
  - `page_start: int` - 起始页
  - `page_end: int` - 结束页
- **返回**：`{'success': int, 'skipped': int}`
- **关键逻辑**：
  1. 每个作者视频存到 `downloads/{日期}/{作者ID}/` 目录
  2. 有失败视频自动弹出重试提示
  3. 全部完成后询问是否继续下一作者

---

### `search_authors`

- **功能**：搜索作者
- **参数**：`keyword: str`
- **返回**：`List[{'name', 'param', 'url', 'count'}]`

---

### `get_author_page_count`

- **功能**：获取作者视频总页数
- **参数**：`author_url: str`
- **返回**：`int` - 总页数

---

### 控制方法

| 方法 | 功能 |
|------|------|
| `stop()` | 停止爬虫 |
| `pause()` | 暂停爬虫 |
| `resume()` | 恢复爬虫 |
| `wait_if_paused()` | 等待恢复（线程安全） |
| `clear_queue()` | 清空下载队列 |
| `flush_history()` | 刷新历史记录到磁盘 |

---

## 正则表达式

### 视频列表解析（Original CMS）

```python
# 匹配带封面图的视频链接
r'<a[^>]*href="(video-(\d+)\.htm)"[^>]*>\s*<div[^>]*style="[^"]*background-image:\s*url\(["\']([^"\']+)["\']\)[^"]*"\s*title=\s*"([^"]*)"'

# 匹配搜索结果中的视频（h4 格式）
r'<h4>\s*<a[^>]*href="(video-(\d+)\.htm)"[^>]*>([^<]+)</a>'
```

### 视频列表解析（Porn91 CMS）

```python
# 容器匹配：确保只取 col-lg-3 内的视频（过滤推荐/广告）
r'<div[^>]*class="[^"]*col-lg-3[^"]*"[^>]*>\s*<div[^>]*class="[^"]*well[^"]*well-sm[^"]*"'

# viewkey 链接（viewkey 可能是纯数字或十六进制）
r'<a[^>]*href="([^"]*viewkey=([a-zA-Z0-9]+)[^"]*)"[^>]*>'

# 封面 ID 从 playvthumb_XXXXXX 提取
r'playvthumb_(\d+)'

# 标题提取
r'class="video-title[^"]*"[^>]*>([^<]+)'

# 作者提取
r'作者[：:]\s*</span>\s*([^<\n]+)'
```

### 视频 ID 提取

```python
# Porn91 风格
r'viewkey=([a-f0-9]+)'      # viewkey 格式
r'playvthumb_(\d+)'          # 备用格式

# Original 风格
r'video-(\d+)\.htm'
```

### 视频地址提取

```python
# strencode2() URL 编码的 <source> 标签（Porn91）
r'strencode2\(["\'](%[0-9a-fA-F]{2}[^"\']+)["\']\)'

# 解码后提取 src 属性
r'src=["\'](https?://[^"\']+\.mp4[^"\']*)["\']'

# <source> 标签
r'<source[^>]+src="([^"]+\.m3u8[^"]*)"'

# 直接搜索 m3u8 URL
r'https?://[^\s"\'<>]+\.m3u8[^\s"\'<>]*'

# JavaScript 变量
r'(?:video_url|sourceUrl|videoUrl|m3u8_url|file)\s*=\s*["\']([^"\']+\.m3u8[^"\']*)["\']'
```

### 标题/日期/作者提取

```python
# Porn91 标题（从 h4.login_register_header）
r'<h4[^>]*class="login_register_header"[^>]*>(.*?)</h4>'

# Porn91 上传日期
r'添加时间[：:]\s*</span>\s*([^<]+)'

# Porn91 作者（多种策略）
r'(?:作者|Added\s*?by)[：:]?\s*</span>\s*([^<\s][^<]*)'
r'<span class="title-yakov">\s*<a[^>]*href="[^"]*uprofile\.php[^>]*>\s*<span class="title">([^<]+)</span>'

# Original 日期
r'日期[：:]\s*([^<]+)'

# Original 作者
r'作者[：:]\s*<a[^>]*>([^<]+)</a>'
```

### 时间解析

```python
r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})'  # YYYY-MM-DD
r'(\d+)\s*分钟前'
r'(\d+)\s*小时前'
r'(\d+)\s*天前'
r'(\d+)\s*周前'
r'(\d+)\s*个?月前'
r'(\d+)\s*年?前'
```

### M3U8 解析

```python
# Master playlist 分辨率匹配
r'#EXT-X-STREAM-INF:.*?RESOLUTION=(\d+)x(\d+).*?\n(.*?)\n'

# AES-128 密钥 URI
r'URI="([^"]+)"'

# AES-128 IV
r'IV=0x([0-9a-fA-F]+)'
```

---

## 请求流程

### Cookie 设置流程

```
1. 检测站点类型 (original / porn91)
   ↓
2. Porn91 站点：
   a. 设置语言 Cookie: language=cn_CN
   b. 对于 91porn.com 额外设置 .91porn.com 域名
   ↓
3. 设置 Referer 为站点域名
   ↓
4. 如启用代理，创建 SOCKS5 Session
   ↓
5. 保留原始 Session 的 headers 和 cookies
```

### 列表页请求流程（Porn91）

```
1. GET 请求获取初始 Cookie
   ↓
2. POST 提交语言参数：
   - URL: 原列表页 URL
   - Data: {"session_language": "cn_CN"}
   ↓
3. 处理重定向（记录最终 URL）
   ↓
4. 解析响应 HTML
```

### 单视频下载流程

```
1. GET 视频页面
   ↓
2. 提取 m3u8/mp4 地址
   ↓
3a. 如果是 .mp4：直接流式下载
   ↓
3b. 如果是 .m3u8：
   a. 解析 m3u8（可能需要选择最高分辨率）
   b. 获取所有 TS 切片列表
   c. 并发下载 TS 切片（支持重试）
   d. 用 ffmpeg 合并为 MP4
   ↓
4. 标记已下载（SQLite）
```

---

## 下载流程

### M3U8 解析 (M3U8Parser)

```
1. 获取 m3u8 文件内容
   ↓
2. 判断是否为 Master Playlist
   ├─ Yes: 选择最高分辨率子流
   └─ No: 解析 Media Playlist
   ↓
3. 解析 EXT-X-KEY 获取加密信息
   ↓
4. 收集所有 TS 切片 URL 和 IV
   ↓
5. 返回切片列表和密钥 URL
```

### TS 切片下载 (TSDownloader)

```
并发下载配置：
- 默认线程数: min(32, cpu_count + 4)
- 超时: 30秒
- 重试: 最多 3 轮

流程：
1. 第一轮并发下载所有切片
   ↓
2. 重试失败的切片（最多 3 轮）
   ↓
3. 检查成功率
   ├─ >= 50%: 继续写入
   └─ < 50%: 放弃转换
   ↓
4. 写入临时 .ts.tmp 文件
   ↓
5. 用 ffmpeg 转换为 MP4
```

### AES-128 解密

```
1. 下载密钥文件（十六进制字符串）
   ↓
2. 转换密钥为 16 字节
   ↓
3. 使用 CBC 模式解密每个 TS 切片
   cipher = AES.new(key, AES.MODE_CBC, iv)
   ↓
4. 解密后数据写入文件
```

### ffmpeg 转换命令

```bash
ffmpeg -y \
  -i {input_ts_file} \
  -c copy \
  -bsf:a aac_adtstoasc \
  -progress pipe:1 \
  -nostats \
  {output_mp4_file}
```

### 直接 MP4 下载

```
1. 流式请求下载
   ↓
2. 分块写入（chunk_size = 256KB）
   ↓
3. 支持暂停/恢复
   ↓
4. 下载完成重命名临时文件
   ↓
5. 标记已下载
```

---

## 文件存储结构

```
downloads/
├── 2026-03-28/
│   ├── 视频标题1.mp4
│   ├── 视频标题2.mp4
│   └── AuthorName/
│       ├── 作者视频1.mp4
│       └── 作者视频2.mp4
└── 2026-03-29/
    └── ...
```

---

## 数据库结构 (SQLite)

```sql
-- 下载历史记录
CREATE TABLE download_history (
    video_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    url TEXT,
    upload_date TEXT,
    download_time TEXT,
    archived INTEGER DEFAULT 0
);

-- 流量统计
CREATE TABLE traffic_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    bytes_downloaded INTEGER DEFAULT 0,
    video_count INTEGER DEFAULT 0,
    start_time TEXT,
    end_time TEXT
);
```

---

## 回调函数接口

| 回调 | 签名 | 说明 |
|------|------|------|
| `log_callback` | `(message: str, level: str) -> void` | 日志输出 |
| `progress_callback` | `(current: int, total: int) -> void` | 下载进度 |
| `merge_progress_callback` | `(percent: int, speed: str) -> void` | 合并进度 |
| `speed_callback` | `(speed_bps: float, total_bytes: int) -> void` | 实时速度 |
| `info_callback` | `(info: dict) -> void` | 视频信息（封面等） |
| `confirm_callback` | `(dialog: dict) -> str` | 确认弹窗，返回选择 |
| `stop_check` | `() -> bool` | 返回 True 时停止 |

---

## 关键配置项 (config)

| 键 | 类型 | 说明 |
|----|------|------|
| `site` | str | 站点 URL |
| `site_types` | dict | 域名到类型的映射 |
| `img_base_url` | str | 封面图片基础 URL |
| `proxy_enabled` | bool | 是否启用代理 |
| `proxy_host` | str | 代理主机 |
| `proxy_port` | int | 代理端口 |
| `proxy_user` | str | 代理用户名 |
| `proxy_pass` | str | 代理密码 |
| `output_dir` | str | 输出目录 |
| `sort_by_upload_date` | bool | 按上传日期分类 |
| `title_with_author` | bool | 标题加上传者 |
