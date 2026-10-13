#!/usr/bin/env bash
# checks/uid0.sh - Responsable: Persona B
# Busca usuarios con UID 0 distintos de root.

check_uid0() {
    section "Usuarios con UID 0"

    local usuarios_uid0 usuario
    local extras=0

    usuarios_uid0=$(awk -F: '$3==0 {print $1}' /etc/passwd)

    while IFS= read -r usuario; do
        [[ -z "$usuario" ]] && continue

        if [[ "$usuario" != "root" ]]; then
            report_crit \
                "El usuario '$usuario' tiene UID 0 (superusuario) y no es root" \
                "Verifica si la cuenta es legítima; si no, elimínala con: userdel $usuario y revisa /var/log/auth.log"
            extras=$((extras + 1))
        fi
    done <<< "$usuarios_uid0"

    if [[ $extras -eq 0 ]]; then
        report_ok "Solo root tiene UID 0"
    fi
}
