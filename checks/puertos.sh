#!/usr/bin/env bash
# checks/puertos.sh - Responsable: Persona B
# Analiza puertos en escucha con ss -tuln.
# OJO: no uses "comando | while read ..." porque corre en un subshell y
# los contadores de report_* se pierden. Usa: while read ...; done < <(comando)

check_puertos() {
    section "Puertos abiertos"
    report_info "TODO (Persona B): implementar check_puertos"
}
