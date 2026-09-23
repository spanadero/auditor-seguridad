#!/usr/bin/env bash
# auditor.sh - Script principal. Responsable: Persona C
# Uso: sudo ./auditor.sh

set -u
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "Este script necesita permisos de root (lee /etc/shadow). Usa: sudo $0" >&2
    exit 1
fi

mkdir -p "$BASE_DIR/reports"
REPORT_FILE="$BASE_DIR/reports/reporte_$(date +%Y%m%d_%H%M%S).txt"
: > "$REPORT_FILE"

# shellcheck source=lib/common.sh
source "$BASE_DIR/lib/common.sh"
source "$BASE_DIR/checks/permisos.sh"
source "$BASE_DIR/checks/uid0.sh"
source "$BASE_DIR/checks/puertos.sh"

report_header
check_permisos
check_uid0
check_puertos
report_summary

echo
echo "Reporte guardado en: $REPORT_FILE"
