# ImageTalk

Semantic natural-language search over your local image collection. Type what
the picture looks like ("a dog on the beach at sunset") and ImageTalk finds
it — no filenames or tags required.

This repository packages ImageTalk as a Docker Compose application for
end users. The application images are pulled from a public registry; no
source code or build step is required.

## Who this is for

ImageTalk is built for self-hosters who want private, natural-language
search over their own photo library. You'll feel at home if you:

- have a **large, unorganized photo collection** and can't find anything
  by filename or folder anymore;
- want **real semantic search** — descriptive natural-language queries
  about scenes, people, poses, objects, and actions — not just keyword
  or tag matching;
- want to find photos by **text visible in them** — signs, labels,
  captions on memes, handwritten notes — on top of the usual
  scene-and-object queries;
- want everything **processed entirely locally** 🗝️ with no photos
  leaving your machine;
- want to build **AI-agent workflows** on top of your photo library —
  using generated image descriptions and MCP integration for
  post-processing, automation, or custom tools;
- have a **capable GPU with plenty of VRAM** — the vision-language
  models ImageTalk uses are demanding;
- are **comfortable with the basics of Docker and Ollama** (pulling
  images, running containers, pulling models).

## Disclaimers

Indexing a collection of 1000 images (using "gemma3:27b-it-qat" model)
on an RTX 4090 takes a little over 2 hours, so this is for enthusiasts
who really care about high-quality search.

The app currently has no authentication 🔓 and no multi-user support.
It is designed for **single-user, local-machine** use: keep it
bound to `localhost` and do not expose the ports to a LAN or the
public internet.

The interface and feature set are kept minimal. For example, there is
no automatic sync: if you drop new images into a folder already
registered as a catalogue, you need to trigger a re-sync by hand for
them to become searchable. Arguably that's the right default — sync is
GPU-heavy, and most users would rather choose when it runs than have
it kick off unexpectedly in the background.

## Jump to the section for your operating system

