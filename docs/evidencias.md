# Evidencias - Despliegue controlado API .NET (Blue/Green) + rollback

## Evidencia A (Local) - Verificación post-despliegue
**Objetivo:** validar disponibilidad básica y preparación de la API antes del despliegue controlado.

**Ejecución (dotnet run):**
- La API se ejecutó usando launchSettings.json.
- Entorno: Staging
- Listening: http://localhost:5000

**Pruebas ejecutadas:**
- GET /health  -> 200 OK, respuesta: {"status":"ok"}
- GET /readiness -> 200 OK, respuesta: {"ready":true}

**Comandos (PowerShell):**
- dotnet run --project src/MyApi/MyApi.csproj
- iwr http://localhost:5000/health -UseBasicParsing
- iwr http://localhost:5000/readiness -UseBasicParsing

**Capturas requeridas (guardar en docs/capturas):**
- A1_dotnet-run_listening-5000.png  (salida donde se ve "Now listening on: http://localhost:5000")
- A2_health_200.png                 (salida de iwr /health con StatusCode 200)
- A3_readiness_200.png              (salida de iwr /readiness con StatusCode 200)
