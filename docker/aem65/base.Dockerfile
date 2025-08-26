# syntax=docker/dockerfile:1.7
FROM eclipse-temurin:11-jdk

ENV AEM_HOME=/opt/aem \
    AEM_ARTIFACTS=/opt/aem/artifacts \
    AEM_USER=aem \
    AEM_GROUP=aem \
    AEM_JAR_PATH=/opt/aem/artifacts/AEM_6.5_Quickstart.jar \
    LICENSE_FILE=/opt/aem/artifacts/license.properties \
    RUN_MODE=author \
    PORT=4502 \
    JVM_OPTS="-server -Xms3g -Xmx5g -XX:+UseG1GC -Djava.awt.headless=true" \
    HEALTHCHECK_PATH=/system/console/bundles.json

RUN groupadd -r ${AEM_GROUP} && useradd -r -g ${AEM_GROUP} -d ${AEM_HOME} ${AEM_USER} \
    && mkdir -p ${AEM_HOME} ${AEM_ARTIFACTS} \
    && chown -R ${AEM_USER}:${AEM_GROUP} ${AEM_HOME}

WORKDIR ${AEM_HOME}
USER ${AEM_USER}

# One entrypoint that handles first install vs subsequent restarts
RUN printf '%s\n' \
    '#!/usr/bin/env bash' \
    'set -euo pipefail' \
    'echo "[AEM] Run mode: ${RUN_MODE}  Port: ${PORT}"' \
    'if [ ! -d "${AEM_HOME}/crx-quickstart" ]; then' \
    '  echo "[AEM] First-time install..."' \
    '  [[ -f "${AEM_JAR_PATH}" ]] || { echo "[FATAL] Missing ${AEM_JAR_PATH}"; exit 2; }' \
    '  [[ -f "${LICENSE_FILE}" ]] || { echo "[FATAL] Missing ${LICENSE_FILE}"; exit 2; }' \
    '  cp -f "${AEM_JAR_PATH}" "${AEM_HOME}/quickstart.jar"' \
    '  cp -f "${LICENSE_FILE}" "${AEM_HOME}/license.properties"' \
    '  exec java ${JVM_OPTS} -jar "${AEM_HOME}/quickstart.jar" -v -nobrowser -nofork -r "${RUN_MODE}" -p "${PORT}"' \
    'else' \
    '  echo "[AEM] Repository exists. Starting..."' \
    '  if [ -x "${AEM_HOME}/crx-quickstart/bin/start" ]; then' \
    '    exec "${AEM_HOME}/crx-quickstart/bin/start"' \
    '  else' \
    '    exec java ${JVM_OPTS} -jar "${AEM_HOME}/quickstart.jar" -v -nobrowser -nofork -r "${RUN_MODE}" -p "${PORT}"' \
    '  fi' \
    'fi' \
    > /opt/aem/entrypoint.sh && chmod +x /opt/aem/entrypoint.sh

EXPOSE 4502 4503
HEALTHCHECK --interval=30s --timeout=10s --retries=20 CMD \
    curl -fsS "http://localhost:${PORT}${HEALTHCHECK_PATH}" >/dev/null || exit 1

ENTRYPOINT ["/opt/aem/entrypoint.sh"]
