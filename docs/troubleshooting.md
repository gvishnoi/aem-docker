# 🩺 Troubleshooting & Verification

---

## 1. Check container status

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

✅ Expect port mappings like `0.0.0.0:4502->4502/tcp`.

---

## 2. Check logs

```bash
docker compose -f aem65.compose.yml logs -f aem65-author
```

Healthy:

- `[AEM] Installing/repairing via Quickstart jar...`
- `Startup completed`

Problems:

- `Unable to access jarfile` → JAR not mounted
- `Missing license.properties`
- `OutOfMemoryError` → lower heap

---

## 3. Test from inside container

```bash
docker exec -it aem65-aem65-author-1 sh -lc 'curl -I http://localhost:4502/ || true'
```

---

## 4. Test from host

```bash
curl -I http://localhost:4502/ || true
```

---

## 5. Check health

```bash
docker inspect -f '{{.State.Health.Status}}' aem65-aem65-author-1
```

Values: `healthy`, `starting`, `unhealthy`.

---

## 6. Reset broken repo

```bash
docker compose -f aem65.compose.yml stop aem65-author
rm -rf data/aem65-author/*
docker compose --env-file .env.aem65 -f aem65.compose.yml --profile author up -d --build --force-recreate
```

---

## 7. Memory tips

- Default:

  ```bash
  -Xms3g -Xmx5g
  ```

- Small laptop:

  ```bash
  -Xms2g -Xmx3g
  ```

Set in `.env.aem65`.

---

## 8. First-run delays

- First install extracts bundles → can take several minutes.
- “Startup completed” means HTTP is live.
