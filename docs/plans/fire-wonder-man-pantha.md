# Plan: Eliminar modo Podman y simplificar a `enable_k0s`

## Objetivo

Eliminar toda la lógica y configuración relacionada con el modo de despliegue `podman` introducida en el diff actual respecto a `main`. Reemplazar la variable `deployment_mode` por una variable booleana `enable_k0s` (default: `true`). Actualizar el consumidor del módulo (`jilguedev`) para usar la nueva interfaz.

## Repositorios afectados

1. `terraform-module-k0s-oci` — el módulo Terraform
2. `villajilguero-oci-services/jilguedev` — el workspace que consume el módulo

## Cambios en `terraform-module-k0s-oci`

### 1. `variables.tf`
- **Eliminar** `variable "deployment_mode"` y su bloque `validation`.
- **Eliminar** `variable "enable_load_balancer"` (ya no es necesaria; el LB siempre estará activo).
- **Añadir** `variable "enable_k0s"`:
  ```hcl
  variable "enable_k0s" {
    description = "Habilitar el despliegue de k0s y sus recursos asociados. Si es false, se crea una instancia plana con solo red básica."
    type        = bool
    default     = true
  }
  ```
- **Mantener** `ssh_public_key` (mejora general no exclusiva de podman).
- **Mantener** `k0s_create_file` (mejora general).

### 2. `instances.tf`
- Mantener `user_data` usando `templatefile` con la variable `enable_k0s`:
  ```hcl
  user_data = base64encode(templatefile("${path.module}/templates/user-data.sh.tmpl", {
    enable_k0s = var.enable_k0s
  }))
  ```
- Cambiar `part_of` a etiqueta fija `"k0s"` o condicional `"k0s"` / `"plain"` según `var.enable_k0s`.
- **Mantener** `ssh_public_keys = var.ssh_public_key`.

### 3. `templates/user-data.sh.tmpl`
- Eliminar toda la lógica condicional de `deployment_mode == "podman"`.
- Reemplazar por condicional basado en `enable_k0s`:
  - Si `enable_k0s == true`: instalar `kubectl`, configurar kubeconfig en `.bashrc`.
  - Si `enable_k0s == false`: solo ejecutar upgrade, deshabilitar ufw/iptables, y reboot. Nada de k0s ni podman.

### 4. `vcn.tf`
- Definir dos grupos de reglas:
  - `base_security_rules`: puertos siempre abiertos — TCP 22 (SSH), TCP 80 (HTTP), TCP 443 (HTTPS).
  - `k0s_security_rules`: puertos adicionales para k0s — 6443, 2380, 179, 10250, 9443, 8132, UDP 4789.
- Concatenar condicionalmente:
  ```hcl
  additional_default_securty_list_ingress_rules = var.enable_k0s ? concat(local.base_security_rules, local.k0s_security_rules) : local.base_security_rules
  ```
- Eliminar la lógica `slice(...)` y `deployment_mode`.

### 5. `main.tf`
- Reemplazar `var.deployment_mode == "k0s"` por `var.enable_k0s` en:
  - `local.k0s_file_content`
  - `count` del recurso `local_file.k0sctl`

### 6. `outputs.tf`
- Reemplazar `var.deployment_mode == "k0s"` por `var.enable_k0s` en el output `k0s_file_content`.
- **Mantener** `private_ip`.

### 7. `load_balancer.tf`
- **Eliminar** cualquier `count` condicional.
- El LB se crea siempre (comportamiento original de `main`, antes del diff de podman).

### 8. `templates/k0sctl.yaml.tmpl`
- **Mantener** las actualizaciones de versiones de charts (no son de podman).

### 9. `AGENTS.md`
- **Mantener**.

## Cambios en `villajilguero-oci-services/jilguedev`

### 1. `main.tf`
- Reemplazar `deployment_mode = "k0s"` por `enable_k0s = true`.
- **Eliminar** todo el bloque comentado `# Ejemplo de uso para modo podman:` y el `module "oci-podman"` comentado.

## Pasos de ejecución

1. Editar `terraform-module-k0s-oci/variables.tf`.
2. Editar `terraform-module-k0s-oci/instances.tf`.
3. Reescribir `terraform-module-k0s-oci/templates/user-data.sh.tmpl` con lógica `enable_k0s`.
4. Editar `terraform-module-k0s-oci/vcn.tf`.
5. Editar `terraform-module-k0s-oci/main.tf`.
6. Editar `terraform-module-k0s-oci/outputs.tf`.
7. Editar `terraform-module-k0s-oci/load_balancer.tf`.
8. Editar `villajilguero-oci-services/jilguedev/main.tf`.
9. Validar con `terraform fmt` en ambos directorios.
10. (Opcional) `terraform plan` en `jilguedev` para verificar que no hay breaking changes no deseados.

## Notas

- Las mejoras generales introducidas en el mismo diff (`ssh_public_key`, outputs `private_ip`/`k0s_file_content`, `k0s_create_file`, versiones de charts) se conservan.
- Con `enable_k0s = true` el comportamiento es idéntico al despliegue k0s actual.
- Con `enable_k0s = false` se obtiene una instancia Ubuntu limpia con red básica (22, 80, 443) y load balancer activo.
