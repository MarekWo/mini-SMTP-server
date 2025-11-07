# Quick Start Guide

This guide will get you up and running in 5 minutes.

## Prerequisites

- Docker and Docker Compose installed
- A domain name with DNS access

## Setup Steps

### 1. Configure Environment

```bash
# Copy example configuration
cp .env.example .env

# Edit .env with your domain
nano .env  # or use any text editor
```

Update these values:
```env
DOMAIN=your-domain.com
DKIM_SELECTOR=mail
HOSTNAME=smtp.your-domain.com
NETWORK_NAME=mail-network  # Change if integrating with existing project
TEST_EMAIL=your-email@example.com
```

**Network Integration Tip:** If you have an existing Docker project (like Manager-Wystaw), set `NETWORK_NAME` to match that project's network (e.g., `manager-wystaw_default`).

### 2. Generate DKIM Keys

**Windows:**
```powershell
.\generate-dkim-keys.ps1
```

**Linux/Mac:**
```bash
chmod +x generate-dkim-keys.sh
./generate-dkim-keys.sh
```

### 3. Add DNS Records

Copy the DNS TXT record shown by the generator and add it to your domain's DNS.

**Example:**
```
Type: TXT
Name: mail._domainkey
Value: v=DKIM1; h=sha256; k=rsa; p=MIIBIjAN...
```

Also add SPF and DMARC records (see README.md for details).

### 4. Start the Server

```bash
docker-compose up -d
```

### 5. Send Test Email

```bash
docker-compose -f docker-compose.yml -f docker-compose.test.yml up test-mailer
```

Check your inbox and verify DKIM passes in email headers.

## Using with Your Application

Add to your app's `docker-compose.yml`:

```yaml
services:
  your-app:
    # ... your app config ...
    environment:
      - SMTP_HOST=smtp
      - SMTP_PORT=25
    networks:
      - mail-network

networks:
  mail-network:
    external: true
    name: mail-network
```

## Verification

### Check DNS Propagation

```bash
# Windows
nslookup -type=TXT mail._domainkey.your-domain.com

# Linux/Mac
dig mail._domainkey.your-domain.com TXT
```

### Check Server Logs

```bash
docker logs mini-smtp-server
```

### Verify DKIM in Email Headers

1. Send test email
2. Open email in Gmail
3. Click "Show original"
4. Look for `dkim=pass`

## Troubleshooting

**Container won't start:**
```bash
docker-compose logs
```

**DKIM fails:**
- Wait for DNS propagation (up to 48 hours)
- Verify DNS record with dig/nslookup
- Check keys are mounted: `docker exec mini-smtp-server ls -la /etc/opendkim/keys/`

**Emails not sending:**
- Check logs: `docker logs mini-smtp-server`
- Verify your app can reach smtp:25
- Test network: `docker exec your-app ping smtp`

## Next Steps

- See [README.md](README.md) for full documentation
- Check [docker-compose.integration-example.yml](docker-compose.integration-example.yml) for integration examples
- Set up monitoring and backups for production use

---

**That's it! You now have a working SMTP relay with DKIM.**
