# Auditor básico de seguridad (Debian)

Script en Bash para Debian/Linux que revisa configuraciones de
seguridad del sistema y genera un reporte de hallazgos con
recomendaciones de hardening (endurecimiento de seguridad).

## Qué revisa

1. **Permisos de archivos sensibles** (`/etc/shadow`, `/etc/passwd`,
   `/etc/group`, `/etc/sudoers`, `/etc/ssh/sshd_config`): compara
   permisos y dueño reales contra los esperados.
2. **Usuarios con UID 0**: solo `root` debería tener UID 0. Otro
   usuario con ese UID es una señal de puerta trasera.
3. **Puertos de red abiertos** (`ss -tuln`): detecta qué puertos
   están escuchando y si están expuestos a toda la red.

## Severidades

| Nivel | Significado |
|---|---|
| `OK` | La configuración es correcta |
| `MEDIO` | Riesgo a revisar, no crítico |
| `CRÍTICO` | Riesgo de seguridad grave, requiere corrección inmediata |

El resumen final también calcula un **nivel de riesgo general**
del sistema (BAJO / MEDIO / ALTO) según los hallazgos encontrados.

## Uso

```bash
sudo ./auditor.sh
```

Requiere `sudo` porque necesita leer `/etc/shadow`. El reporte se
guarda en `reports/reporte_FECHA.txt`.

## Estructura del proyecto
auditor-seguridad/
├── auditor.sh # script principal
├── lib/common.sh # funciones compartidas (report_ok, report_warn, report_crit)
├── checks/
│ ├── permisos.sh # revisión de permisos de archivos sensibles
│ ├── uid0.sh # revisión de usuarios con UID 0
│ └── puertos.sh # revisión de puertos abiertos
├── reports/ # reportes generados (no se sube a git)
└── docs/ # documentación de hardening


## Equipo

| Integrante | Responsabilidad |
|---|---|
| [Santiago Panadero] | `auditor.sh`, `lib/common.sh`, integración, README |
| [Andres Barrios] | `checks/uid0.sh` |
| [Samuel Rodriguez] | `checks/puertos.sh` |

## Requisitos

- Debian/Linux (o WSL con Debian)
- Bash
- `coreutils`, `iproute2` (trae `ss`, viene instalado por defecto en Debian)
