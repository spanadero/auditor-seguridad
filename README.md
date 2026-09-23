# Auditor básico de seguridad (Debian)

Script en Bash que revisa:
- Permisos de archivos sensibles (`/etc/shadow`, `/etc/passwd`, ...)
- Usuarios con UID 0
- Puertos abiertos (`ss -tuln`)

y genera un reporte de hallazgos con recomendaciones de hardening.

## Uso
```bash
sudo ./auditor.sh
```
Los reportes se guardan en `reports/`.

## Estructura
- `auditor.sh`: script principal
- `lib/common.sh`: funciones compartidas (`report_ok`, `report_warn`, `report_crit`)
- `checks/`: un módulo por verificación

## Equipo
| Integrante | Responsabilidad |
|---|---|
| A | checks/permisos.sh |
| B | checks/uid0.sh, checks/puertos.sh |
| C | auditor.sh, lib/common.sh, README, pruebas |
