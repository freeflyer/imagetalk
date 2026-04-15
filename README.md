# ImageTalk

Semantic natural-language search over your local image collection. Type what
the picture looks like ("a dog on the beach at sunset") and ImageTalk finds
it — no filenames or tags required.

This repository packages ImageTalk as a Docker Compose application for
end users. The application images are pulled from a public registry; no
source code or build step is required.

## Prerequisites

Install and start the following before you begin:

- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** —
  runs the ImageTalk services as containers.
- **[Ollama](https://ollama.com/download)** — hosts the local language
  models ImageTalk uses.

Both must be running on your machine when you install and start ImageTalk.

> Tested on Windows. macOS support is planned.

## Install

### 1. Get the repo

```bat
git clone https://github.com/freeflyer/imagetalk.git
cd imagetalk
```

Or, without Git, download and extract the archive (Windows):

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

```env
IMAGETALK_ROOT=C:\Users\YourName\Pictures
```

Other values have sensible defaults and typically don't need changes.

### 3. Install

```bat
scripts\install.bat
```

This checks that Docker and Ollama are running, then downloads the
language models listed in `.settings.env` via `ollama pull`. The first
run can take a long time — the models are several gigabytes each.

## Run

### Start

```bat
scripts\start.bat
```

Open http://localhost:2080 in your browser.

### Stop

```bat
scripts\stop.bat
```

Both scripts are safe to run multiple times.

## Update

To pull newer images and restart:

```bat
scripts\update.bat
```

## Reset

To wipe ImageTalk's database and vector index and start fresh:

```bat
scripts\stop.bat
scripts\clean.bat
scripts\start.bat
```

`clean.bat` deletes `data\postgres` and `data\qdrant` after asking for
confirmation. It refuses to run while containers are still up, so always
stop first. Your images in `IMAGETALK_ROOT` are not touched — but the
next start will initialize empty stores, and you will need to resync
your image folders from scratch.
