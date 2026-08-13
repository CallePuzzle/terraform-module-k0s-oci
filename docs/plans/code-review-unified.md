# Code Review Unificado: terraform-module-k0s-oci

> Documento unificado que consolida el proceso, los hallazgos y el plan de
> remediación derivados de la revisión de código del repositorio
> `terraform-module-k0s-oci` (módulo Terraform que despliega clusters K0s en
> Oracle Cloud Infrastructure usando recursos Always Free).

## Tabla de contenidos

1. [Revisión — Plan y alcance](#1-revisión--plan-y-alcance)
2. [Revisión — Proceso y metodología](#2-revisión--proceso-y-metodología)
3. [Revisión — Hallazgos](#3-revisión--hallazgos)
4. [Revisión — Plan de remediación](#4-revisión--plan-de-remediación)
   - [Fase 0 — Bloqueantes (no mergeables)](#fase-0--bloqueantes-no-mergeables)
   - [Fase 1 — Calidad y mantenibilidad](#fase-1--calidad-y-mantenibilidad-mergeables-individualmente)
   - [Fase 2 — Mejoras estructurales](#fase-2--mejoras-estructurales-nice-to-have)
   - [Fase 3 — Documentación de diseño](#fase-3--documentación-de-diseño)
   - [Tabla resumen de severidad](#tabla-resumen-de-severidad)
   - [Orden sugerido de ejecución](#orden-sugerido-de-ejecución)

---

## 1. Revisión — Plan y alcance

### Overview
Documento que describe la revisión de código del repositorio
`terraform-module-k0s-oci`, que despliega clusters K0s en Oracle Cloud
Infrastructure usando recursos del free tier.

### Review Scope
- Estructura y organización del módulo Terraform.
- Configuraciones de seguridad y reglas de red.
- Archivos de plantilla (`k0sctl.yaml`, `user-data.sh`).
- Definiciones de variables y valores por defecto.
- Outputs del módulo y ejemplos de uso.

### Key Areas to Inspect

#### 1. Module Structure
- Organización de archivos y separación de responsabilidades.
- Uso de `locals` para configuración.
- Enfoque modular con componentes reutilizables.

#### 2. Security Implementation
- Reglas de seguridad de red en la VCN.
- Configuración de puertos para componentes de K0s.
- Restricciones de acceso SSH.

#### 3. Template Files
- Lógica de templating de `k0sctl.yaml`.
- Funcionalidad del script de user data.
- Renderizado condicional de extensiones.

#### 4. Variable Management
- Tipos de variables y valores por defecto.
- Requisitos de validación de entrada.
- Calidad de la documentación.

#### 5. Code Quality
- Buenas prácticas de Terraform.
- Manejo de errores y casos borde.
- Consideraciones de mantenibilidad.

### Deliverables
- Resumen de issues identificados.
- Recomendaciones de mejora.
- Risk assessment de los cambios de código.

---

## 2. Revisión — Proceso y metodología

### Review Date
2026-08-05

### Reviewer
opencode AI Assistant

### Project Overview
Módulo Terraform para desplegar clusters K0s en Oracle Cloud Infrastructure
usando únicamente recursos del free tier. El módulo aprovisiona:
- VCN con reglas de seguridad apropiadas.
- Instancias de cómputo con soporte para K0s.
- Generación de archivos de configuración vía plantillas.

### Review Methodology

#### 1. Initial Exploration
- Examen de la estructura y organización del repositorio.
- Identificación de archivos clave: `main.tf`, `variables.tf`, `vcn.tf`,
  `instances.tf`.
- Revisión de plantillas (`k0sctl.yaml.tmpl`, `user-data.sh.tmpl`).

#### 2. Deep Dive Analysis
- Análisis de configuraciones Terraform y buenas prácticas.
- Revisión de la implementación de seguridad en reglas de VCN.
- Examen de la lógica de generación de plantillas.
- Verificación de definiciones de variables y valores por defecto.

#### 3. Documentation Review
- Evaluación de `README.md` por claridad y completitud.
- Revisión de ejemplos e instrucciones de uso.
- Verificación de la documentación de opciones de configuración.

### Tools Used
- Lectura de archivos y análisis de contenido.
- Exploración del repositorio Git.
- Parsing de plantillas.
- Análisis de estructura de código.

### Findings Summary
El módulo demuestra buenas prácticas de Terraform con separación adecuada de
responsabilidades. Las configuraciones de seguridad son comprehensivas para
los requisitos de K0s. Se identificaron issues menores para corrección,
incluyendo typos y valores hardcodeados que podrían ser configurables.

### Status
Pendiente de corrección de los issues identificados.

---

## 3. Revisión — Hallazgos

### Summary
Este módulo Terraform despliega exitosamente clusters K0s en Oracle Cloud
Infrastructure usando recursos del free tier. La implementación está bien
estructurada, con buena separación de responsabilidades y configuración de
seguridad de red adecuada.

### Major Strengths

#### 1. Module Organization
- Separación clara entre setup de VCN, creación de instancias y lógica
  principal.
- Buen uso de `locals` para configuraciones complejas.
- Organización adecuada de plantillas en el directorio `templates/`.

#### 2. Security Configuration
- Reglas de seguridad comprehensivas cubriendo todos los puertos requeridos
  por K0s.
- Uso apropiado de bloques CIDR (específicamente para tráfico interno).
- Separación limpia entre reglas base y reglas específicas de K0s.

#### 3. Template Flexibility
- Plantillas bien construidas para `k0sctl.yaml` con extensiones condicionales.
- Soporte para configuraciones de ArgoCD, NGINX y del proyecto.
- Uso correcto de sintaxis de plantillas Terraform con indentación apropiada.

### Issues Identified

#### Critical Issues
1. **Typo en nombre de variable** (`vcn.tf` línea 102):
   - `additional_default_securty_list_ingress_rules` debería ser
     `additional_default_security_list_ingress_rules`.

#### High Priority Issues
1. **Usuario SSH hardcodeado**:
   - La plantilla usa el usuario "ubuntu" hardcodeado, lo cual puede no
     funcionar en todos los despliegues.
   - Debería ser configurable vía variable.

2. **Limitaciones del script de user data**:
   - Deshabilita `ufw` e `iptables`, lo cual puede no ser necesario o deseado
     en producción.
   - Podría ser más robusto con manejo de errores.

#### Medium Priority Issues
1. **Validación de variables**:
   - Falta validación de entrada para `compartment_id` y otros parámetros
     críticos.
   - No hay checks en el formato o disponibilidad de `k0s_version`.

2. **Complejidad de plantillas**:
   - Algo de la lógica condicional en `k0sctl.yaml` podría simplificarse.
   - Podría beneficiarse de mejor indentación y organización de estructura.

### Recommendations

#### Immediate Fixes
1. Corregir el typo en el nombre de variable en `vcn.tf`.
2. Hacer configurable el usuario SSH mediante una variable.
3. Añadir validación de entrada para parámetros clave.

#### Improvements
1. Mejorar el manejo de errores en las plantillas de shell scripts.
2. Añadir documentación más comprehensiva para edge cases.
3. Considerar añadir soporte para versiones adicionales de K0s u opciones de
   configuración.
4. Implementar mejores prácticas de etiquetado de recursos.

### Risk Assessment
- **Bajo riesgo** para cambios de código: la mayoría de issues son problemas
  menores de configuración o mejoras.
- **Impacto medio**: el typo y el usuario hardcodeado podrían causar fallos de
  despliegue en algunos entornos.
- **Mantenibilidad**: el código ya está bien estructurado con buena
  documentación.

---

## 4. Revisión — Plan de remediación

> Plan de remediación derivado del code review completo del repo
> `terraform-module-k0s-oci`. Cada tarea tiene severidad, archivos afectados,
> pasos concretos y criterio de aceptación.

### Metadata
- Fecha: 2026-08-05
- Última actualización: 2026-08-07 (re-revisión contra el stage actual de la
  rama `4-remote-workflow-support`; se ejecutó `terraform validate`/`fmt`
  real sobre una copia del repo para confirmar hallazgos)
- Repo: `terraform-module-k0s-oci`
- Rama base sugerida: `4-remote-workflow-support`
- Idioma del código del repo: inglés (con excepciones existentes en español
  que se normalizan).
- Convención de tareas: checkboxes `- [ ]` para seguimiento manual.

### Estado de implementación al 2026-08-05

> Resumen de qué tareas del plan ya están reflejadas (parcial o totalmente)
> en el código stageado o en el working tree, y qué regresiones aparecen
> como efecto colateral.

**Tareas ya implementadas (2026-08-05, histórico)**

- ✅ Hallazgo crítico §3 — Typo `securty` → `security` corregido en
  `vcn.tf:101,118` (working tree).
- ✅ Hallazgo high §3 — Usuario SSH configurable vía `var.ssh_user`
  (`variables.tf:29-33`, propagado a `templates/k0sctl.yaml.tmpl:9` y
  `instances.tf:59`).
- ⚠️ Hallazgo medium §3 — Validación de variables parcialmente implementada:
  `main.tf:3-4` añade `error()` para `compartment_id` y `k0s_version`
  (presencia), pero no valida formato de `k0s_version`.

**Tareas pendientes / no implementadas (2026-08-05, histórico — ver
re-revisión 2026-08-07 más abajo, casi todo esto ya está resuelto)**

- ❌ **T0.1** sigue roto. `lb/main.tf:79` referencia
  `oci_load_balancer_certificate.this[0]` desde un listener que **no** tiene
  `count`. El certificado sí está condicionado (`count =
  var.certificate_public_certificate != null ? 1 : 0`), pero el listener no.
  `terraform plan` sin vars de cert devuelve `Invalid index`.
- ❌ **T0.2** newline al final. `load_balancer.tf:16` y `lb/variables.tf:52`
  siguen sin `\n` final. `terraform fmt -check` falla.
- ❌ **T0.3 / T0.4** CIDRs de API/SSH no parametrizados.
- ❌ **T1.1** `user-data.sh` huérfano sigue presente en la raíz.
- ❌ **T1.2** hardening de `templates/user-data.sh.tmpl` no aplicado.
- ❌ **T1.5** provider mínima **empeoró**: ahora `provider.tf` y
  `lb/provider.tf` declaran `>= 6.18.0` mientras `.terraform.lock.hcl` fija
  `8.12.0`. La ventana de versiones soportadas es ahora más amplia.
- ❌ **T1.7** `AGENTS.md` humana no restaurada; además `opencode.jsonc` se ha
  commiteado con problemas nuevos (ver T1.7-bis más abajo).
- ❌ **T1.8** `freeform_tags.environment = "pro"` sigue hardcodeado en
  `vcn.tf:128` (e implícitamente en `instances.tf`).
- ❌ **T1.9** `variables.tf:8` sigue con la descripción en español.
- ❌ **T1.10`–`T1.14` sin tocar.

**Regresiones introducidas por los cambios en stage / working tree
(2026-08-05, histórico)**

1. **T1.7-bis [MEDIUM] `opencode.jsonc` commiteado con path absoluto**:
   el archivo en stage (`opencode.jsonc:7`) contiene
   `"path": "/home/cesar/projects/terraform-module-k0s-oci"`, path absoluto
   del entorno del autor. No es portable, rompe la reproducción del setup
   en otra máquina y debería estar en `.gitignore` o usar ruta relativa.
2. **T1.5-bis [MEDIUM] Inconsistencia provider ↔ lock ampliada**: bajar la
   `version` constraint de `8.12.0` a `>= 6.18.0` amplía la ventana donde
   `terraform init` puede resolver un provider no validado contra este
   código. El lock debería forzarse a la versión probada o subir el mínimo
   en lugar de bajarlo.
3. **T-nuevo [LOW] Indentación rota en `templates/k0sctl.yaml.tmpl:6`**:
   el working tree contiene `-     ssh:` (5 espacios extra entre `-` y
   `ssh:`). Es funcional pero malformado y ensucia futuros `terraform fmt`
   o validadores YAML.

### Nuevas tareas detectadas en esta revisión (2026-08-05, histórico)

- **T0.1-bis** Reafirmación: T0.1 sigue siendo CRITICAL y bloqueante.
- **T0.2-bis** Reafirmación: T0.2 sigue pendiente (los archivos del LB
  introducidos en esta rama son los que no tienen `\n`).
- **T1.7-bis** `opencode.jsonc`: gitignore o relativizar el path.
- **T1.5-bis** Decidir dirección del constraint del provider OCI (subir a
  `>= 8.0.0` o degradar el lock a 6.x) y aplicarlo de forma consistente.
- **T-nuevo (1.15) [LOW] Formato de `k0s_version`**: añadir `validation` con
  regex `^\d+\.\d+\.\d+\+k0s\.\d+$` en `variables.tf`.
- **T-nuevo (1.16) [LOW] Indentación de `templates/k0sctl.yaml.tmpl:6`**.

---

### Re-revisión 2026-08-07 — todo lo de arriba se corrigió, pero apareció un bug de sintaxis nuevo

> Contra el stage actual de la rama. Verificado leyendo `git diff HEAD` de
> cada archivo y ejecutando `terraform validate`/`terraform fmt -check` de
> verdad sobre una copia del repo (root y submódulo `lb/`).

**Todo lo pendiente del 2026-08-05 quedó resuelto**:

- ✅ T0.1, T0.2, T0.3, T0.4, T1.1, T1.2, T1.3 (parcial, ver T1.18), T1.5,
  T1.5-bis, T1.6, T1.7, T1.7-bis, T1.8, T1.9, T1.10, T1.11, T1.12, T1.13,
  T1.14, T1.15, T1.16: **todos verificados como resueltos** en el código
  actual, incluyendo la eliminación de `.terraform.lock.hcl` (ver **T1.17**
  — es un acierto, no una regresión).
- ✅ T1.4: completado tras aplicar **T1.4-bis** (ver abajo).

**Hallazgos de esta re-revisión — todos corregidos el mismo 2026-08-07**
(detalle completo en Fase 0/1 más abajo):

- **T0.5 [CRITICAL] — ✅ corregido**: `vcn.tf:103` usaba sintaxis de
  slicing estilo Python (`local.k0s_security_rules[0:0]`), que no existe en
  HCL. Confirmado con `terraform validate`:
  `Error: Missing close bracket on index`. Rompía `fmt`, `validate` y
  `plan` para **todo** el módulo, no solo para el caso `enable_k0s = false`.
  Corregido a `var.enable_k0s ? local.k0s_security_rules : []`; verificado
  con `terraform fmt -check -recursive` y `terraform validate` (root y
  `lb/`) en limpio.
- **T1.17 [LOW, corregido] — no es una regresión**: la primera pasada de
  esta re-revisión marcó como HIGH el borrado de `.terraform.lock.hcl`,
  pero es un error de esa pasada. El `.gitignore` del repo **ya** ignoraba
  ese archivo desde antes de esta rama; llevaba trackeado por error varios
  commits y esta rama corrige esa inconsistencia. Para un módulo
  reutilizable (no un root config), no versionar el lock es lo esperado —
  ningún consumidor lo lee. Sin acción de código; queda como nota de
  documentación pendiente (baja prioridad, el usuario no la considera
  urgente dado que no le preocupa la reproducibilidad exacta de la CI).
- **T1.18 [MEDIUM] — ✅ corregido**: en `lb/`, las condiciones `count` para
  el backend/NSG de HTTPS solo miraban la var deprecada
  `certificate_public_certificate`, mientras que el certificado y el
  listener HTTPS ya miraban también el objeto `var.certificate` nuevo.
  Unificado en `local.has_certificate` (`lb/main.tf`) y reutilizado en los
  4 recursos con `count` + la regla NSG de `lb/nsg.tf:25`.
- **T1.4-bis [LOW] — ✅ corregido**: `k0s_version` por defecto pasa de
  `1.27.4+k0s.0` (EOL) a `1.30.4+k0s.0`; actualizadas también las
  referencias en `README.md` y `AGENTS.md`.
- **T1.19 [LOW] — ✅ corregido**: añadido salto de línea final a
  `templates/user-data.sh.tmpl`.
- **T1.19 [LOW] — nuevo**: `templates/user-data.sh.tmpl` sigue sin newline
  final tras el hardening de T1.2 (`git diff` muestra
  `\ No newline at end of file`).

---

### Fase 0 — Bloqueantes (no mergeables)

#### T0.1 [CRITICAL] Listener HTTPS referencia certificado que puede no existir

- **Síntoma**: `lb/main.tf:79` hace
  `oci_load_balancer_certificate.this[0].certificate_name` sobre un recurso
  con `count = var.certificate_public_certificate != null ? 1 : 0`. Si el
  consumidor no pasa cert, `[0]` falla con `Invalid index`.
- **Estado (2026-08-05)**: **NO RESUELTO**. En la rama actual el certificado
  ya está condicionado con `count`, pero el listener HTTPS (`lb/main.tf:71-82`)
  **no** lo está, por lo que el bug sigue vivo y se reproduce con el
  ejemplo por defecto (sin vars de certificado).
- **Archivos**: `lb/main.tf`
- **Pasos**:
  1. Convertir `oci_load_balancer_listener.https` a un recurso con
     `count = var.certificate_public_certificate != null ? 1 : 0`.
  2. Referenciar `oci_load_balancer_certificate.this[0]` solo dentro del bloque
     `count`.
  3. Validar con `terraform validate`.
- **Criterio de aceptación**: `terraform plan` sin vars de certificado no
  produce error; con vars sí crea listener HTTPS con SSL.
- **PR sugerido**: `fix(lb): make https listener conditional on certificate`

#### T0.2 [HIGH] Variables de cert sin newline al final

- **Síntoma**: `variables.tf` y `lb/variables.tf` terminan sin `\n`. Falla
  `terraform fmt -check`.
- **Estado (2026-08-05)**: **NO RESUELTO**. `variables.tf` ya termina en
  `\n` tras los cambios, pero `load_balancer.tf:16` y `lb/variables.tf:52`
  siguen sin newline final. Además, en el working tree
  `load_balancer.tf:16` no tiene `\n` y `lb/variables.tf:52` tampoco.
- **Archivos**:
  - `variables.tf`
  - `lb/variables.tf`
  - `load_balancer.tf`
- **Pasos**:
  1. Ejecutar `terraform fmt` en raíz y submódulo `lb/`.
  2. Confirmar que `git diff` solo añade línea final.
- **Criterio de aceptación**: `terraform fmt -check -recursive` retorna 0.
- **PR sugerido**: `chore: terraform fmt`

#### T0.3 [HIGH] kube-apiserver (6443) abierto a `0.0.0.0/0`

- **Síntoma**: `vcn.tf:48` permite TCP 6443 desde cualquier IP.
- **Archivos**: `vcn.tf`, `variables.tf`
- **Pasos**:
  1. Añadir `variable "api_allowed_cidrs"` con default `["0.0.0.0/0"]` y
     `description` explícita sobre el riesgo.
  2. Cambiar la regla k0s 6443 para usar `var.api_allowed_cidrs` (mapeando
     cada CIDR a una regla).
  3. Mantener compat: default `["0.0.0.0/0"]` para no romper despliegues
     Always Free.
- **Criterio de aceptación**: los despliegues existentes siguen funcionando;
  un consumidor puede pasar
  `api_allowed_cidrs = ["203.0.113.0/24"]`.
- **PR sugerido**: `feat(security): parameterize api_allowed_cidrs`

#### T0.5 [CRITICAL] Sintaxis HCL inválida en `vcn.tf` rompe todo el módulo — ✅ RESUELTO 2026-08-07

- **Fix aplicado**: `vcn.tf:103` cambiado a
  `var.enable_k0s ? local.k0s_security_rules : []`. Verificado con
  `terraform fmt -check -recursive` (sin diferencias) y `terraform validate`
  en raíz y en `lb/` (ambos `Success!`) sobre una copia limpia del repo.
- **Síntoma (antes del fix)**: `vcn.tf:103` contenía
  `var.enable_k0s ? local.k0s_security_rules : local.k0s_security_rules[0:0]`.
  El operador `[0:0]` es slicing estilo Python; HCL no lo soporta. Confirmado
  con `terraform validate`:
  ```
  Error: Missing close bracket on index
    on vcn.tf line 103, in locals:
   103:     var.enable_k0s ? local.k0s_security_rules : local.k0s_security_rules[0:0],
  The index operator must end with a closing bracket ("]").
  ```
  Esto rompe `terraform fmt`, `terraform validate` y `terraform plan` para
  **cualquier** invocación del módulo, con o sin `enable_k0s`, con o sin
  certificado — es un error de parseo, no de tipos. Es un regresión
  introducida al refactorizar el filtro `[for r in local.k0s_security_rules
  : r if var.enable_k0s]` (que sí era válido) a la forma actual.
- **Archivos**: `vcn.tf`
- **Pasos**:
  1. Sustituir la expresión rota por una de estas dos (ambas verificadas con
     `terraform validate`):
     - `var.enable_k0s ? local.k0s_security_rules : []`
     - `slice(local.k0s_security_rules, 0, 0)` (si se quiere preservar la
       forma "lista vacía del mismo tipo" explícitamente).
  2. Ejecutar `terraform fmt -check -recursive` y `terraform validate` en
     raíz y en `lb/`.
- **Criterio de aceptación**: `terraform validate` pasa en raíz sin
  necesidad de credenciales OCI (con `terraform init -backend=false`);
  `terraform fmt -check -recursive` no reporta diferencias.
- **PR sugerido**: `fix(vcn): remove invalid python-style slice syntax`

#### T0.4 [HIGH] SSH (22) abierto a `0.0.0.0/0`

- **Síntoma**: `vcn.tf:7` permite TCP 22 desde cualquier IP.
- **Archivos**: `vcn.tf`, `variables.tf`
- **Pasos**:
  1. Añadir `variable "ssh_allowed_cidrs"` con default `["0.0.0.0/0"]`.
  2. Cambiar la regla base 22 para usar `var.ssh_allowed_cidrs`.
  3. Documentar en `README.md` cómo restringir.
- **Criterio de aceptación**: ídem T0.3.
- **PR sugerido**: `feat(security): parameterize ssh_allowed_cidrs`

---

### Fase 1 — Calidad y mantenibilidad (mergeables individualmente)

#### T1.1 [MEDIUM] Eliminar `user-data.sh` huérfano

- **Síntoma**: el archivo raíz `user-data.sh` ya no se usa (el módulo usa
  `templates/user-data.sh.tmpl`).
- **Archivos**: `user-data.sh`
- **Pasos**:
  1. Borrar el archivo.
  2. Verificar que `grep -R "user-data.sh" .` (excluyendo `.terraform/`) no
     tiene referencias distintas a `.tmpl`.
- **Criterio de aceptación**: archivo eliminado; ningún test rompe.
- **PR sugerido**: `chore: remove orphan user-data.sh`

#### T1.2 [MEDIUM] Hardening de `templates/user-data.sh.tmpl`

- **Síntoma**: `apt upgrade -y` retrasa el boot; `systemctl stop iptables`
  falla si no existe el servicio.
- **Archivos**: `templates/user-data.sh.tmpl`
- **Pasos**:
  1. Reemplazar `apt upgrade -y` por `unattended-upgrade -d` o
     `apt -y --no-install-recommends upgrade` y aceptar el retraso solo si el
     módulo lo permite.
  2. Envolver `systemctl stop/disable iptables` con `|| true`.
  3. Comentar la línea `sudo reboot` con `# Consider removing for faster
     boot` y, opcional, hacer el reboot condicional a `var.enable_k0s`.
- **Criterio de aceptación**: cloud-init no devuelve error por `iptables`
  ausente; primer boot ≤ 4 min.
- **PR sugerido**: `fix(user-data): tolerate missing iptables service`

#### T1.3 [MEDIUM] Variables de certificado en object

- **Síntoma**: cuatro vars de cert sueltas (`certificate_certificate_name`,
  `certificate_public_certificate`, `certificate_private_key`,
  `certificate_ca_certificate`). Se repiten en `variables.tf` y
  `lb/variables.tf`.
- **Archivos**: `variables.tf`, `lb/variables.tf`, `load_balancer.tf`,
  `lb/main.tf`
- **Pasos**:
  1. Crear `variable "certificate"` con
     `type = object({ name = string, public_certificate = string, private_key = string, ca_certificate = optional(string) })`
     y `sensitive = true`.
  2. Mantener las cuatro vars actuales como **deprecated** con `description`
     "DEPRECATED: use `certificate` object".
  3. En `load_balancer.tf`, pasar el objeto a `lb` (con un fallback a las vars
     deprecadas vía `coalesce`).
  4. `lb/variables.tf` consume el mismo `object`.
- **Criterio de aceptación**: los consumidores pueden migrar a
  `certificate = { ... }`; las vars deprecadas siguen funcionando.
- **PR sugerido**: `feat(cert): group certificate variables into object`

#### T1.4 [MEDIUM] Bump de versiones (k0s + charts)

- **Síntoma**: `k0s_version = 1.27.4+k0s.0` (EOL), `nginx-ingress 4.12.3`,
  `argo-cd 8.1.1`, `argocd-apps 2.0.2`. Algunas ya EOL o cerca.
- **Archivos**: `variables.tf`, `templates/k0sctl.yaml.tmpl`
- **Pasos**:
  1. Definir versiones objetivo como vars con defaults nuevos (ej: k0s
     `1.30.x+k0s.0`, nginx-ingress `4.12.x`, argo-cd `7.x`, argocd-apps
     `2.x`).
  2. Actualizar README al ejemplo con k0sctl versión actual.
  3. Validar que `terraform apply` + `k0sctl apply` siguen funcionando.
- **Criterio de aceptación**: cluster recién desplegado pasa
  `kubectl get nodes` y los pods de ArgoCD/ingress en estado `Running`.
- **PR sugerido**: `feat(deps): bump k0s and chart versions`

#### T1.4-bis [LOW] `k0s_version` sigue en versión EOL pese a marcarse T1.4 como resuelto — ✅ RESUELTO 2026-08-07

- **Fix aplicado**: default de `k0s_version` en `variables.tf` actualizado a
  `1.30.4+k0s.0`. Actualizadas también las referencias a `1.27.4+k0s.0` /
  `1.27.1+k0s.0` en `README.md` y `AGENTS.md` (tabla de variables y enlace a
  docs de k0sproject.io).
- **Síntoma (antes del fix)**: la tabla resumen de esta versión del plan
  marcaba T1.4 como
  "resuelto", pero solo se actualizaron las versiones de los charts en
  `templates/k0sctl.yaml.tmpl` (nginx-ingress, argo-cd, argocd-apps). El
  default de `variable "k0s_version"` en `variables.tf` sigue siendo
  `"1.27.4+k0s.0"`, la misma versión EOL señalada en el hallazgo original.
- **Archivos**: `variables.tf`
- **Pasos**:
  1. Definir el default a una versión de k0s soportada (ej.
     `1.30.x+k0s.0`), verificando que sigue pasando la `validation` regex
     ya existente (T1.15).
  2. Actualizar el ejemplo de README si menciona la versión.
- **Criterio de aceptación**: `terraform plan` con el default actual crea un
  cluster con una versión de k0s no EOL.
- **PR sugerido**: `chore(deps): bump default k0s_version`

#### T1.5 [MEDIUM] Invalidación de OCI provider entre lock y provider.tf

- **Síntoma**: lock `oracle/oci = 8.12.0`, `provider.tf` dice `>= 6.18.0`. Si
  el consumidor tiene 6.x obtendrá código no validado con esa versión.
- **Estado (2026-08-05)**: **EMPEORADO**. La rama actual bajó la constraint
  de `8.12.0` a `>= 6.18.0` en `provider.tf` y `lb/provider.tf`, ampliando
  la ventana de versiones no validadas. La inconsistencia lock ↔ provider
  sigue, pero ahora en dirección opuesta a la recomendada por este plan.
- **Archivos**: `provider.tf`, `lb/provider.tf`, `.terraform.lock.hcl`
- **Pasos**:
  1. Decidir mínimo soportado. Subir `provider.tf` y `lb/provider.tf` a
     `>= 8.0.0` (preferido) o, alternativamente, regenerar el lock contra
     6.x si se decide seguir soportando 6.x.
  2. Regenerar `.terraform.lock.hcl` con `terraform init -upgrade`.
  3. Documentar en README la versión mínima.
- **Criterio de aceptación**: `terraform init` en raíz y en `lb/` con provider
  8.x resuelve OK; el lock y la constraint son coherentes.
- **PR sugerido**: `chore(provider): bump minimum oci to 8.0.0`

#### T1.5-bis [MEDIUM] Coherencia provider ↔ lock

- **Síntoma**: la rama actual relajó la constraint en lugar de alinearla
  con el lock. Cualquier `terraform init` puede ahora resolver un provider
  entre 6.18 y 8.12 que no ha sido probado contra este código.
- **Acción**: ejecutar `T1.5` con dirección **subir** (no bajar). Dejar la
  decisión como `>= 8.0.0` y `terraform init -upgrade` para fijar el lock.
- **Criterio de aceptación**: `provider.tf` y `lock.hcl` son coherentes y la
  ventana de versiones válidas queda acotada.

#### T1.17 [LOW] `.terraform.lock.hcl` destrackeado — correcto, pero falta documentarlo

- **Corrección sobre la revisión anterior**: esta entrada originalmente
  pedía "regenerar y commitear" el lock como si su eliminación fuera una
  regresión de severidad HIGH. Es un error de esa revisión — al comprobar
  el histórico, `.gitignore` **ya** ignora `.terraform.lock.hcl` desde hace
  tiempo (la regla no es nueva en esta rama); el archivo llevaba
  **trackeado por error** desde `254556d` hasta `3b914d3` pese a estar en
  `.gitignore`, y esta rama simplemente alinea el estado real de git con lo
  que el propio `.gitignore` ya pedía. Además, para un **módulo**
  reutilizable (no un root config desplegable), la guía de Terraform es
  precisamente esa: declarar `required_providers` con constraints abiertos
  (`>= 8.0.0`, ya corregido en T1.5) y no versionar el lock — ese archivo
  solo se genera/usa en el root config real que hace `terraform init`
  (aquí, `test/main.tf` o el root de quien consuma el módulo vía
  `source = "..."`), nunca en la raíz del módulo. Ningún consumidor lee el
  lock de este repo.
- **Matiz real que sí queda pendiente**: `.github/workflows/ci.yml` (T1.6)
  corre `terraform init -backend=false` + `validate` directamente contra la
  raíz y contra `lb/`, tratándolos como si fueran roots. Sin lock, cada run
  de CI puede resolver una versión distinta del provider OCI — no rompe
  nada (validate no depende de una versión exacta), pero resta
  reproducibilidad al propio pipeline y podría enmascarar temporalmente una
  incompatibilidad si un futuro release del provider cambia algo que
  `validate` sí detecta.
- **Archivos**: `AGENTS.md` o `README.md` (documentación), opcionalmente
  `.github/workflows/ci.yml`
- **Pasos** (opcionales, esfuerzo XS, no bloqueante):
  1. Añadir una línea en `AGENTS.md`/`README.md` explicando que el lock no
     se versiona a propósito (es un módulo, no un root config) para que
     nadie lo vuelva a añadir por accidente.
  2. Si se quiere reproducibilidad de CI sin convertir el repo en algo que
     no es, cachear el resultado de `terraform init` dentro del propio job
     de CI (mismo run) en lugar de commitear un lock permanente.
- **Criterio de aceptación**: no hay acción de código requerida; el repo
  documenta por qué no hay lock committeado.
- **PR sugerido**: `docs: note why .terraform.lock.hcl is intentionally untracked`

#### T1.18 [MEDIUM] `count` inconsistente entre `certificate` y vars deprecadas en `lb/` — ✅ RESUELTO 2026-08-07

- **Fix aplicado**: añadido `local.has_certificate` en `lb/main.tf`
  (`var.certificate != null ? var.certificate.public_certificate != null :
  var.certificate_public_certificate != null`) y reutilizado en los cuatro
  `count` de `lb/main.tf` (`backend_set.https`, `backend.https`,
  `certificate`, `listener.https`) y en la regla NSG `lb/nsg.tf:25`.
  Verificado con `terraform validate` en `lb/` sobre una copia limpia.
- **Síntoma (antes del fix)**: en `lb/main.tf`, `oci_load_balancer_backend_set.https`
  (línea 22), `oci_load_balancer_backend.https` (línea 50) y la regla NSG
  de `lb/nsg.tf:25` condicionan su `count` solo con
  `var.certificate_public_certificate != null`. En cambio,
  `oci_load_balancer_certificate.this` (línea 66) y
  `oci_load_balancer_listener.https` (línea 76) ya usan la condición unión
  `var.certificate != null ? ... : var.certificate_public_certificate != null`.
  Si el submódulo `lb/` se invoca directamente pasando solo el objeto nuevo
  `certificate = {...}` (sin las vars deprecadas), el listener
  (`count = 1`) referenciaría `oci_load_balancer_backend_set.https[0]`, pero
  ese recurso tendría `count = 0` → `Invalid index`. Hoy el bug queda
  enmascarado porque `load_balancer.tf` (raíz) siempre aplana
  `var.certificate` a las cuatro vars deprecadas antes de invocar
  `module "lb"` (`certificate_certificate_name = var.certificate != null ?
  var.certificate.name : var.certificate_certificate_name`, etc.), así que
  `var.certificate_public_certificate` dentro del submódulo nunca queda
  `null` cuando el objeto sí está seteado. Es relevante para **T2.1**
  (extraer `lb/` a un repo externo): en cuanto se use como módulo
  independiente sin ese aplanado previo, el bug se manifiesta.
- **Archivos**: `lb/main.tf`, `lb/nsg.tf`
- **Pasos**:
  1. Extraer la condición unión a un único `local.has_certificate` dentro de
     `lb/` y usarlo en los cuatro `count` (`backend_set.https`,
     `backend.https`, `certificate`, `listener.https`) y en
     `nsg.tf:25`.
  2. Alternativa más simple: dentro de `lb/`, resolver `var.certificate` y
     las vars deprecadas a un único `local.certificate` al principio de
     `lb/main.tf` y dejar de branchear en cada recurso.
  3. Validar pasando `certificate = {...}` sin las vars deprecadas
     directamente al submódulo (`cd lb && terraform plan` con un stub) para
     confirmar que ya no depende del aplanado de la raíz.
- **Criterio de aceptación**: el submódulo `lb/` produce el mismo `count`
  para los 5 recursos afectados sin importar si el consumidor usa
  `var.certificate` o las vars deprecadas, tanto invocado desde la raíz como
  de forma standalone.
- **PR sugerido**: `fix(lb): unify certificate presence check across resources`

#### T1.6 [MEDIUM] CI mínimo (fmt + validate + tflint + tfsec)

- **Síntoma**: solo hay workflow de release; nada valida el código en PRs.
- **Archivos**: `.github/workflows/ci.yml` (nuevo)
- **Pasos**:
  1. Crear workflow que corra en `pull_request`:
     - `terraform fmt -check -recursive`
     - `terraform init -backend=false`
     - `terraform validate`
     - `tflint --recursive`
     - `tfsec .`
  2. Cachear `.terraform/` entre runs.
- **Criterio de aceptación**: workflow falla si cualquiera de los pasos falla;
  los PRs muestran checks verdes.
- **PR sugerido**: `ci: add terraform lint and security checks`

#### T1.7 [MEDIUM] Restaurar AGENTS.md humana y mover config opencode

- **Síntoma**: la rama actual reemplazó `AGENTS.md` (295 líneas de doc del
  proyecto) por 34 líneas de doc de CodeGraph.
- **Estado (2026-08-05)**: **NO RESUELTO**. `AGENTS.md` sigue con la versión
  corta de CodeGraph; `opencode.jsonc` además se ha añadido con
  problemas (ver T1.7-bis).
- **Archivos**: `AGENTS.md`, `opencode.jsonc`
- **Pasos**:
  1. Recuperar el contenido original de `AGENTS.md` desde
     `git show HEAD~1:AGENTS.md`.
  2. Mover la sección CodeGraph a `.opencode/agents.md` o similar (decidir
     ubicación).
  3. Decidir si `opencode.jsonc` se commitea; si no, añadir a `.gitignore`.
- **Criterio de aceptación**: el repo tiene la doc humana del proyecto;
  CodeGraph sigue funcionando para el IDE.
- **PR sugerido**: `docs: restore AGENTS.md and move tool config`

#### T1.7-bis [MEDIUM] `opencode.jsonc` commiteado con path absoluto

- **Síntoma**: el archivo staged `opencode.jsonc:7` contiene
  `"path": "/home/cesar/projects/terraform-module-k0s-oci"`, ruta absoluta
  del entorno del autor. No portable, rompe la reproducción en otras
  máquinas y filtra información de la máquina del autor.
- **Archivos**: `opencode.jsonc`, `.gitignore`
- **Pasos**:
  1. **Opción A (recomendada)**: añadir `opencode.jsonc` a `.gitignore`
     (o a un `.gitignore` local tipo `.gitignore.local`) y sacarlo del
     stage. La config de opencode es por usuario/máquina, no del repo.
  2. **Opción B**: relativizar el `path` a `.` o
     `${workspaceFolder}` (variable soportada por opencode), y dejar el
     archivo versionado como ejemplo.
  3. Verificar que `git grep opencode` no muestra el path absoluto en
     commits previos.
- **Criterio de aceptación**: ningún commit contiene paths absolutos del
  autor; `opencode.jsonc` o está ignorado, o solo contiene rutas
  relativas/variables.
- **PR sugerido**: `chore: don't commit local opencode.jsonc`

#### T1.8 [MEDIUM] Parametrizar tag `environment`

- **Síntoma**: `freeform_tags.environment = "pro"` hardcodeado en
  `instances.tf` y `vcn.tf`. Contradice el uso de "pro" cuando solo es Always
  Free.
- **Archivos**: `instances.tf`, `vcn.tf`, `variables.tf`
- **Pasos**:
  1. Añadir `variable "environment"` con default `"dev"`.
  2. Reemplazar `"pro"` por `var.environment` en los dos archivos.
- **Criterio de aceptación**: un consumidor puede sobreescribir
  `environment = "prod"` y el cambio se refleja en todas las tags.
- **PR sugerido**: `feat(tags): parameterize environment tag`

#### T1.9 [LOW] Normalizar idioma de descripciones

- **Síntoma**: `variables.tf:8` está en español; el resto en inglés.
- **Archivos**: `variables.tf`
- **Pasos**:
  1. Traducir `enable_k0s` al inglés.
  2. Buscar `grep -n '[áéíóúñ]' *.tf` para detectar otros casos.
- **Criterio de aceptación**: todas las descripciones en inglés.
- **PR sugerido**: `chore: translate variable descriptions to english`

#### T1.10 [LOW] Limpiar `argocd_values` por defecto

- **Síntoma**: `argocd_values = {}` cuando no hay `argocd_host` lleva a un
  ArgoCD sin ingress (`server.insecure: true` no se setea).
- **Archivos**: `main.tf`, `variables.tf`
- **Pasos**:
  1. Añadir `validation` que requiera `argocd_host` si
     `enable_argocd = true` y `argocd_values = {}`.
  2. Documentar el flujo en README.
- **Criterio de aceptación**: el plan falla si la combinación no es coherente;
  el apply funciona cuando se pasa `argocd_host`.
- **PR sugerido**: `feat(argocd): require argocd_host when using defaults`

#### T1.11 [LOW] Agrupar outputs útiles del LB/VCN

- **Síntoma**: `outputs.tf` solo expone `public_ip`, `private_ip`,
  `k0s_file_content`. Falta `lb_id`, `lb_public_ip`, `vcn_id`.
- **Archivos**: `outputs.tf`, `lb/main.tf`, `vcn/outputs.tf`
- **Pasos**:
  1. Exponer `lb_public_ip` desde `lb/main.tf`.
  2. Añadir outputs `lb_id`, `lb_public_ip`, `vcn_id` en raíz.
- **Criterio de aceptación**: `terraform output` lista los nuevos valores
  tras `apply`.
- **PR sugerido**: `feat(outputs): expose lb and vcn identifiers`

#### T1.12 [LOW] Reducir magic string `controllerworker`

- **Síntoma**: outputs y `main.tf` hardcodean `"controllerworker"`.
- **Archivos**: `outputs.tf`, `main.tf`
- **Pasos**:
  1. Añadir `local.controller_key = "controllerworker"` (o derivarlo de las
     keys de `local.instances`).
  2. Reemplazar el literal en `outputs.tf` y `main.tf`.
- **Criterio de aceptación**: las refs pasan por un único punto.
- **PR sugerido**: `refactor: introduce controller_key local`

#### T1.13 [LOW] Documentar `ssh_public_key` en README

- **Síntoma**: la variable es obligatoria pero el README no la menciona.
- **Archivos**: `README.md`
- **Pasos**:
  1. Añadir bloque de "Required variables" con `compartment_id` y
     `ssh_public_key`.
  2. Ejemplo de uso con `file("~/.ssh/id_rsa.pub")`.
- **Criterio de aceptación**: un nuevo consumidor entiende las vars
  obligatorias sin abrir `variables.tf`.
- **PR sugerido**: `docs(readme): document required variables`

#### T1.14 [LOW] Sanitizar OCID en `test/main.tf`

- **Síntoma**: OCID real hardcodeado en el ejemplo.
- **Archivos**: `test/main.tf`
- **Pasos**:
  1. Reemplazar por
     `ocid1.tenancy.oc1..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`.
- **Criterio de aceptación**: el OCID no es un tenancy real.
- **PR sugerido**: `chore(test): replace ocid placeholder`

#### T1.15 [LOW] Validar formato de `k0s_version`

- **Síntoma**: el plan original pedía "checks en el formato o disponibilidad
  de `k0s_version`". La rama actual solo valida presencia (`main.tf:4`) pero
  no formato; un valor mal escrito como `1.30` se acepta y falla tarde en
  `k0sctl apply`.
- **Archivos**: `variables.tf`
- **Pasos**:
  1. Añadir bloque `validation` a `variable "k0s_version"` con
     `condition = can(regex("^\\d+\\.\\d+\\.\\d+\\+k0s\\.\\d+$",
     var.k0s_version))`.
  2. Mensaje de error sugiriendo el formato esperado.
- **Criterio de aceptación**: `terraform plan` con `k0s_version = "1.30"`
  falla con mensaje claro; con `"1.30.0+k0s.0"` pasa.
- **PR sugerido**: `feat(variables): validate k0s_version format`

#### T1.16 [LOW] Arreglar indentación de `templates/k0sctl.yaml.tmpl`

- **Síntoma**: el working tree tiene `  -     ssh:` (5 espacios extra entre
  el `-` y `ssh:`). Es funcional pero está claramente malformado y
  ensucia cualquier validador YAML externo.
- **Archivos**: `templates/k0sctl.yaml.tmpl`
- **Pasos**:
  1. Restaurar la indentación a `  - ssh:` (un único espacio tras `-`).
  2. Verificar con `k0sctl --config ... validate` o `yq` que el YAML sigue
     parseando.
- **Criterio de aceptación**: el YAML valida con la indentación correcta;
  `terraform apply` produce el mismo contenido efectivo.
- **PR sugerido**: `fix(template): correct k0sctl.yaml indentation`

---

#### T1.19 [LOW] `templates/user-data.sh.tmpl` sin newline final — ✅ RESUELTO 2026-08-07

- **Fix aplicado**: añadido salto de línea final al archivo. Verificado con
  `tail -c1 templates/user-data.sh.tmpl` (ahora vacío/`\n`).
- **Síntoma (antes del fix)**: tras el hardening de T1.2, el archivo seguía terminando sin
  `\n` (`git diff` muestra `\ No newline at end of file` en la línea final
  `sudo reboot`). No lo detecta `terraform fmt` (no es un archivo `.tf`),
  pero ensucia diffs futuros y algunos linters de shell.
- **Archivos**: `templates/user-data.sh.tmpl`
- **Pasos**:
  1. Añadir salto de línea final al archivo.
- **Criterio de aceptación**: `tail -c1 templates/user-data.sh.tmpl | wc -l`
  devuelve `1`.
- **PR sugerido**: incluir en el mismo PR que toque T1.2 o T0.5.

---

### Fase 2 — Mejoras estructurales (nice-to-have)

#### T2.1 Extraer submódulo `lb/` a repo externo

- **Síntoma**: `lb/` tiene 100 LoC propios; podría reutilizarse.
- **Acción**: publicar como submódulo separado (p.ej.
  `oracle-terraform-modules/lb-http-tcp/oci`) y consumirlo vía
  `git::https://...`.
- **Criterio de aceptación**: `lb/` se reemplaza por `module "lb"` externo;
  los tests pasan.

#### T2.2 Pre-commit hooks

- **Acción**: añadir `.pre-commit-config.yaml` con `terraform_fmt`,
  `terraform_validate`, `tflint`, `trailer`, `end-of-file-fixer`.
- **Criterio de aceptación**: `pre-commit run --all-files` pasa en limpio.

#### T2.3 Documentar troubleshooting avanzado

- **Acción**: ampliar `README.md` con sección sobre second-`apply`, cambios de
  `boot_volume_size`, import de recursos preexistentes.
- **Criterio de aceptación**: el troubleshooting cubre los 3 casos.

#### T2.4 Tests con `terratest` o kitchen-terraform

- **Acción**: añadir test de humo que cree un compartment efímero, aplique el
  módulo y verifique outputs.
- **Criterio de aceptación**: el test corre en menos de 15 min y valida al
  menos un output.

#### T2.5 Idempotencia de `local_file.k0sctl`

- **Acción**: añadir `lifecycle { ignore_changes = [content] }` o usar
  `file_provisioner` de Helm; el output `k0s_file_content` puede ser
  suficiente.
- **Criterio de aceptación**: el archivo no se reescribe si los inputs no
  cambian.

---

### Fase 3 — Documentación de diseño

#### T3.1 ADRs (Architecture Decision Records)

- **Acción**: crear `docs/adr/0001-vcn-forked-in-repo.md`,
  `0002-single-node-controller-worker.md`, `0003-oci-always-free.md`,
  `0004-certificate-via-tls-lb.md`.
- **Criterio de aceptación**: cada ADR tiene Contexto / Decisión /
  Consecuencias.

#### T3.2 Diagrama de arquitectura

- **Acción**: añadir `docs/architecture.md` con un diagrama (mermaid) de:
  provider → VCN → subnet → instancia → LB → NSG → cert, más flechas a
  k0s/ArgoCD/ingress.
- **Criterio de aceptación**: el diagrama refleja el grafo real de Terraform.

---

### Tabla resumen de severidad

| Tarea | Severidad | Esfuerzo | Bloquea release | Estado 2026-08-07 |
|---|---|---|---|---|
| T0.5 | CRITICAL | XS | sí | ✅ resuelto |
| T0.1 | CRITICAL | S | sí | ✅ resuelto |
| T0.2 | HIGH | XS | sí | ✅ resuelto |
| T0.3 | HIGH | S | sí | ✅ resuelto |
| T0.4 | HIGH | S | sí | ✅ resuelto |
| T1.1 | MEDIUM | XS | no | ✅ resuelto |
| T1.2 | MEDIUM | S | no | ✅ resuelto |
| T1.3 | MEDIUM | M | no | ✅ resuelto (ver T1.18) |
| T1.4 | MEDIUM | M | no | ✅ resuelto (ver T1.4-bis) |
| T1.5 | MEDIUM | S | no | ✅ resuelto (dirección correcta) |
| T1.5-bis | MEDIUM | XS | no | ✅ resuelto |
| T1.6 | MEDIUM | S | no | ✅ resuelto |
| T1.7 | MEDIUM | S | no | ✅ resuelto |
| T1.7-bis | MEDIUM | XS | no | ✅ resuelto |
| T1.8 | MEDIUM | S | no | ✅ resuelto |
| T1.18 | MEDIUM | S | no | ✅ resuelto |
| T1.9 | LOW | XS | no | ✅ resuelto |
| T1.10 | LOW | S | no | ✅ resuelto |
| T1.11 | LOW | XS | no | ✅ resuelto |
| T1.12 | LOW | XS | no | ✅ resuelto |
| T1.13 | LOW | XS | no | ✅ resuelto |
| T1.14 | LOW | XS | no | ✅ resuelto |
| T1.15 | LOW | XS | no | ✅ resuelto |
| T1.16 | LOW | XS | no | ✅ resuelto |
| T1.4-bis | LOW | XS | no | ✅ resuelto |
| T1.17 | LOW | XS | no | ⏸️ opcional, no bloqueante (usuario no prioriza fiabilidad exacta de CI) |
| T1.19 | LOW | XS | no | ✅ resuelto |
| T2.* | LOW | L | no | ❌ no resuelto |
| T3.* | LOW | M | no | ❌ no resuelto |

Esfuerzo: XS (≤15 min), S (≤1h), M (≤4h), L (>4h).

---

### Orden sugerido de ejecución

**Histórico (2026-08-05)** — ya completado en su mayor parte, ver
re-revisión 2026-08-07 arriba:

1. ~~T0.1~~ · 2. ~~T0.2~~ · 3. ~~T0.3, T0.4~~ · 4. ~~T1.6~~ ·
5. ~~T1.7 + T1.7-bis~~ · 6. ~~T1.5 + T1.5-bis~~ · 7. ~~T1.8~~ ·
8. ~~T1.1, T1.2, T1.3, T1.15, T1.16~~ · 9. ~~T1.9 → T1.14~~.

**2026-08-07** — T0.5, T1.18, T1.4-bis y T1.19 corregidos en el mismo día
(ver notas "✅ RESUELTO 2026-08-07" en cada sección de Fase 0/1). Verificado
con `terraform fmt -check -recursive` y `terraform validate` (root y `lb/`)
sobre una copia limpia del repo.

**Pendiente**:

1. **T1.17** — opcional/documentación, sin urgencia; el usuario indicó
   explícitamente que no le preocupa la fiabilidad exacta de la CI, así que
   queda como nice-to-have.
2. **Fase 2 y Fase 3** cuando se decida invertir tiempo en calidad a largo
   plazo.
