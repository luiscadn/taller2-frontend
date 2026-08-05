#!/usr/bin/env bash
# ==============================================================================
# Script de Despliegue Automatizado - Taller 2 DevOps: taller2-frontend
# Universidad ICESI - Despliegue sin requerir privilegios sudo
# ==============================================================================

set -e

PORT=${PORT:-3000}
BACKEND_URL=${BACKEND_URL:-"http://localhost:8080"}
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$APP_DIR"

echo "=== [1/5] Iniciando despliegue de taller2-frontend en puerto $PORT ==="
echo "Target Backend URL: $BACKEND_URL"

# ------------------------------------------------------------------------------
# 1. Verificación de Red / Firewall (Sin requerir sudo)
# ------------------------------------------------------------------------------
echo "=== [2/5] Verificación de Red ==="
echo "[INFO] Omitiendo configuración de UFW/sudo (despliegue en entorno sin privilegios root, firewall desactivado)."

# ------------------------------------------------------------------------------
# 2. Verificación de Node.js y Dependencias
# ------------------------------------------------------------------------------
echo "=== [3/5] Verificando Entorno de Node.js y npm ==="
if ! command -v node > /dev/null 2>&1; then
    echo "[ERROR] Node.js no está instalado. Por favor instale Node.js 18+ antes de continuar."
    exit 1
fi

if ! command -v npm > /dev/null 2>&1; then
    echo "[ERROR] npm no está instalado."
    exit 1
fi

echo "Instalando dependencias de Node.js..."
npm install --quiet

# ------------------------------------------------------------------------------
# 3. Detener instancias previas y Ejecutar Servidor Frontend (nohup)
# ------------------------------------------------------------------------------
echo "=== [4/5] Liberando puerto $PORT y arrancando Frontend ==="

PID=$(lsof -ti:$PORT || true)
if [ -n "$PID" ]; then
    echo "Deteniendo proceso previo en puerto $PORT (PID: $PID)..."
    kill -9 $PID || true
    sleep 1
fi

export PORT=$PORT
export BACKEND_URL=$BACKEND_URL

echo "=== [5/5] Ejecutando servidor Node.js en segundo plano ==="
nohup node server.js > frontend.log 2>&1 &
NEW_PID=$!

sleep 2

if ps -p $NEW_PID > /dev/null; then
    echo "=========================================================================="
    echo "🌐 ¡DESPLIEGUE EXITOSO DE taller2-frontend!"
    echo "PID del Proceso: $NEW_PID"
    echo "URL Aplicación:  http://localhost:$PORT"
    echo "Status / Health: http://localhost:$PORT/status"
    echo "Log de Salida:   $APP_DIR/frontend.log"
    echo "=========================================================================="
else
    echo "[ERROR] El servidor frontend falló al iniciar. Revisa $APP_DIR/frontend.log para más detalles."
    cat frontend.log
    exit 1
fi
