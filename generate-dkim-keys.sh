#!/bin/bash

# DKIM Key Generator for mini-SMTP-server
# This script generates DKIM keys for your domain

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}  DKIM Key Generator${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""

# Get domain name
read -p "Enter your domain name (e.g., example.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Error: Domain name is required${NC}"
    exit 1
fi

# Get selector (default: mail)
read -p "Enter DKIM selector (default: mail): " SELECTOR
SELECTOR=${SELECTOR:-mail}

# Create dkim directory if it doesn't exist
DKIM_DIR="./dkim"
mkdir -p "$DKIM_DIR"

echo ""
echo -e "${YELLOW}Generating DKIM keys for domain: $DOMAIN${NC}"
echo -e "${YELLOW}Using selector: $SELECTOR${NC}"
echo ""

# Check if opendkim-genkey is available
if ! command -v opendkim-genkey &> /dev/null; then
    echo -e "${RED}Error: opendkim-genkey not found${NC}"
    echo -e "${YELLOW}Installing opendkim-tools...${NC}"

    # Detect OS and install
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y opendkim-tools
        elif command -v yum &> /dev/null; then
            sudo yum install -y opendkim
        else
            echo -e "${RED}Unable to install opendkim-tools automatically${NC}"
            echo "Please install it manually and run this script again"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install opendkim
        else
            echo -e "${RED}Homebrew not found. Please install opendkim manually${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Unsupported OS. Please install opendkim-tools manually${NC}"
        exit 1
    fi
fi

# Generate keys
cd "$DKIM_DIR"
opendkim-genkey -b 2048 -d "$DOMAIN" -s "$SELECTOR"

# Rename files for consistency
mv "${SELECTOR}.private" "${SELECTOR}.private"
mv "${SELECTOR}.txt" "${SELECTOR}.txt"

echo -e "${GREEN}✓ Keys generated successfully!${NC}"
echo ""
echo -e "${GREEN}Files created:${NC}"
echo "  - dkim/${SELECTOR}.private (private key - keep this secret!)"
echo "  - dkim/${SELECTOR}.txt (public key for DNS)"
echo ""

# Display DNS record
echo -e "${YELLOW}==================================${NC}"
echo -e "${YELLOW}  DNS RECORD TO ADD${NC}"
echo -e "${YELLOW}==================================${NC}"
echo ""
cat "${SELECTOR}.txt"
echo ""
echo -e "${GREEN}Add this TXT record to your DNS configuration${NC}"
echo ""

# Create .env file if it doesn't exist
cd ..
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cat > .env << EOF
# SMTP Server Configuration
DOMAIN=$DOMAIN
DKIM_SELECTOR=$SELECTOR
HOSTNAME=smtp.$DOMAIN

# Email sending limits (optional)
# MESSAGE_SIZE_LIMIT=10485760
EOF
    echo -e "${GREEN}✓ .env file created${NC}"
    echo ""
fi

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}  NEXT STEPS${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""
echo "1. Add the DNS TXT record shown above to your domain"
echo "2. Verify DNS propagation (may take up to 48 hours)"
echo "3. Update .env file with your domain settings"
echo "4. Run: docker-compose up -d"
echo ""
echo -e "${YELLOW}To verify DNS record:${NC}"
echo "  dig ${SELECTOR}._domainkey.${DOMAIN} TXT"
echo ""
echo -e "${GREEN}Done! Your DKIM keys are ready to use.${NC}"
