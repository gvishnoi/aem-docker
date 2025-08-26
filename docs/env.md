# ⚙️ Environment Variables

All runtime settings are centralized in `.env` files.

- **Runmodes & Ports** are configured via environment variables (from `.env` files).
  - Author: `RUN_MODE=author` `PORT=4502` (or `5502` for SDK)
  - Publish: `RUN_MODE=publish` `PORT=4503` (or `5503` for SDK)

- **JVM Heap & GC** can be tuned in `.env.aem65` / `.env.aemsdk`:

  ```env
  AEM65_JVM_OPTS=-server -Xms4g -Xmx6g -XX:+UseG1GC -Djava.awt.headless=true
  ```

- **Stop grace period** is set to `3m` to allow AEM to shut down cleanly.

---

## Example: `.env.aem65`

```env
# AEM 6.5 ports
AEM65_AUTHOR_PORT=4502
AEM65_PUBLISH_PORT=4503

# JVM options
AEM65_JVM_OPTS=-server -Xms3g -Xmx5g -XX:+UseG1GC -Djava.awt.headless=true
```

---

## Example: `.env.aemsdk`

```env
# AEM SDK ports
AEMSDK_AUTHOR_PORT=5502
AEMSDK_PUBLISH_PORT=5503

# JVM options
AEMSDK_JVM_OPTS=-server -Xms3g -Xmx5g -XX:+UseG1GC -Djava.awt.headless=true
```

---

## Usage

Pass env file to compose:

```bash
docker compose --env-file .env.aem65 -f aem65.compose.yml --profile author up -d
```

Or copy to `.env` in repo root for auto-loading:

```bash
cp .env.aem65 .env
```
