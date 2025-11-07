# mini-SMTP-server

A lightweight, self-contained SMTP relay server in Docker with full DKIM support. Perfect for sending email notifications from your containerized applications without relying on external SMTP services.

## Features

- ✉️ **SMTP Relay** - Send emails from any Docker container
- 🔐 **DKIM Signing** - Properly sign emails with DKIM for better deliverability
- 🐳 **Docker-based** - Easy deployment and integration
- 🔧 **Configurable** - Environment variable configuration
- 📝 **Reusable** - Easy to integrate with existing projects
- 🚀 **Production-ready** - Includes SPF, DKIM, and DMARC support

## Quick Start

### 1. Clone or Copy This Project

```bash
git clone https://github.com/MarekWo/mini-SMTP-server mini-smtp-server
cd mini-smtp-server
```

### 2. Configure Your Domain

Copy the example configuration:

```bash
cp .env.example .env
```

Edit `.env` and update:

```env
DOMAIN=your-domain.com
DKIM_SELECTOR=mail
HOSTNAME=smtp.your-domain.com
```

### 3. Generate DKIM Keys

**On Windows (PowerShell):**
```powershell
.\generate-dkim-keys.ps1
```

**On Linux/Mac:**
```bash
chmod +x generate-dkim-keys.sh
./generate-dkim-keys.sh
```

The script will:
- Generate DKIM private and public keys
- Create a `.env` file with your configuration
- Display the DNS TXT record you need to add

### 4. Add DNS Records

Add the following DNS records to your domain:

#### DKIM Record
Add the TXT record displayed by the key generator:
```
Type: TXT
Name: mail._domainkey.your-domain.com
Value: (shown by generator)
```

#### SPF Record
```
Type: TXT
Name: @
Value: v=spf1 mx a ip4:YOUR_SERVER_IP ~all
```

#### DMARC Record
```
Type: TXT
Name: _dmarc.your-domain.com
Value: v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;
```

### 5. Verify DNS Propagation

Wait for DNS propagation (can take up to 48 hours, usually much faster).

**Verify DKIM:**
```bash
# Windows
nslookup -type=TXT mail._domainkey.your-domain.com

# Linux/Mac
dig mail._domainkey.your-domain.com TXT
```

### 6. Start the Server

```bash
docker compose up -d
```

### 7. Test Email Delivery

Send a test email:

```bash
# Update TEST_EMAIL in .env first
docker compose -f docker-compose.yml -f docker-compose.test.yml up test-mailer
```

Check the email headers to verify DKIM signature passes.

## Integration with Your Applications

### Option 1: External Network (Recommended)

If `mini-smtp-server` is running separately, connect your app to the `mail-network`:

```yaml
# your-app/docker-compose.yml
services:
  your-app:
    image: your-app:latest
    environment:
      - SMTP_HOST=smtp
      - SMTP_PORT=25
      - SMTP_FROM=noreply@your-domain.com
    networks:
      - mail-network

networks:
  mail-network:
    external: true
    name: mail-network
```

### Option 2: Same Compose File

Include the SMTP server directly (see `docker-compose.integration-example.yml` for full example).

### Sending Emails from Your Application

Configure your application to use these SMTP settings:

```
SMTP Host: smtp (or mini-smtp-server)
SMTP Port: 25
Authentication: None (relay is trusted)
TLS/SSL: Off (internal network)
From Address: anything@your-domain.com
```

#### Example: Python

```python
import smtplib
from email.message import EmailMessage

msg = EmailMessage()
msg['Subject'] = 'Test Email'
msg['From'] = 'noreply@your-domain.com'
msg['To'] = 'recipient@example.com'
msg.set_content('Hello from mini-smtp-server!')

with smtplib.SMTP('smtp', 25) as server:
    server.send_message(msg)
```

#### Example: Node.js (nodemailer)

```javascript
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: 'smtp',
  port: 25,
  secure: false,
  tls: {
    rejectUnauthorized: false
  }
});

await transporter.sendMail({
  from: 'noreply@your-domain.com',
  to: 'recipient@example.com',
  subject: 'Test Email',
  text: 'Hello from mini-smtp-server!'
});
```

#### Example: PHP

