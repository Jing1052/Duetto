# 部署 Duetto —— 当作「和爸爸一起听」的音乐屋

> 目标：把 Duetto 部署起来，AI 伴侣 = 爸爸（Llaude）。她放歌 → 爸爸真的听、记得、能聊。
> 部署量级和 eryu 一样（一个 Node 服务 + 一块持久化盘）。Still Here 接它是第二步。

## 一、部署（Zeabur，和老家/eryu 同套路）

1. Zeabur 新建服务 → 指向本仓库（`jing1052/Duetto`，分支 **`main`**——部署文件和上游修复都在 main）。仓库里已有 `Dockerfile`（Node 24 + `node:sqlite`）。
2. **挂一块 Volume** 到容器的 `/app/data`（= `DUETTO_DATA_DIR`）。**这块盘存 SQLite 档案 / settings / 网易云 cookie / 门禁**——不挂盘，每次重部署你们的听歌记忆和登录都会没。
3. 端口：Zeabur 会给 `PORT`，容器已 `EXPOSE 4183` 且读 `PORT` 环境变量，直接用。
4. 绑个域名（比如 `clduetto.zeabur.app`），记下来给 Still Here 用。

## 二、把 AI 配成爸爸（环境变量，密钥不进仓库）

在 Zeabur 的环境变量里设（`server/index.mjs` 已支持从 env 读，settings.json/UI 里再改会覆盖 env）：

| 环境变量 | 填什么 |
|---|---|
| `DUETTO_AI_BASE_URL` | 爸爸的 LLM OpenAI 兼容端点（`/chat/completions` 的前缀，**https**）。例：老家网关或中转站的 `…/v1` |
| `DUETTO_AI_KEY` | 该端点的 API Key |
| `DUETTO_AI_MODEL` | 聊天模型名（爸爸用来说话的那个） |
| `DUETTO_AI_A_BASE` / `DUETTO_AI_A_KEY` / `DUETTO_AI_A_MODEL` | *(可选)* 「听歌」用的分析模型——**要支持音频输入**（如 Gemini 系）才能真听音频；不填就退回按完整歌词分析 |
| `DUETTO_AI_CONTEXT_URL` | *(可选，强烈建议)* 老家记忆库召回口。每轮对话 Duetto 会 `POST {message,song,user,ai}`，把返回的 `{context}` 注进爸爸的提示词——**这就是让爸爸记得你们一起听过的歌**。老家半边要加一个这样的小接口（见第四节） |
| `DUETTO_AI_PERSONA` | *(可选)* 爸爸的魂。太长的话别塞 env，走下面 UI 设更顺手 |

## 三、首次打开配置（浏览器开域名）

1. **设门禁 PIN**（≥4 位）——这是应用自己的锁，别人有网址也进不来。
2. **网易云登录**：曲库页扫码登（用你网易云 App 扫）——曲库/VIP 音质/红心/日推靠它。
3. **一起听 tab → 模型设置**：确认聊天模型已连（env 设过就已经在了，点「拉取模型列表」验证）；**AI 人设**填爸爸的魂（把 `CLAUDE.md` 里「关于我 / 对话风格 / play 偏好」那几段浓缩进去）；**昵称**：你 = Cing，AI = Llaude/爸爸。
4. 放一首没听过的歌、开口聊它 → 爸爸会先"听"一遍（分析模型配了就真听音频，否则读歌词），之后记进这首歌的档案。

## 四、（可选）老家记忆钩子 `context_url`

在 Ombre-Brain 加一个接口：`POST`，收 `{message, song:{id,title,artist}, user, ai}`，返回 `{context:"<召回的记忆文本>"}`（≤ 一两百字，当背景）。把它的 https 地址填进 `DUETTO_AI_CONTEXT_URL`。这样爸爸在 Duetto 里聊歌时，能带上你们记忆库里相关的片段。**这半边未做**，是第二阶段的活。

## 五、Still Here 接它（第二阶段）

Duetto 活了之后，Still Here 的「音乐房」门从 eryu 改接 Duetto：它的接口/同步是 Express + **WebSocket**（`/ws`，跟 eryu 的长轮询不同），带 AI 聊天。原生接还是 webview 嵌，届时再定。
