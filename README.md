# AEM Dockerized Environment (AEM 6.5 & AEM SDK)

This project provides a **Dockerized setup** for running Adobe Experience Manager (AEM) 6.5 (Java 11) and AEM SDK (Java 17) in **Author** and **Publish** modes.  

It is designed for developers who want:

- Flexible choice of **AEM version** (6.5 vs SDK).
- Option to run **Author only**, **Publish only**, or **both**.
- A clean separation of **base images** (per version) and **role images** (Author/Publish).
- Persistent storage for repositories (`crx-quickstart`).
- Lightweight role-specific images (no bloated JARs baked in).
- Reproducible startup/shutdown flows.
- Easy configuration via `.env` files.

---

## 📁 Project Structure

```bash
aem-docker/
├─ docker/
│  ├─ aem65/
│  │  ├─ base.Dockerfile        # Base image (Java 11, entrypoint logic)
│  │  ├─ author.Dockerfile      # Author instance (role-specific)
│  │  └─ publish.Dockerfile     # Publish instance (role-specific)
│  └─ aemsdk/
│     ├─ base.Dockerfile        # Base image (Java 17, entrypoint logic)
│     ├─ author.Dockerfile      # SDK Author instance
│     └─ publish.Dockerfile     # SDK Publish instance
├─ aem65.compose.yml            # Compose stack for AEM 6.5
├─ aemsdk.compose.yml           # Compose stack for AEM SDK
├─ .env.aem65                   # Environment overrides for AEM 6.5
├─ .env.aemsdk                  # Environment overrides for AEM SDK
├─ artifacts/
│  ├─ aem65/
│  │  ├─ AEM_6.5_Quickstart.jar
│  │  └─ license.properties
│  └─ aem-sdk/
│     ├─ AEM_SDK_Quickstart.jar
│     └─ license.properties
└─ data/
   ├─ aem65-author/             # Persistent repo for 6.5 Author
   ├─ aem65-publish/            # Persistent repo for 6.5 Publish
   ├─ aemsdk-author/            # Persistent repo for SDK Author
   └─ aemsdk-publish/           # Persistent repo for SDK Publish
```

---

## ⚙️ Prerequisites

You need a working container runtime with Compose support. Either of these options works:

- Docker Desktop ≥ 20.10 (includes Docker Compose v2)
- Rancher Desktop ≥ 1.8 (with Docker CLI / Moby backend enabled)

**AEM artifacts** (must be downloaded from Adobe Software Distribution):

- `AEM_6.5_Quickstart.jar` + `license.properties`
- `AEM_SDK_Quickstart.jar` + `license.properties`

⚠️ **Important:** Adobe binaries are **not included** in this repo due to licensing. Place them under `artifacts/` as shown above.

---

## 📝 Environment Files

Configuration for ports and JVM heap is centralized in `.env` files.

### `.env.aem65` (example)

```env
# Ports
AEM65_AUTHOR_PORT=4502
AEM65_PUBLISH_PORT=4503

# JVM options
AEM65_JVM_OPTS=-server -Xms3g -Xmx5g -XX:+UseG1GC -Djava.awt.headless=true
```

### `.env.aemsdk` (example)

```env
# Ports
AEMSDK_AUTHOR_PORT=5502
AEMSDK_PUBLISH_PORT=5503

# JVM options
AEMSDK_JVM_OPTS=-server -Xms3g -Xmx5g -XX:+UseG1GC -Djava.awt.headless=true
```

You can override these per developer by copying to `.env` (which Compose loads automatically):

```bash
cp .env.aem65 .env
```

Then run without `--env-file`.  

---

## 🏗️ Build Images

The first time, build the base + role images:

```bash
# AEM 6.5
docker compose --env-file .env.aem65 -f aem65.compose.yml build

# AEM SDK
docker compose --env-file .env.aemsdk -f aemsdk.compose.yml build
```

---

## ▶️ Running Instances

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

---

## 🌐 Access URLs

| Version  | Role     | URL                          | Default Port |
|----------|----------|------------------------------|--------------|
| AEM 6.5  | Author   | [http://localhost:4502](http://localhost:4502)        | 4502         |
| AEM 6.5  | Publish  | [http://localhost:4503](http://localhost:4503)        | 4503         |
| AEM SDK  | Author   | [http://localhost:5502](http://localhost:5502)        | 5502         |
| AEM SDK  | Publish  | [http://localhost:5503](http://localhost:5503)        | 5503         |

---

## 💾 Persistence

- Each instance mounts `./data/...` → `/opt/aem/crx-quickstart`  
- Your repository persists between restarts/rebuilds.
- To **wipe clean**, simply delete the corresponding folder under `data/`.

---

## 🩺 Healthchecks

- Containers are marked **healthy** when `/system/console/bundles.json` responds OK.
- Healthcheck retries every 30s with a 10s timeout.

---

## 🔧 Configuration

- **Runmodes & Ports** are configured via environment variables (from `.env` files).
  - Author: `RUN_MODE=author` `PORT=4502` (or `5502` for SDK)
  - Publish: `RUN_MODE=publish` `PORT=4503` (or `5503` for SDK)

- **JVM Heap & GC** can be tuned in `.env.aem65` / `.env.aemsdk`:

  ```env
  AEM65_JVM_OPTS=-server -Xms4g -Xmx6g -XX:+UseG1GC -Djava.awt.headless=true
  ```

- **Stop grace period** is set to `3m` to allow AEM to shut down cleanly.

---

## 🛑 Stopping Containers

```bash
# Stop everything (example for AEM 6.5)
docker compose --env-file .env.aem65 -f aem65.compose.yml down

# Stop SDK author only
docker compose --env-file .env.aemsdk -f aemsdk.compose.yml stop aemsdk-author
```

---

## ❌ Cleaning Up

- Remove repositories:

  ```bash
  rm -rf data/aem65-author data/aem65-publish data/aemsdk-author data/aemsdk-publish
  ```

- Rebuild from scratch:

  ```bash
  docker compose --env-file .env.aem65 -f aem65.compose.yml build --no-cache
  docker compose --env-file .env.aemsdk -f aemsdk.compose.yml build --no-cache
  ```

---

## ⚖️ Notes

- **AEM 6.5** requires **Java 11**.
- **AEM SDK** supports **Java 11 and 17** (we use 17 by default).
- Do not bake Adobe binaries into images unless absolutely necessary (legal & size issues).
- Dispatcher support can be added via a separate container wired to Publish.

---

## 📜 License

This repository contains **Docker setup only**.  
You must provide your own licensed **AEM Quickstart jars** and **license.properties** from [Adobe Software Distribution](https://experience.adobe.com/downloads).

---

## ✅ Quick Start

For example to run AEM 6.5 Author:

1. Place your Adobe JAR + license under `artifacts/aem65/` and `artifacts/aem-sdk/`.
2. Copy env template:

   ```bash
   cp .env.aem65 .env
   ```

3. Build base + role images:

   ```bash
   docker compose -f aem65.compose.yml build
   ```

4. Start AEM:

   ```bash
   docker compose -f aem65.compose.yml --profile author up -d
   ```

5. Open <http://localhost:4502> in your browser.
