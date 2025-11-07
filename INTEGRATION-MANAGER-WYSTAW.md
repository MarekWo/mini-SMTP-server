# Integracja z projektem Manager-Wystaw

Ten przewodnik pokazuje jak zintegrować mini-SMTP-server z projektem [Manager-Wystaw](https://github.com/MarekWo/Manager-Wystaw).

## Metoda 1: Wykorzystanie istniejącej sieci Manager-Wystaw (Zalecane)

### Krok 1: Sprawdź nazwę sieci Manager-Wystaw

```bash
cd /path/to/Manager-Wystaw
docker compose ps
docker network ls | grep manager-wystaw
```

Typowa nazwa sieci: `manager-wystaw_default`

### Krok 2: Skonfiguruj mini-SMTP-server

W pliku `mini-SMTP-server/.env`:

```env
DOMAIN=grupa-lumen.pl
DKIM_SELECTOR=key002
HOSTNAME=smtp.grupa-lumen.pl
NETWORK_NAME=manager-wystaw_default  # ← Nazwa sieci z Manager-Wystaw
TEST_EMAIL=your-email@example.com
```

### Krok 3: Uruchom mini-SMTP-server

```bash
cd /path/to/mini-SMTP-server
docker compose up -d
```

Mini-SMTP-server dołączy automatycznie do sieci `manager-wystaw_default`.

### Krok 4: Skonfiguruj Manager-Wystaw do wysyłki emaili

W projekcie Manager-Wystaw, zaktualizuj konfigurację SMTP:

```env
# .env w Manager-Wystaw
SMTP_HOST=smtp
SMTP_PORT=25
SMTP_FROM=noreply@grupa-lumen.pl
```

Jeśli Manager-Wystaw używa Node.js/Nodemailer:

```javascript
// W konfiguracji emaila
const transporter = nodemailer.createTransport({
  host: 'smtp',
  port: 25,
  secure: false
});
```

### Krok 5: Testowanie

Wyślij testowy email z mini-SMTP-server:

```bash
cd /path/to/mini-SMTP-server
docker compose -f docker-compose.yml -f docker-compose.test.yml up test-mailer
```

Następnie przetestuj wysyłkę z aplikacji Manager-Wystaw.

## Metoda 2: Dedykowana sieć mail-network

Jeśli wolisz użyć dedykowanej sieci dla poczty:

### Krok 1: Użyj domyślnej konfiguracji mini-SMTP-server

```env
# mini-SMTP-server/.env
NETWORK_NAME=mail-network
```

### Krok 2: Zaktualizuj docker-compose.yml w Manager-Wystaw

Dodaj do `docker-compose.yml`:

```yaml
services:
  your-app:
    # ... istniejąca konfiguracja ...
    environment:
      - SMTP_HOST=smtp
      - SMTP_PORT=25
    networks:
      - default
      - mail-network  # ← Dodaj drugą sieć

networks:
  mail-network:
    external: true
    name: mail-network
```

## Weryfikacja połączenia

### Test 1: Sprawdź czy kontenery widzą się nawzajem

```bash
# Z kontenera Manager-Wystaw
docker exec manager-wystaw-container ping smtp

# Z kontenera mini-SMTP-server
docker exec mini-smtp-server ping manager-wystaw-container
```

### Test 2: Sprawdź sieci

```bash
# Lista sieci
docker network ls

# Szczegóły sieci
docker network inspect manager-wystaw_default
# lub
docker network inspect mail-network
```

Powinieneś zobaczyć oba kontenery w tej samej sieci.

### Test 3: Wyślij testowy email

Z poziomu Manager-Wystaw wyślij testowy email i sprawdź logi:

```bash
# Logi mini-SMTP-server
docker logs mini-smtp-server -f

# Szukaj wpisów o wysyłce
docker logs mini-smtp-server | grep "status=sent"
```

## Troubleshooting

### Problem: Kontenery nie mogą się połączyć

**Rozwiązanie:**
1. Sprawdź czy oba kontenery są w tej samej sieci:
   ```bash
   docker network inspect manager-wystaw_default
   ```

2. Zrestartuj kontenery:
   ```bash
   docker compose restart
   ```

### Problem: "Connection refused" na porcie 25

**Rozwiązanie:**
1. Sprawdź czy mini-SMTP-server działa:
   ```bash
   docker ps | grep mini-smtp-server
   ```

2. Sprawdź logi:
   ```bash
   docker logs mini-smtp-server
   ```

3. Upewnij się że używasz nazwy kontenera `smtp`, nie `localhost` ani `127.0.0.1`

### Problem: DKIM validation fails

**Rozwiązanie:**
1. Sprawdź DNS:
   ```bash
   dig key002._domainkey.grupa-lumen.pl TXT
   ```

2. Weryfikuj klucze w kontenerze:
   ```bash
   docker exec mini-smtp-server ls -la /etc/opendkim/keys/
   ```

## Przykładowa struktura katalogów

```
projekty/
├── Manager-Wystaw/
│   ├── docker-compose.yml
│   ├── .env
│   └── ... (aplikacja)
└── mini-SMTP-server/
    ├── docker-compose.yml
    ├── .env (z NETWORK_NAME=manager-wystaw_default)
    ├── dkim/
    │   ├── key002.private
    │   └── key002.txt
    └── ...
```

## Zalety tej integracji

✅ **Brak zewnętrznych usług SMTP** - wszystko w Dockerze
✅ **Pełne DKIM** - profesjonalne podpisywanie emaili
✅ **Izolacja** - dedykowany kontener dla poczty
✅ **Reużywalność** - ten sam SMTP dla wielu projektów
✅ **Łatwa konfiguracja** - tylko jedna zmienna `NETWORK_NAME`

---

**Gotowe!** Twój projekt Manager-Wystaw może teraz wysyłać emaile z pełnym wsparciem DKIM. 🎉