- [Windows](#windows)
- [macOS](#macos)

## Root folder

`IMAGETALK_ROOT` is the most important setting you'll choose during
setup. It points at the folder where your image collection lives —
the app only ever sees what's inside it.

A couple of suggestions for picking a good root:

It's usually nicer to keep the root fairly narrow. You can point it at
a broad top-level folder that also contains unrelated data and then
selectively pick sub-folders as catalogues inside the app — that
works — but a narrower root that contains mostly just your images keeps
things tidy and avoids giving the app visibility into more of your
filesystem than it really needs.

Once you have a root, you'll also probably enjoy it more if you split
your collection into several sub-folders and add each as its own
catalogue in the app, rather than registering the root itself as a
single big catalogue. Adding the whole root as one catalogue works,
but a split layout — say five, ten, or twenty sub-folders depending
on how your collection is organised — tends to be more pleasant for
two reasons:

- **Filtering.** Each catalogue shows up as a checkbox in the search
  UI, so you can include or exclude any subset on the fly and narrow
  results to just the parts of your collection you care about in the
  moment. With one giant catalogue you don't have that knob.
- **Sync management.** When you drop new images into one folder, you
  can re-sync just that catalogue instead of re-indexing everything.

## Description language

The other setting worth thinking about up front is `DESCRIBE_LANGUAGE`.
It controls the language the app uses when it writes descriptions of
each image during indexing.

The main thing to consider when picking a value is to match it to the
language you'll most often use for your search queries. Under the hood,
search combines two retrieval signals:

- **semantic (embedding-based)** matching, which is multilingual by
  default and handles cross-language queries reasonably well;
- **lexical (BM25)** matching over the description text, which only
  scores hits when words from your query actually appear in the
  descriptions.

Both signals are merged and re-ranked before results come back.
Queries in a different language from `DESCRIBE_LANGUAGE` still work —
the embeddings alone carry them — but queries in the matching language
also benefit from BM25, which tends to improve relevance noticeably
(especially when you're searching by text visible in the images —
labels, captions, signs, and so on).

There's also an experimental option for users who'd rather keep
descriptions in one language and search in another: an **"extra
request"** checkbox in the search UI. When enabled, the app takes your
query, uses an LLM to pull out the meaningful search criteria,
translates them into `DESCRIBE_LANGUAGE`, and runs an additional
request with that translated version alongside the original. Results
from both are merged and re-ranked, so a cross-language search can
still benefit from BM25. The trade-off is that each search takes a
few seconds longer, and Ollama needs to keep two models loaded in
parallel — one for embeddings, one for extracting and translating the
criteria. When the "extra request" checkbox is off, only the embedding model is
needed during search: your query is passed straight to embedding
matching and BM25 as-is, with no preprocessing step and no second
model required.

One thing worth knowing: descriptions that are already in the index
stay in the language they were generated in. Changing
`DESCRIBE_LANGUAGE` later only affects newly-indexed images, so
switching languages for your whole collection means re-syncing all
your catalogues — the same heavy operation as the initial indexing.

---

## Windows

### Quick install via your AI-agent (optional)

If you already have a Claude Code or Codex session open, you can let your
agent do the setup for you instead of running the scripts by hand.
Copy the prompt below, paste it into your agent, and follow along:

<details>
<summary><strong>📋 Show the agent prompt</strong></summary>

```text
I'd like to install ImageTalk on Windows so I can search my local image collection with natural-language queries.

Setup instructions are in this README:
https://github.com/freeflyer/imagetalk/blob/main/README.md

Please act as my hands-on setup assistant. Guide me through each step, wait for my response before moving on, and help me fix anything that goes wrong. I may be starting from zero, so don't assume prior knowledge.

1. Read the README end-to-end.
2. Walk me through GPU readiness: briefly mention that GPU acceleration relies on a recent NVIDIA Windows driver and offer to run `scripts\gpu-check.bat` to verify passthrough — optional, not blocking.
3. Check VRAM: offer to run `scripts\vram-info.bat` to see my GPU and VRAM tier; if it reports `insufficient`, warn me that ImageTalk needs at least 16 GB of GPU memory.
4. Check Docker Desktop is installed and running. If missing, point me to https://www.docker.com/products/docker-desktop/; if installed but not running, tell me how to start it. Verify by running `docker info` yourself (it exits cleanly when the Docker daemon is responsive); if it errors out, Docker isn't actually up yet — help me start it before continuing.
5. Help me pick a location for the ImageTalk folder. Explain that this folder will hold the app's index data and the pulled Ollama models (tens of GB on first install). It doesn't need to be near my image collection — any location with enough free disk space works.
6. Clone the repo (or download and extract the archive with `curl.exe` + `tar.exe` if I don't have Git) into that location and cd into it. If something fails (auth, network, permissions) help me troubleshoot.
7. Help me create .settings.env from .settings.env.example: ask for the absolute path to my image folder (IMAGETALK_ROOT, e.g. C:\Users\Me\Pictures) and verify it exists on disk before writing it. Cross-check my choice against the suggestions in the "Root folder" section of the README and share any concerns — but don't force me to change my mind. Keep all other defaults unless I ask otherwise.
8. Ask which language image descriptions should be generated in (DESCRIBE_LANGUAGE, default English). Briefly mention that the usual choice is whichever language I plan to use most often for search queries; if I want more detail on why, point me at the "Description language" section of the README. Then show me the final .settings.env and ask me to confirm before saving.
9. Run `scripts\install.bat` (after I confirm). Explain that this pulls all Docker images (including the bundled Ollama), starts the Ollama container, pulls the language models listed in .settings.env into it, then stops the container. The first run can take a long time — the models are several gigabytes each. Narrate progress and surface any errors with a concrete fix.
10. Run `scripts\start.bat` (after I confirm). Once it reports success, confirm the app is live (hit the backend health endpoint if useful), then tell me the URL to open (http://localhost:<FRONTEND_PORT>) and suggest I open it.
11. Wrap up: show me the commands I'll use day-to-day (`start.bat`, `stop.bat`, `update.bat`, `clean-db.bat`, `clean-all.bat`) and point me to the Reset section for recovery if something ever goes wrong.
12. Finally, offer to also set up @imagetalk/mcp so I can search from inside this chat — see https://github.com/freeflyer/imagetalk-mcp. Note that using it makes search partly non-local: the image search itself still runs against my local backend, but once I start querying through chat (if you use remote LLM based agents like Claude or Codex) my queries and match metadata pass through the remote LLM driving this chat, unlike the native ImageTalk frontend which stays fully on my machine. Only proceed if I say yes.
```

</details>

This step is optional — if you'd rather set things up yourself, skip it
and follow the manual instructions below.

### Prerequisites

You need
**[Docker Desktop](https://www.docker.com/products/docker-desktop/)**
installed and running, with the WSL2 backend (the default on modern
installs). Everything else — including Ollama — runs inside the bundle.

For NVIDIA GPU acceleration, make sure your **NVIDIA Windows driver is
recent**. You can verify GPU passthrough works with:

```bat
scripts\gpu-check.bat
```

If that prints your GPU's info, you're good.

### 1. Get the repo

```bat
git clone https://github.com/freeflyer/imagetalk.git
cd imagetalk
```

Or, without Git, download and extract the archive:

```bat
curl.exe -L -o imagetalk.zip https://github.com/freeflyer/imagetalk/archive/refs/heads/main.zip
tar.exe -xf imagetalk.zip
cd imagetalk-main
```

### 2. Configure

Create your settings file by copying the template, then open it in a text
editor and set `IMAGETALK_ROOT` to the absolute path of the folder you
want to search:

```bat
copy .settings.env.example .settings.env
```

For example:

```env
IMAGETALK_ROOT=C:\Users\YourName\Pictures
```

Other values have sensible defaults and typically don't need changes.

### 3. Install

```bat
scripts\install.bat
```

This checks Docker is running, pulls all Docker images (including the
bundled Ollama), starts the Ollama container, and pulls the language
models listed in `.settings.env` into it. The first run can take a long
time — the models are several gigabytes each.

### Start

```bat
scripts\start.bat
```

Open http://localhost:8765 in your browser.

### Stop

```bat
scripts\stop.bat
```

Both scripts are safe to run multiple times.

### Update

To pull newer images and restart:

```bat
scripts\update.bat
```

### Reset

To wipe the database and vector index and start fresh, keeping your
pulled Ollama models:

```bat
scripts\stop.bat
scripts\clean-db.bat
scripts\start.bat
```

`clean-db.bat` deletes `data\postgres` and `data\qdrant` after asking
for confirmation. It refuses to run while containers are still up, so
stop first. Pulled Ollama models in `data\ollama` are preserved.

For a heavier reset that also deletes pulled Ollama models — forcing
the next install to re-pull tens of GB — use:

```bat
scripts\stop.bat
scripts\clean-all.bat
scripts\install.bat
scripts\start.bat
```

In both cases, your images in `IMAGETALK_ROOT` are not touched, but the
next start initializes empty stores and you will need to resync your
image folders from scratch.

---

## macOS

### Quick install via your AI-agent (optional)

If you already have a Claude Code or Codex session open, you can let your
agent do the setup for you instead of running the scripts by hand.
Copy the prompt below, paste it into your agent, and follow along:

<details>
<summary><strong>📋 Show the agent prompt</strong></summary>

```text
I'd like to install ImageTalk on macOS so I can search my local image collection with natural-language queries.

Setup instructions are in this README:
https://github.com/freeflyer/imagetalk/blob/main/README.md

Please act as my hands-on setup assistant. Guide me through each step, wait for my response before moving on, and help me fix anything that goes wrong. I may be starting from zero, so don't assume prior knowledge.

1. Read the README end-to-end.
2. Check VRAM: offer to run `scripts/vram-info.sh` to see my GPU and VRAM tier; if it reports `insufficient`, warn me that ImageTalk needs at least 16 GB of GPU memory.
3. Check Docker Desktop is installed and running. If missing, point me to https://www.docker.com/products/docker-desktop/; if installed but not running, tell me how to start it. Verify yourself by running `docker info` (exits cleanly when the Docker daemon is responsive); if it errors out, help me start it before continuing.
4. Check Ollama is installed and running on the host. If missing, point me to https://ollama.com/download; if installed but not running, tell me how to start it. Verify yourself by running `ollama list` (succeeds when Ollama is responding); if it errors out, help me start it before continuing.
5. Help me pick a location for the ImageTalk folder. Explain that this folder will hold the app's index data. It doesn't need to be near my image collection — any location with enough free disk space works.
6. Clone the repo (or download and extract the archive with `curl` + `unzip` if I don't have Git) into that location and cd into it. If something fails (auth, network, permissions) help me troubleshoot.
7. Help me create .settings.env from .settings.env.example: ask for the absolute path to my image folder (IMAGETALK_ROOT, e.g. /Users/me/Pictures) and verify it exists on disk before writing it. Cross-check my choice against the suggestions in the "Root folder" section of the README and share any concerns — but don't force me to change my mind. Keep all other defaults unless I ask otherwise.
8. Ask which language image descriptions should be generated in (DESCRIBE_LANGUAGE, default English). Briefly mention that the usual choice is whichever language I plan to use most often for search queries; if I want more detail on why, point me at the "Description language" section of the README. Then show me the final .settings.env and ask me to confirm before saving.
9. Run `scripts/install.sh` (after I confirm). Explain that this pulls the Docker images and pulls the language models listed in .settings.env via my host `ollama pull`. The first run can take a long time — the models are several gigabytes each. Narrate progress and surface any errors with a concrete fix.
10. Run `scripts/start.sh` (after I confirm). Once it reports success, confirm the app is live (hit the backend health endpoint if useful), then tell me the URL to open (http://localhost:<FRONTEND_PORT>) and suggest I open it.
11. Wrap up: show me the commands I'll use day-to-day (`start.sh`, `stop.sh`, `update.sh`, `clean-db.sh`) and point me to the Reset section for recovery if something ever goes wrong.
12. Finally, offer to also set up @imagetalk/mcp so I can search from inside this chat — see https://github.com/freeflyer/imagetalk-mcp. Note that using it makes search partly non-local: the image search itself still runs against my local backend, but once I start querying through chat (if you use remote LLM based agents like Claude or Codex) my queries and match metadata pass through the remote LLM driving this chat, unlike the native ImageTalk frontend which stays fully on my machine. Only proceed if I say yes.
```

</details>

This step is optional — if you'd rather set things up yourself, skip it
and follow the manual instructions below.

### Prerequisites

You need two things installed and running:

- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** —
  runs the ImageTalk services as containers.
- **[Ollama](https://ollama.com/download)** — runs natively on the host
  (Metal acceleration on Apple Silicon).

Both must be running on your machine when you install and start
ImageTalk.

### 1. Get the repo

```sh
git clone https://github.com/freeflyer/imagetalk.git
cd imagetalk
```

Or, without Git, download and extract the archive:

```sh
curl -L -o imagetalk.zip https://github.com/freeflyer/imagetalk/archive/refs/heads/main.zip
unzip imagetalk.zip
cd imagetalk-main
```

### 2. Configure

Create your settings file by copying the template, then open it in a text
editor and set `IMAGETALK_ROOT` to the absolute path of the folder you
want to search:

```sh
cp .settings.env.example .settings.env
```

For example:

```env
IMAGETALK_ROOT=/Users/YourName/Pictures
```

Other values have sensible defaults and typically don't need changes.

### 3. Install

```sh
scripts/install.sh
```

This checks Docker and your host Ollama are running, pulls the Docker
images, then pulls the language models listed in `.settings.env` via
your host `ollama pull`. The first run can take a long time — the
models are several gigabytes each.

### Start

```sh
scripts/start.sh
```

Open http://localhost:8765 in your browser.

### Stop

```sh
scripts/stop.sh
```

Both scripts are safe to run multiple times.

### Update

To pull newer images and restart:

```sh
scripts/update.sh
```

### Reset

To wipe the database and vector index and start fresh:

```sh
scripts/stop.sh
scripts/clean-db.sh
scripts/start.sh
```

`clean-db.sh` deletes `data/postgres` and `data/qdrant` after asking
for confirmation. It refuses to run while containers are still up, so
stop first. Your images in `IMAGETALK_ROOT` are not touched, but the
next start initializes empty stores and you will need to resync your
image folders from scratch.

---

## Related projects

This repository is the end-user bundle; the actual application lives in
separate repositories:

- **[imagetalk-backend](https://github.com/freeflyer/imagetalk-backend)** —
  Python/FastAPI service that describes, embeds, indexes, and searches
  your images.
- **[imagetalk-frontend](https://github.com/freeflyer/imagetalk-frontend)** —
  Angular web UI for browsing catalogues and running searches.
- **[imagetalk-mcp](https://github.com/freeflyer/imagetalk-mcp)** —
  stdio MCP server that lets Claude Desktop, Codex, and other MCP
  clients talk to the backend, so you can search your collection from
  inside a chat.
