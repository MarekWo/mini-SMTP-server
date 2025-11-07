# DKIM Key Generator for mini-SMTP-server (Windows PowerShell)
# This script generates DKIM keys using Docker

param(
    [string]$Domain,
    [string]$Selector = "mail"
)

Write-Host "==================================" -ForegroundColor Green
Write-Host "  DKIM Key Generator (Windows)" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

# Get domain name if not provided
if ([string]::IsNullOrEmpty($Domain)) {
    $Domain = Read-Host "Enter your domain name (e.g., example.com)"
    if ([string]::IsNullOrEmpty($Domain)) {
        Write-Host "Error: Domain name is required" -ForegroundColor Red
        exit 1
    }
}

# Get selector if not provided
if ([string]::IsNullOrEmpty($Selector)) {
    $SelectorInput = Read-Host "Enter DKIM selector (default: mail)"
    if (-not [string]::IsNullOrEmpty($SelectorInput)) {
        $Selector = $SelectorInput
    }
}

Write-Host ""
Write-Host "Generating DKIM keys for domain: $Domain" -ForegroundColor Yellow
Write-Host "Using selector: $Selector" -ForegroundColor Yellow
Write-Host ""

# Create dkim directory if it doesn't exist
$DkimDir = ".\dkim"
if (-not (Test-Path $DkimDir)) {
    New-Item -ItemType Directory -Path $DkimDir | Out-Null
}

# Generate keys using Docker (works on any platform)
Write-Host "Using Docker to generate DKIM keys..." -ForegroundColor Yellow

try {
    # Run opendkim-genkey in a container
    docker run --rm -v "${PWD}/dkim:/keys" alpine sh -c "
        apk add --no-cache opendkim-tools &&
        cd /keys &&
        opendkim-genkey -b 2048 -d $Domain -s $Selector &&
        chmod 644 ${Selector}.private ${Selector}.txt
    "

    Write-Host ""
    Write-Host "Keys generated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Files created:" -ForegroundColor Green
    Write-Host "  - dkim\${Selector}.private (private key - keep this secret!)"
    Write-Host "  - dkim\${Selector}.txt (public key for DNS)"
    Write-Host ""

    # Display DNS record
    Write-Host "==================================" -ForegroundColor Yellow
    Write-Host "  DNS RECORD TO ADD" -ForegroundColor Yellow
    Write-Host "==================================" -ForegroundColor Yellow
    Write-Host ""

    $DnsRecord = Get-Content ".\dkim\${Selector}.txt" -Raw
    Write-Host $DnsRecord
    Write-Host ""
    Write-Host "Add this TXT record to your DNS configuration" -ForegroundColor Green
    Write-Host ""

    # Create .env file if it doesn't exist
    if (-not (Test-Path ".\.env")) {
        Write-Host "Creating .env file..." -ForegroundColor Yellow

        $EnvContent = @"
# SMTP Server Configuration
DOMAIN=$Domain
DKIM_SELECTOR=$Selector
HOSTNAME=smtp.$Domain

# Email sending limits (optional)
# MESSAGE_SIZE_LIMIT=10485760
"@

        Set-Content -Path ".\.env" -Value $EnvContent
        Write-Host ".env file created" -ForegroundColor Green
        Write-Host ""
    }

    # Display next steps
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "  NEXT STEPS" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Add the DNS TXT record shown above to your domain"
    Write-Host "2. Verify DNS propagation (may take up to 48 hours)"
    Write-Host "3. Update .env file with your domain settings"
    Write-Host "4. Run: docker-compose up -d"
    Write-Host ""
    Write-Host "To verify DNS record:" -ForegroundColor Yellow
    Write-Host "  nslookup -type=TXT ${Selector}._domainkey.${Domain}"
    Write-Host ""
    Write-Host "Done! Your DKIM keys are ready to use." -ForegroundColor Green

} catch {
    Write-Host "Error generating keys: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure Docker is running and try again." -ForegroundColor Yellow
    exit 1
}
