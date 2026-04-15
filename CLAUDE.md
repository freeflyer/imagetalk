# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

End-user distribution of **ImageTalk** as a Docker Compose application.
Not source code — just compose files, a settings template, and helper
scripts that pull prebuilt images. This repo does **not** build images;
builds happen in the sibling source repos (see [Related Projects](#related-projects)).

## Layout

- `docker-compose.windows.yml` — Windows compose: postgres, qdrant,
  bundled Ollama (NVIDIA GPU passthrough), backend, frontend.
- `docker-compose.macos.yml` — macOS compose: postgres, qdrant,
  backend, frontend. No Ollama service — macOS users run Ollama
  natively on the host; backend reaches it via
  `host.docker.internal:11434`.
- `.settings.env.example` — single source of truth for user-configurable
  values. Keys `OLLAMA_VERSION`, `OLLAMA_PORT`,
  `OLLAMA_MAX_LOADED_MODELS` are Windows-only.
- `.settings.env` — user's actual settings; gitignored.
- `scripts/` — `.bat` for Windows (containerized Ollama), `.sh` for
  macOS (host Ollama).
- `data/` — runtime bind mounts (Postgres, Qdrant, and on Windows
  Ollama models). Gitignored.

## Scripts

| Script | `.bat` (Windows) | `.sh` (macOS) |
|---|---|---|
| `install` | Check Docker → pull images → start ollama container → exec pull models → stop ollama. | Check Docker + host Ollama → pull images → host `ollama pull` × 3. |
| `start` / `stop` / `update` | compose up/down/pull-and-up. | Same. |
| `clean-db` | Delete `data/postgres` + `data/qdrant`. | Same. |
| `clean-all` | Like `clean-db` + delete `data/ollama`. | Not provided (host Ollama owns its model cache). |
| `ollama-ps` | `docker exec imagetalk-ollama ollama ps`. | `ollama ps` (host). |
| `gpu-check` | Verifies WSL2 GPU passthrough. | Not provided. |
| `vram-info` | Reports GPU + VRAM + recommended profile. | Same. |

### Pairing rules between `.bat` and `.sh`

The two sets are **not blindly mirrored**. Each script lives on the
platform(s) where it does something meaningful, and is omitted where
it doesn't.

- If a script applies to both OSes: keep both, match step numbering /
  prompts / exit codes / messages. Implementation differs (compose
  file, container vs host Ollama); behavior matches.
- If a script only makes sense on one OS: provide it only there. Don't
  ship a degenerate stub on the other side.

## Related Projects

- **`imagetalk-backend`** — Python/FastAPI service. Published as
  `ghcr.io/freeflyer/imagetalk-backend`; this bundle pulls it.
- **`imagetalk-frontend`** — Angular web UI. Published as
  `ghcr.io/freeflyer/imagetalk-frontend`; this bundle pulls it.
- **`imagetalk-mcp`** — Stdio MCP server. Distributed via npm as
  `@imagetalk/mcp`. Not part of the Compose flow.

### Working across related projects

When a task requires looking at one of the sibling projects:

1. If you don't know where the related project lives locally — or the
   path you remembered no longer resolves — **stop and ask the user**.
   Verify the path, then save it to project-scope memory (never to
   files committed in this repo).
2. **Never make silent changes in a related project.** Describe the
   proposed change and wait for approval. The only exception is when
   the user has explicitly asked you to modify that other project.

A request to change *this* project is not permission to change
*another*.
