#!/usr/bin/env bash
# checks/uid0.sh - Responsable: Persona B
# Busca usuarios con UID 0 distintos de root.
# Pista: awk -F: '$3==0 {print $1}' /etc/passwd

check_uid0() {
    section "Usuarios con UID 0"
    report_info "TODO (Persona B): implementar check_uid0"
}
