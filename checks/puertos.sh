#!/usr/bin/env bash
# =============================================================================
# checks/puertos.sh - Responsable: Persona B
# Analiza puertos en escucha con ss -tuln.
#
# Lista los puertos abiertos con "ss -tuln" y distingue:
#   - Puertos solo locales (127.x.x.x o ::1): solo accesibles desde la máquina.
#   - Puertos expuestos (0.0.0.0, ::, * u otra IP): accesibles desde la red.
# Si un puerto sensible (FTP, Telnet, MySQL, PostgreSQL) está expuesto -> WARN.
#
# Usa las funciones de lib/common.sh (las carga auditor.sh, no este archivo):
#   section, report_ok, report_warn, report_crit, report_info
# =============================================================================

check_puertos() {
    section "Puertos abiertos"

    # Comprobar que el comando ss exista antes de usarlo
    if ! command -v ss >/dev/null 2>&1; then
        report_warn "No se encontró el comando 'ss'; no se pudieron revisar los puertos." \
            "Instale el paquete iproute2: sudo apt install iproute2"
        return
    fi

    # Variables para cada columna de la salida de ss
    local netid estado recvq sendq local_addr resto
    # Variables que calculamos nosotros
    local ip puerto servicio recomendacion alcance
    # Contadores
    local total=0 expuestos=0 locales=0 riesgosos=0

    # ss -tuln:  -t TCP, -u UDP, -l solo en escucha, -n números (no nombres)
    # Cada línea se parte en columnas; la 5.ª es "Dirección:Puerto" local.
    while read -r netid estado recvq sendq local_addr resto; do
        # Saltar la línea de encabezado ("Netid State ...") y líneas raras
        [[ "$netid" == "Netid" || -z "$local_addr" ]] && continue

        total=$((total + 1))

        # --- Separar IP y puerto -------------------------------------------
        # Ejemplos de local_addr:  0.0.0.0:22   [::]:22   127.0.0.53%lo:53
        puerto="${local_addr##*:}"   # todo lo que va después del ÚLTIMO ":"
        ip="${local_addr%:*}"        # todo lo que va antes del ÚLTIMO ":"
        ip="${ip%%\%*}"              # quitar "%lo" (nombre de interfaz) si hay
        ip="${ip#\[}"                # quitar "[" inicial (direcciones IPv6)
        ip="${ip%\]}"                # quitar "]" final

        # --- ¿Es un puerto sensible? ----------------------------------------
        servicio=""
        recomendacion=""
        case "$puerto" in
            21)
                servicio="FTP"
                recomendacion="FTP envía contraseñas sin cifrar. Use SFTP (incluido en SSH) y desactive el servidor FTP, por ejemplo: sudo systemctl disable --now vsftpd"
                ;;
            23)
                servicio="Telnet"
                recomendacion="Telnet no cifra nada. Reemplácelo por SSH y desinstale el servidor: sudo apt purge telnetd"
                ;;
            3306)
                servicio="MySQL/MariaDB"
                recomendacion="Si solo lo usa esta máquina, ponga 'bind-address = 127.0.0.1' en la configuración de MySQL/MariaDB y reinicie el servicio; si debe ser remoto, restrinja el acceso con un firewall (ufw)."
                ;;
            5432)
                servicio="PostgreSQL"
                recomendacion="Ponga listen_addresses = 'localhost' en postgresql.conf, o limite qué IPs pueden conectarse en pg_hba.conf y con un firewall (ufw)."
                ;;
        esac

        # --- ¿Local o expuesto? ---------------------------------------------
        if [[ "$ip" == 127.* || "$ip" == "::1" ]]; then
            # Solo accesible desde la propia máquina: no es riesgo de red
            locales=$((locales + 1))
            if [[ -n "$servicio" ]]; then
                report_ok "$servicio (puerto $netid/$puerto) solo escucha en local ($ip)."
            else
                report_info "Puerto $netid/$puerto escuchando solo en local ($ip)."
            fi
        else
            # Accesible desde la red
            expuestos=$((expuestos + 1))
            if [[ "$ip" == "0.0.0.0" || "$ip" == "::" || "$ip" == "*" ]]; then
                alcance="todas las interfaces de red"
            else
                alcance="la interfaz $ip"
            fi

            if [[ -n "$servicio" ]]; then
                riesgosos=$((riesgosos + 1))
                report_warn "$servicio (puerto $netid/$puerto) está expuesto en $alcance." \
                    "$recomendacion"
            else
                report_info "Puerto $netid/$puerto escuchando en $alcance."
            fi
        fi
    done < <(ss -tuln)

    # --- Resumen de la revisión ---------------------------------------------
    if (( total == 0 )); then
        report_info "No se encontraron puertos en escucha."
        return
    fi

    report_info "Resumen: $total puertos en escucha ($expuestos expuestos a la red, $locales solo locales)."

    if (( riesgosos == 0 )); then
        report_ok "Ningún puerto sensible (FTP, Telnet, MySQL, PostgreSQL) está expuesto a la red."
    fi
}
