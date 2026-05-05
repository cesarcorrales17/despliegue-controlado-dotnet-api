# Documentación del Proyecto
## Despliegue controlado de API .NET con estrategia Blue/Green + verificación + rollback (Local)

Repositorio: https://github.com/cesarcorrales17/despliegue-controlado-dotnet-api  
Autor: Cesar Corrales  
Última actualización: 2026-05-04/05

---

## 1) Propósito del proyecto
Este repositorio implementa un ejercicio completo de **despliegue controlado** para una **API .NET** en entorno local, aplicando una estrategia profesional **Blue/Green** con un **router Nginx**, incluyendo:

- Generación de **artefacto versionado** (dotnet publish).
- Definición de **ambientes** (Staging y Production) y separación de **secretos** mediante .env (fuera del repo).
- Automatización con **Docker Compose** para simular dos versiones/instancias (blue y green).
- **Verificación post-despliegue**: smoke tests, endpoints /health y /readiness, evidencia de dependencias (N/A), medición de latencia (p95).
- **Rollback** ejecutado y evidenciado.
- Pipeline CI (GitHub Actions) para build/test/publish de artefactos.

---

## 2) Requisitos (entorno del desarrollador)
### 2.1 Software
- Windows (PowerShell).
- .NET SDK instalado (este proyecto se generó con **net10.0**).
- Git.
- Docker Desktop (Linux containers) + Docker Compose.

### 2.2 Comprobación rápida
- dotnet --version
- git --version
- docker version
- docker compose version

---

## 3) Estructura del repositorio (alto nivel)
- .github/workflows/ci-cd.yml  
  Pipeline de CI: restore/build/test/publish + upload de artefacto.
- src/MyApi/  
  Código fuente de la API .NET.
- deploy/  
  Infraestructura del despliegue local Blue/Green:
  - docker-compose.bluegreen.yml
  - default.conf (config del router Nginx)
  - scripts/ (switch/rollback)
- docs/  
  Documentación y evidencias:
  - informe.md (máx. 1 página)
  - evidencias.md (índice de evidencias)
  - capturas/ (screenshots)
- out/  
  Artefactos y salidas:
  - out/MyApi-1.4.0/ (artefacto publish)
  - latency_ms.txt, p95.txt

---

## 4) API: diseño y endpoints
### 4.1 Proyecto
Ruta: src/MyApi/MyApi.csproj

### 4.2 Endpoints principales
- GET /weatherforecast  
  Endpoint de ejemplo del template.
- GET /health  
  Responde 200 OK con {"status":"ok"}.
- GET /readiness  
  Responde 200 OK con {"ready":true}.

> Nota: /health valida disponibilidad básica.  
> /readiness representa “listo para recibir tráfico” (en sistemas reales suele validar dependencias).

---

## 5) Configuración por ambiente y secretos
### 5.1 Ambientes soportados
- **Staging**
- **Production**

Archivos:
- src/MyApi/appsettings.Staging.json
- src/MyApi/appsettings.Production.json

### 5.2 Secretos
- .env **NO** se sube al repositorio (está en .gitignore).
- .env.example se incluye como plantilla (sin secretos reales).

Ejemplo de .env (local, fuera del repo):
- ASPNETCORE_ENVIRONMENT=Staging
- API_SECRET=...

---

## 6) Ejecución local (sin Docker)
### 6.1 Ejecutar API
Desde la raíz:
- dotnet run --project src/MyApi/MyApi.csproj

Escucha local (por launchSettings.json):
- http://localhost:5000

### 6.2 Pruebas rápidas (PowerShell)
- iwr http://localhost:5000/health -UseBasicParsing
- iwr http://localhost:5000/readiness -UseBasicParsing

---

## 7) Artefacto versionado (publish)
### 7.1 Generación
- dotnet publish src/MyApi/MyApi.csproj -c Release -o out/MyApi-1.4.0

Salida esperada:
- out/MyApi-1.4.0/ con MyApi.dll, ppsettings.json, etc.

---

## 8) Despliegue Blue/Green (local con Docker)
### 8.1 Componentes
- pi-blue (contenedor) -> host localhost:8081
- pi-green (contenedor) -> host localhost:8082
- pi-router (nginx) -> host localhost:8080

