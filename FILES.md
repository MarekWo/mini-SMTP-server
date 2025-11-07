# Project Files Overview

Quick reference guide to all files in mini-SMTP-server project.

## 📄 Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | Complete project documentation with all features and configuration |
| [QUICKSTART.md](QUICKSTART.md) | 5-minute quick start guide |
| [EXAMPLES.md](EXAMPLES.md) | Code examples for 7+ programming languages (with display name examples) |
| [INTEGRATION-MANAGER-WYSTAW.md](INTEGRATION-MANAGER-WYSTAW.md) | Integration guide for Manager-Wystaw project (includes sender name config) |
| [FILES.md](FILES.md) | This file - project files overview |
| [podsumowanie.md](podsumowanie.md) | Project summary (Polish - internal) |

## 🐳 Docker Configuration

| File | Description |
|------|-------------|
| [docker-compose.yml](docker-compose.yml) | Main Docker Compose configuration |
| [docker-compose.test.yml](docker-compose.test.yml) | Test service for sending test emails |
| [docker-compose.integration-example.yml](docker-compose.integration-example.yml) | Integration examples for existing projects |

## ⚙️ Configuration

| File | Description |
|------|-------------|
| [.env](.env) | Your environment configuration (not committed to git) |
| [.env.example](.env.example) | Example configuration template |
| [.gitignore](.gitignore) | Git ignore rules (protects keys and .env) |

## 🔧 Tools

| File | Description |
|------|-------------|
| [generate-dkim-keys.ps1](generate-dkim-keys.ps1) | DKIM key generator for Windows (PowerShell) |
| [generate-dkim-keys.sh](generate-dkim-keys.sh) | DKIM key generator for Linux/Mac (Bash) |

## 🗂️ Directories

| Directory | Description |
|-----------|-------------|
| `dkim/` | DKIM keys directory (private key protected by .gitignore) |

## 📋 Quick Navigation

### First Time Setup
1. Read [QUICKSTART.md](QUICKSTART.md)
2. Copy `.env.example` to `.env`
3. Run `generate-dkim-keys.ps1` or `generate-dkim-keys.sh`
4. Start: `docker compose up -d`

### Integration with Existing Project
1. See [INTEGRATION-MANAGER-WYSTAW.md](INTEGRATION-MANAGER-WYSTAW.md) for example
2. Check [docker-compose.integration-example.yml](docker-compose.integration-example.yml)
3. Set `NETWORK_NAME` in `.env`

### Code Examples
- [EXAMPLES.md](EXAMPLES.md) - Python, Node.js, PHP, Java, C#, Go, Ruby

### Testing
```bash
docker compose -f docker-compose.yml -f docker-compose.test.yml up test-mailer
```

### Full Documentation
- [README.md](README.md) - Everything you need to know

---

**Tip:** All documentation files are written in Markdown and can be viewed directly on GitHub or in any Markdown viewer.
