# ▶️ Running AEM Instances

This repo supports **AEM 6.5** and **AEM SDK**.

All commands assume you are in the project root and pass the correct `--env-file`  
(`.env.aem65` or `.env.aemsdk`).  

## 🔨 Build Images

```bash
# AEM 6.5
docker compose --env-file .env.aem65 -f aem65.compose.yml build

# AEM SDK
docker compose --env-file .env.aemsdk -f aemsdk.compose.yml build
```

Rebuild from scratch (no cached layers):

```bash
docker compose --env-file .env.aem65 -f aem65.compose.yml build --no-cache
```

## 🚀 Start Containers

### AEM 6.5

- **Author only**

  ```bash
  docker compose --env-file .env.aem65 -f aem65.compose.yml --profile author up -d
  ```

- **Publish only**

  ```bash
  docker compose --env-file .env.aem65 -f aem65.compose.yml --profile publish up -d
  ```

- **Both Author + Publish**

  ```bash
  docker compose --env-file .env.aem65 -f aem65.compose.yml --profile all up -d
  ```

### AEM SDK

- **Author only**

  ```bash
  docker compose --env-file .env.aemsdk -f aemsdk.compose.yml --profile author up -d
  ```

- **Publish only**

  ```bash
  docker compose --env-file .env.aemsdk -f aemsdk.compose.yml --profile publish up -d
  ```

- **Both Author + Publish**

  ```bash
  docker compose --env-file .env.aemsdk -f aemsdk.compose.yml --profile all up -d
  ```

**Please note: the first startup may take several minutes** as AEM initializes and installs packages. Use the logs command below to monitor progress.

```bash
# Follow Author logs
docker compose --env-file .env.aem65 -f aem65.compose.yml logs -f aem65-author

# Follow Publish logs (SDK)
docker compose --env-file .env.aemsdk -f aemsdk.compose.yml logs -f aemsdk-publish
```

Once you see `Quickstart Started` in the logs, AEM is ready. See the sample logs below:

```text
aem65-author-1  | Attempting to load ESAPI.properties via file I/O.
aem65-author-1  | Attempting to load ESAPI.properties as resource file via file I/O.
aem65-author-1  | Not found in 'org.owasp.esapi.resources' directory or file not readable: /opt/aem/ESAPI.properties
aem65-author-1  | Not found in SystemResource Directory/resourceDirectory: .esapi/ESAPI.properties
aem65-author-1  | Not found in 'user.home' (/opt/aem) directory: /opt/aem/esapi/ESAPI.properties
aem65-author-1  | Loading ESAPI.properties via file I/O failed. Exception was: java.io.FileNotFoundException
aem65-author-1  | Attempting to load ESAPI.properties via the classpath.
aem65-author-1  | SUCCESSFULLY LOADED ESAPI.properties via the CLASSPATH from '/ (root)' using class loader for DefaultSecurityConfiguration class!
aem65-author-1  | Attempting to load validation.properties via file I/O.
aem65-author-1  | Attempting to load validation.properties as resource file via file I/O.
aem65-author-1  | Not found in 'org.owasp.esapi.resources' directory or file not readable: /opt/aem/validation.properties
aem65-author-1  | Not found in SystemResource Directory/resourceDirectory: .esapi/validation.properties
aem65-author-1  | Not found in 'user.home' (/opt/aem) directory: /opt/aem/esapi/validation.properties
aem65-author-1  | Loading validation.properties via file I/O failed.
aem65-author-1  | Attempting to load validation.properties via the classpath.
aem65-author-1  | SUCCESSFULLY LOADED validation.properties via the CLASSPATH from '/ (root)' using class loader for DefaultSecurityConfiguration class!
aem65-author-1  | Warning: Nashorn engine is planned to be removed from a future JDK release
aem65-author-1  | Warning: Nashorn engine is planned to be removed from a future JDK release
aem65-author-1  | Browser opening disabled by nobrowser option
aem65-author-1  | Installation time:474 seconds
aem65-author-1  | http://localhost:4502/
aem65-author-1  | Quickstart started
```

## 🌐 Access URLs

| Version  | Role     | URL                               | Port |
|----------|----------|-----------------------------------|------|
| AEM 6.5  | Author   | [http://localhost:4502](http://localhost:4502)             | 4502 |
| AEM 6.5  | Publish  | [http://localhost:4503](http://localhost:4503)             | 4503 |
| AEM SDK  | Author   | [http://localhost:5502](http://localhost:5502)             | 5502 |
| AEM SDK  | Publish  | [http://localhost:5503](http://localhost:5503)             | 5503 |

Login: `admin / admin`

## ⏹️ Stopping Containers

```bash
# Stop everything (example AEM 6.5)
docker compose --env-file .env.aem65 -f aem65.compose.yml down

# Stop SDK Author only
docker compose --env-file .env.aemsdk -f aemsdk.compose.yml stop aemsdk-author

# Stop only 6.5 Publish
docker compose --env-file .env.aem65 -f aem65.compose.yml stop aem65-publish
```

## 🔄 Restart Containers

```bash
# Restart AEM 6.5 Author
docker compose --env-file .env.aem65 -f aem65.compose.yml restart aem65-author
```

## 📜 View Logs

```bash
# Follow Author logs
docker compose --env-file .env.aem65 -f aem65.compose.yml logs -f aem65-author

# Follow Publish logs (SDK)
docker compose --env-file .env.aemsdk -f aemsdk.compose.yml logs -f aemsdk-publish
```

## 🩺 Check Status

```bash
# Show running containers and mapped ports
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

## 🧹 Wipe Data (fresh repo install)

⚠️ This deletes your local CRX repository and forces a fresh install.

```bash
rm -rf data/aem65-author data/aem65-publish
rm -rf data/aemsdk-author data/aemsdk-publish
```

Then restart Author/Publish.

## ❌ Cleaning Up

⚠️ This deletes your local CRX repository and forces a fresh install.

```bash
rm -rf data/aem65-author data/aem65-publish
rm -rf data/aemsdk-author data/aemsdk-publish
```

## Rebuild from scratch

  ```bash
  docker compose --env-file .env.aem65 -f aem65.compose.yml build --no-cache
  docker compose --env-file .env.aemsdk -f aemsdk.compose.yml build --no-cache
  ```

## ✅ Summary

- Use `--env-file` for **all commands** if you keep `.env.aem65` / `.env.aemsdk` separate.  
- Use `docker ps` to verify ports.  
- Use `logs -f` to check installation progress.  
- Delete `data/` folders if the repo is corrupted.  
