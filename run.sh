#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       ComfyGo - One-Click Start      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ─── Cleanup on exit ──────────────────────────────────────────────
cleanup() {
    echo ""
    echo "Shutting down..."
    if [ -n "$BACKEND_PID" ]; then
        kill "$BACKEND_PID" 2>/dev/null || true
        echo "Backend stopped."
    fi
}
trap cleanup EXIT INT TERM

# ─── Check prerequisites ─────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo "[ERROR] Python3 not found. Please install Python 3.10+"
    exit 1
fi

if ! command -v flutter &>/dev/null; then
    echo "[ERROR] Flutter not found. Please install Flutter SDK."
    exit 1
fi

# ─── Backend ─────────────────────────────────────────────────────
echo "[1/4] Setting up backend..."
cd "$SCRIPT_DIR/backend"

if [ ! -d "venv" ]; then
    echo "      Creating Python virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate

echo "[2/4] Installing Python dependencies..."
pip install -r requirements.txt --quiet

echo "[3/4] Starting backend server on http://localhost:8000 ..."
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

# Wait for backend to be ready
echo "      Waiting for backend to start..."
sleep 3

# ─── Frontend ────────────────────────────────────────────────────
cd "$SCRIPT_DIR"

echo "[4/4] Starting Flutter frontend..."
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  Backend  : http://localhost:8000     ║"
echo "║  Frontend : flutter run               ║"
echo "║                                      ║"
echo "║  Press Ctrl+C to stop everything.    ║"
echo "╚══════════════════════════════════════╝"
echo ""

flutter run
