#!/usr/bin/env bash
# checks/permisos.sh - Responsable: spanadero
# Revisa permisos y dueño de archivos sensibles del sistema.

_check_un_archivo() {
    local ruta="$1"
    local permisos_esperados="$2"
    local dueno_esperado="$3"

    if [[ ! -e "$ruta" ]]; then
        report_info "$ruta no existe en este sistema, se omite"
        return
    fi

    local permisos_actuales dueno_actual
    permisos_actuales=$(stat -c '%a' "$ruta")
    dueno_actual=$(stat -c '%U:%G' "$ruta")

    if [[ "$permisos_actuales" == "$permisos_esperados" && "$dueno_actual" == "$dueno_esperado" ]]; then
        report_ok "$ruta tiene permisos correctos ($permisos_actuales, $dueno_actual)"
    else
        report_crit \
            "$ruta tiene permisos $permisos_actuales ($dueno_actual), se esperaba $permisos_esperados ($dueno_esperado)" \
            "chmod $permisos_esperados $ruta && chown $dueno_esperado $ruta"
    fi
}

check_permisos() {
    section "Permisos de archivos sensibles"

    _check_un_archivo "/etc/shadow"          "640" "root:shadow"
    _check_un_archivo "/etc/gshadow"         "640" "root:shadow"
    _check_un_archivo "/etc/passwd"          "644" "root:root"
    _check_un_archivo "/etc/group"           "644" "root:root"
    _check_un_archivo "/etc/sudoers"         "440" "root:root"
    _check_un_archivo "/etc/ssh/sshd_config" "644" "root:root"
}
