# Base image for AEM SDK (Java 17)
FROM eclipse-temurin:17-jdk

# Create AEM user and directories
RUN groupadd -r aem && useradd -r -g aem -d /opt/aem aem \
    && mkdir -p /opt/aem /opt/aem/artifacts \
    && chown -R aem:aem /opt/aem

WORKDIR /opt/aem
USER aem

# Environment defaults (override via compose/env-file)
ENV AEM_HOME=/opt/aem \
    RUN_MODE=author \
    PORT=5502 \
    JVM_OPTS="-server -Xms3g -Xmx5g -XX:+UseG1GC -Djava.awt.headless=true" \
    AEM_JAR_PATH=/opt/aem/artifacts/AEM_SDK_Quickstart.jar \
    LICENSE_FILE=/opt/aem/artifacts/license.properties

# Entrypoint: if a proper repo exists use its start script; otherwise install/repair via JAR
RUN printf '%s\n' \
    '#!/usr/bin/env bash' \
    'set -euo pipefail' \
    'echo "[AEM SDK] Run mode: ${RUN_MODE}  Port: ${PORT}"' \
    'if [ -x "${AEM_HOME}/crx-quickstart/bin/start" ]; then' \
    '  echo "[AEM SDK] start script found. Starting..."; exec "${AEM_HOME}/crx-quickstart/bin/start"' \
    'else' \
    '  echo "[AEM SDK] Installing/repairing via Quickstart jar..."' \
    '  [[ -f "${AEM_JAR_PATH}" ]] || { echo "[FATAL] Missing JAR at ${AEM_JAR_PATH}"; exit 2; }' \
    '  [[ -f "${LICENSE_FILE}" ]] || { echo "[FATAL] Missing license.properties at ${LICENSE_FILE}"; exit 2; }' \
    '  cp -f "${AEM_JAR_PATH}" "${AEM_HOME}/quickstart.jar"' \
    '  cp -f "${LICENSE_FILE}" "${AEM_HOME}/license.properties"' \
    '  exec java ${JVM_OPTS} -jar "${AEM_HOME}/quickstart.jar" -v -nobrowser -nofork -r "${RUN_MODE}" -p "${PORT}"' \
    'fi' \
    > /opt/aem/entrypoint.sh && chmod +x /opt/aem/entrypoint.sh

ENTRYPOINT ["/opt/aem/entrypoint.sh"]

# Healthcheck (public login page -> no auth needed)
HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=5 \
    CMD curl -f http://localhost:${PORT}/libs/granite/core/content/login.html || exit 1
