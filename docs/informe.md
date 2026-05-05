## Despliegue controlado de API .NET con estrategia Blue/Green y plan de reversión (local)

**Objetivo del despliegue**  
Ejecutar un despliegue controlado de una API .NET en un entorno local aplicando una estrategia profesional (Blue/Green), validando estabilidad posterior al despliegue mediante endpoints de salud y readiness, y ejecutando un plan de reversión (rollback) documentado.

**Estrategia seleccionada y razones (Blue/Green)**  
Se implementaron dos versiones/instancias (Blue y Green) en paralelo y un router Nginx como punto de entrada. Esta estrategia reduce riesgo porque permite conmutar tráfico de forma controlada y revertir rápidamente sin reconstruir el entorno (solo cambiando el enrutamiento).

**Resumen del proceso (por fases)**  
1) **Preparación del artefacto:** se generó el artefacto versionado con dotnet publish y se organizó en out/MyApi-1.4.0. (Evidencias B1–B2)  
2) **Configuración por ambiente y secretos:** se definieron dos ambientes (Staging/Production) mediante ppsettings.Staging.json y ppsettings.Production.json. Los secretos se gestionaron con .env fuera del repositorio (con .env.example como plantilla) y exclusión mediante .gitignore. (Evidencias E1–E3)  
3) **Despliegue controlado Blue/Green:** se levantaron contenedores pi-blue, pi-green y pi-router mediante Docker Compose; el router expone http://localhost:8080 y enruta a Blue/Green. (Evidencias C2–C3)  
4) **Verificación post-despliegue:** se ejecutaron smoke tests y se validaron endpoints /health y /readiness tanto en el router como por instancia. Se revisó latencia y se obtuvo p95 a partir de mediciones locales. (Evidencias D1–D5)  
5) **Rollback:** se conmutó a Green y se ejecutó rollback retornando a Blue, verificando nuevamente disponibilidad. (Evidencias R1–R2)

**Evidencias clave (referencia rápida)**  
- Artefacto: B1, B2 + out/MyApi-1.4.0/  
- Ambientes/secretos: E1–E3 + .env.example + .gitignore  
- Pipeline: .github/workflows/ci-cd.yml  
- Estrategia Blue/Green: C2–C3 + deploy/docker-compose.bluegreen.yml + deploy/default.conf  
- Verificación: D1–D5  
- Rollback: R1–R2  

**Resultado final**  
El despliegue controlado se ejecutó correctamente con validación post-despliegue satisfactoria y rollback probado. Se dejó evidencia reproducible en repositorio, incluyendo configuración por ambiente, pipeline y scripts.

**Lecciones aprendidas**  
- Separar configuración y secretos del código mejora seguridad y reduce errores en despliegue.  
- Blue/Green simplifica la reversión y disminuye el tiempo de recuperación ante fallos.  
- Endpoints de salud/readiness y mediciones de latencia permiten validar estabilidad de forma objetiva.
