#!/usr/bin/env bash
# lib/common.sh - Funciones compartidas por todos los módulos.
# Este archivo se "source"-ea desde auditor.sh; no se ejecuta solo.
#
# CONTRATO PARA LOS MÓDULOS (checks/*.sh):
#   report_ok   "mensaje"
#   report_warn "mensaje" "recomendación"
#   report_crit "mensaje" "recomendación"
#   report_info "mensaje"          (no cuenta en el resumen)
#   section     "Título de sección"

COUNT_OK=0
COUNT_WARN=0
COUNT_CRIT=0
REPORT_FILE="${REPORT_FILE:-/dev/null}"

# Colores solo si la salida es una terminal
if [[ -t 1 ]]; then
    GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'; BLUE=$'\e[34m'; NC=$'\e[0m'
else
    GREEN=""; YELLOW=""; RED=""; BLUE=""; NC=""
fi

# _emit NIVEL COLOR MENSAJE [RECOMENDACION]
_emit() {
    local level="$1" color="$2" msg="$3" rec="${4:-}"
    printf '%s[%s]%s %s\n' "$color" "$level" "$NC" "$msg"
    printf '[%s] %s\n' "$level" "$msg" >> "$REPORT_FILE"
    if [[ -n "$rec" ]]; then
        printf '       -> Recomendación: %s\n' "$rec"
        printf '       -> Recomendación: %s\n' "$rec" >> "$REPORT_FILE"
    fi
}

report_ok()   { COUNT_OK=$((COUNT_OK + 1));     _emit "OK"      "$GREEN"  "$1"; }
report_warn() { COUNT_WARN=$((COUNT_WARN + 1)); _emit "MEDIO"   "$YELLOW" "$1" "${2:-}"; }
report_crit() { COUNT_CRIT=$((COUNT_CRIT + 1)); _emit "CRÍTICO" "$RED"    "$1" "${2:-}"; }
report_info() { _emit "INFO" "$BLUE" "$1"; }

section() {
    printf '\n%s== %s ==%s\n' "$BLUE" "$1" "$NC"
    printf '\n== %s ==\n' "$1" >> "$REPORT_FILE"
}

report_header() {
    local line
    line="Auditor básico de seguridad | Host: $(hostname) | Fecha: $(date '+%F %T')"
    echo "$line"
    echo "$line" >> "$REPORT_FILE"
}

report_summary() {
    section "RESUMEN"
    local total=$((COUNT_OK + COUNT_WARN + COUNT_CRIT))
    local nivel="BAJO"

    if [[ $COUNT_CRIT -gt 0 ]]; then
        nivel="ALTO"
    elif [[ $COUNT_WARN -gt 0 ]]; then
        nivel="MEDIO"
    fi

    {
        echo "Total de verificaciones: $total"
        echo "  OK:      $COUNT_OK"
        echo "  MEDIO:   $COUNT_WARN"
        echo "  CRÍTICO: $COUNT_CRIT"
        echo ""
        local color_nivel="$GREEN"
        [[ "$nivel" == "MEDIO" ]] && color_nivel="$YELLOW"
        [[ "$nivel" == "ALTO" ]] && color_nivel="$RED"
        printf '%sNivel de riesgo del sistema: %s%s\n' "$color_nivel" "$nivel" "$NC"
    } | tee -a "$REPORT_FILE"
}
