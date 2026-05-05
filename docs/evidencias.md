# Evidencias - Despliegue controlado de un componente con plan de reversión (API .NET)

Repositorio: https://github.com/cesarcorrales17/despliegue-controlado-dotnet-api  
Carpeta de capturas: docs/capturas/  
Artefactos/salidas: out/

---

## Evidencia 1) Artefacto versionado o enlace a repositorio
**Repositorio:** https://github.com/cesarcorrales17/despliegue-controlado-dotnet-api  
**Artefacto publicado:** out/MyApi-1.4.0/

**Capturas:**
- B1: B1_dotnet_publish_ok.png
- B2: B2_artifact_folder_list.png

---

## Evidencia 2) Configuración por ambiente + gestión de secretos
**Ambientes:** Staging y Production (simulados localmente).  
**Archivos de configuración por ambiente (en repo):**
- src/MyApi/appsettings.Staging.json
- src/MyApi/appsettings.Production.json

**Secretos:**
- .env NO se sube al repo (ignorado por .gitignore).
- .env.example se incluye como plantilla sin secretos reales.

**Capturas:**
- E1: E1_appsettings_staging.png
- E2: E2_appsettings_production.png
- E3: E3_gitignore_env.png

---

## Evidencia 3) YAML del pipeline o script de despliegue
**Pipeline CI (YAML):**
- .github/workflows/ci-cd.yml

**Scripts/automatización de despliegue local:**
- deploy/docker-compose.bluegreen.yml
- deploy/default.conf
- deploy/scripts/switch-to-blue.ps1
- deploy/scripts/switch-to-green.ps1
- deploy/scripts/rollback.ps1

**Capturas (referencia):**
- C2: C2_compose_up_ok.png

---

## Evidencia 4) Estrategia de despliegue aplicada (Blue/Green)
**Estrategia:** Blue/Green local con Docker Compose (2 instancias) y Nginx como router.  
**Instancias:**
- Blue: http://localhost:8081
- Green: http://localhost:8082
**Punto de entrada (router):**
- http://localhost:8080

**Capturas:**
- C2: C2_compose_up_ok.png
- C3: C3_docker_ps_containers.png
- R1: R1_switch_to_green.png (conmutación)

---

## Evidencia 5) Verificación post-despliegue
**Smoke tests / endpoints de verificación:**
- /health
- /readiness

**Router (8080):**
- D1: D1_router_health_readiness_200.png

**Verificación por instancia:**
- D2: D2_blue_health_200.png
- D3: D3_green_health_200.png

**Dependencias:**
- D4: D4_dependencias_na.png (N/A en entorno local)

**Latencia (p95):**
- Archivo: out/latency_ms.txt
- Archivo: out/p95.txt
- Capturas: D5a_latency_generated_file.png, D5b_latency_last10.png, D5c_p95_value.png

---

## Evidencia 6) Rollback (si se ejecutó)
**Rollback ejecutado:** retorno de tráfico a BLUE tras conmutación a GREEN.

**Capturas:**
- R1: R1_switch_to_green.png
- R2: R2_rollback_to_blue.png

---

## Evidencia adicional (verificación local previa)
**Local (puerto 5000):**
- A1: A1_dotnet-run_listening-5000.png
- A2: A2_health_200.png
- A3: A3_readiness_200.png