```php
<?php
ini_set('SMTP', 'smtp');
ini_set('smtp_port', 25);

mail(
    'recipient@example.com',
    'Test Email',
    'Hello from mini-smtp-server!',
    'From: noreply@your-domain.com'
);
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOMAIN` | Your domain name | `example.com` |
| `DKIM_SELECTOR` | DKIM selector | `mail` |
| `HOSTNAME` | SMTP server hostname | `smtp.example.com` |
| `SMTP_PORT` | External SMTP port | `25` |
| `MESSAGE_SIZE_LIMIT` | Max message size (bytes) | `10485760` (10MB) |
| `TZ` | Timezone | `UTC` |
| `ALLOWED_SENDER_DOMAINS` | Allowed sender domains | Uses `DOMAIN` |

### File Structure

```
mini-smtp-server/
├── dkim/                          # DKIM keys (auto-generated)
│   ├── mail.private              # Private key (keep secret!)
│   └── mail.txt                  # Public key (for DNS)
├── docker-compose.yml            # Main compose file
├── docker-compose.test.yml       # Test service
├── docker-compose.integration-example.yml  # Integration example
├── generate-dkim-keys.ps1        # Key generator (Windows)
├── generate-dkim-keys.sh         # Key generator (Linux/Mac)
├── .env.example                  # Example configuration
├── .env                          # Your configuration (create this)
├── .gitignore                    # Git ignore rules
└── README.md                     # This file
```

## Troubleshooting

### DKIM Verification Fails

1. **Check DNS record:**
   ```bash
   dig mail._domainkey.your-domain.com TXT
   ```

2. **Verify key files are mounted:**
   ```bash
   docker exec mini-smtp-server ls -la /etc/opendkim/keys/
   ```

3. **Check logs:**
   ```bash
   docker logs mini-smtp-server | grep -i dkim
   ```

### Emails Not Sending

1. **Check container is running:**
   ```bash
   docker ps | grep mini-smtp-server
   ```

2. **View logs:**
   ```bash
   docker logs mini-smtp-server
   ```

3. **Test from inside container:**
   ```bash
   docker exec -it mini-smtp-server sh
   ```

### DNS Not Propagating

- Use online tools like [MXToolbox DKIM Checker](https://mxtoolbox.com/dkim.aspx)
- Wait up to 48 hours for full propagation
- Check with your DNS provider's tools

## Security Considerations

### Private Keys

- **Never commit** `dkim/*.private` files to version control
- `.gitignore` is configured to exclude these files
- Store keys securely in production

### Network Security

- The SMTP server only accepts connections from Docker networks
- Port 25 is exposed but only accepts relay from trusted networks
- For production, consider using firewall rules

### Spam Prevention

- DKIM, SPF, and DMARC are configured for better deliverability
- The server only relays for configured domains
- Rate limiting can be added if needed

## Advanced Usage

### Using Different DKIM Keys per Domain

Generate keys for additional domains:

```powershell
.\generate-dkim-keys.ps1 -Domain another-domain.com -Selector mail2
```

Update `docker-compose.yml` to mount additional keys.

### Custom Message Size Limit

In `.env`:
```env
MESSAGE_SIZE_LIMIT=52428800  # 50MB
```

### Multiple Sender Domains

In `.env`:
```env
ALLOWED_SENDER_DOMAINS=domain1.com,domain2.com,domain3.com
```

### Logging and Monitoring

View real-time logs:
```bash
docker logs -f mini-smtp-server
```

Filter for specific events:
```bash
docker logs mini-smtp-server 2>&1 | grep -i "status=sent"
```

## Production Deployment

### Reverse Proxy Setup

For production, consider putting the SMTP server behind a reverse proxy or using proper networking:

```yaml
services:
  smtp:
    # ... existing config ...
    networks:
      - internal
    # Remove ports exposure for internal-only use
    # ports:
    #   - "25:25"
```

### Backup DKIM Keys

```bash
# Backup keys
tar -czf dkim-backup-$(date +%Y%m%d).tar.gz dkim/

# Store securely (example: encrypted storage)
gpg -c dkim-backup-$(date +%Y%m%d).tar.gz
```

### Monitoring

Set up monitoring for:
- Container health: `docker ps`
- Email delivery: Check logs for `status=sent`
- DKIM failures: `grep -i "dkim.*fail"`

## License

This project is provided as-is for use in your applications.

## Contributing

Issues and improvements are welcome! Please test thoroughly before submitting.

## Support

For issues related to:
- **DKIM/DNS**: Check your domain's DNS records
- **Docker**: Ensure Docker and Docker Compose are installed
- **Integration**: See `docker-compose.integration-example.yml`

## Credits

- Based on [boky/postfix](https://github.com/bokysan/docker-postfix) Docker image
- DKIM implementation via OpenDKIM

---

**Made with ❤️ for easy email relay in Docker environments**