### 8.2 Config del router Nginx
Archivo: deploy/default.conf  
Montaje dentro del contenedor:
- /etc/nginx/conf.d/default.conf

El upstream apunta inicialmente a pi-blue:8080.  
La conmutación se logra cambiando el upstream a pi-green:8080 y recargando Nginx.

### 8.3 Levantar el stack
- docker compose -f deploy/docker-compose.bluegreen.yml up -d --build

### 8.4 Verificación post-despliegue (router + instancias)
Router:
- iwr http://localhost:8080/health -UseBasicParsing
- iwr http://localhost:8080/readiness -UseBasicParsing

Blue:
- iwr http://localhost:8081/health -UseBasicParsing

Green:
- iwr http://localhost:8082/health -UseBasicParsing

---

## 9) Conmutación y rollback (plan de reversión)
Scripts PowerShell:
- deploy/scripts/switch-to-green.ps1 (dirige tráfico a GREEN)
- deploy/scripts/switch-to-blue.ps1 (dirige tráfico a BLUE)
- deploy/scripts/rollback.ps1 (rollback a BLUE)

Ejecución:
- powershell -ExecutionPolicy Bypass -File deploy/scripts/switch-to-green.ps1
- powershell -ExecutionPolicy Bypass -File deploy/scripts/rollback.ps1

### 9.1 Criterios típicos de rollback (guía)
Se recomienda ejecutar rollback si ocurre alguno de estos escenarios:
- /readiness falla o devuelve error.
- Aumento significativo de errores (5xx).
- Incremento anormal de latencia (p95).
- Smoke tests fallan.

> En este ejercicio se ejecuta rollback como demostración controlada con evidencia (R1/R2).

---

## 10) Latencia y p95 (verificación adicional)
Archivos:
- out/latency_ms.txt (lista de tiempos en ms)
- out/p95.txt (valor p95 calculado)

Reproducible con PowerShell midiendo requests al router (/health).

---

## 11) Pipeline CI (GitHub Actions)
Archivo: .github/workflows/ci-cd.yml

Qué hace:
1) Checkout
2) Setup .NET
3) Restore
4) Build
5) Test
6) Publish a out/MyApi-${{ github.sha }}
7) Upload artifact

> Nota: el despliegue Blue/Green es local, por eso el pipeline se limita a CI + publish de artefacto.

---

## 12) Evidencias (capturas) y dónde encontrarlas
Índice completo:
- docs/evidencias.md

Capturas:
- docs/capturas/ (A*, B*, C*, D*, E*, R*)

---

## 13) Operación y mantenimiento
### 13.1 Apagar el stack
- docker compose -f deploy/docker-compose.bluegreen.yml down

### 13.2 Limpieza (opcional)
- docker image prune -f
- docker container prune -f

### 13.3 Troubleshooting común
**Caso: router no responde en 8080**
- Verificar docker ps (debe existir pi-router).
- Revisar logs: docker logs api-router --tail 100
- Confirmar que compose monta deploy/default.conf en /etc/nginx/conf.d/default.conf y NO reemplaza /etc/nginx/nginx.conf.

**Caso: endpoints 404**
- Confirmar que Program.cs tiene MapGet("/health"... y MapGet("/readiness"....

---

## 14) Estándares del repositorio
- No subir .env (secretos) al repositorio.
- Mantener docs/evidencias.md actualizado cuando se agreguen nuevas capturas.
- Cualquier cambio a la estrategia (p.ej. canary/rolling) debe documentarse en:
  - docs/informe.md
  - docs/evidencias.md
  - y en deploy/ con scripts/config correspondientes.

---

## 15) Pendientes / mejoras sugeridas (no obligatorias)
- Agregar tests automatizados de smoke (script) para /health y /readiness.
- Agregar un endpoint /dependencies real si se incorpora una base de datos/cola.
- Implementar feature flags reales (por ejemplo con configuración o biblioteca) para demostrar cambios por ambiente.
- Añadir logging/observabilidad (request logging) para reforzar verificación.

