# Despliegue controlado de API .NET (Blue/Green) con plan de reversión — Local

Este repositorio implementa un despliegue controlado de una **API .NET** en entorno **local** aplicando estrategia **Blue/Green**, con verificación post-despliegue (smoke tests, /health, /readiness, latencia p95) y **rollback** documentado y ejecutado.

---

## Contenido principal

### Documentos (entrega)
- **Informe técnico (máx. 1 página):** docs/informe.md
- **Índice de evidencias (capturas y archivos):** docs/evidencias.md
- **Documentación completa del proyecto:** docs/DOCUMENTACION_PROYECTO.md
- **Capturas:** docs/capturas/

### Código y despliegue
- API: src/MyApi/
- Dockerfile: src/MyApi/Dockerfile
- Blue/Green + Router: deploy/docker-compose.bluegreen.yml + deploy/default.conf
- Scripts de conmutación/rollback: deploy/scripts/*.ps1
- Pipeline CI (GitHub Actions): .github/workflows/ci-cd.yml

---

## Requisitos
- .NET SDK (el proyecto fue generado con 
et10.0).
- Docker Desktop (Linux containers) y Docker Compose.
- Git.
- Windows PowerShell.

Verificación:
- dotnet --version
- docker version
- docker compose version

---

## Ejecución local (sin Docker)
Desde la raíz del repositorio:

- Ejecutar:
  - dotnet run --project src/MyApi/MyApi.csproj

La API escucha en:
- http://localhost:5000 (configurado en src/MyApi/Properties/launchSettings.json)

Probar endpoints:
- iwr http://localhost:5000/health -UseBasicParsing
- iwr http://localhost:5000/readiness -UseBasicParsing

---

## Despliegue Blue/Green (Docker)
Levantar el stack:

- docker compose -f deploy/docker-compose.bluegreen.yml up -d --build

Servicios:
- Router (Nginx): http://localhost:8080
- Blue: http://localhost:8081
- Green: http://localhost:8082

Verificación post-despliegue:
- iwr http://localhost:8080/health -UseBasicParsing
- iwr http://localhost:8080/readiness -UseBasicParsing
- iwr http://localhost:8081/health -UseBasicParsing
- iwr http://localhost:8082/health -UseBasicParsing

Apagar:
- docker compose -f deploy/docker-compose.bluegreen.yml down

---

## Conmutación y rollback (plan de reversión)
Scripts (PowerShell):
- Conmutar a GREEN:
  - powershell -ExecutionPolicy Bypass -File deploy/scripts/switch-to-green.ps1
- Volver a BLUE (rollback):
  - powershell -ExecutionPolicy Bypass -File deploy/scripts/rollback.ps1

---

## Configuración por ambiente y secretos
Ambientes soportados:
- Staging: src/MyApi/appsettings.Staging.json
- Production: src/MyApi/appsettings.Production.json

Secretos:
- .env **no** se versiona (ignorado en .gitignore).
- .env.example sirve como plantilla.

---

## Artefacto versionado (publish)
Generación del artefacto:
- dotnet publish src/MyApi/MyApi.csproj -c Release -o out/MyApi-1.4.0

Salida:
- out/MyApi-1.4.0/

---

## Evidencias
Todas las evidencias (capturas y archivos) están indexadas en:
- docs/evidencias.md

---

## Licencia / Nota académica
Repositorio desarrollado como evidencia académica (despliegue controlado, verificación y rollback) en entorno local.

