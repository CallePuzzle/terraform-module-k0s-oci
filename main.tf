locals {
  # Validate required variables
  _validate_compartment_id = var.compartment_id != null && var.compartment_id != "" ? true : error("compartment_id is required")
  _validate_k0s_version    = var.k0s_version != null && var.k0s_version != "" ? true : error("k0s_version is required")

  argocd_values = var.argocd_values != {} ? var.argocd_values : (
    var.argocd_host != null ? templatefile("${path.module}/templates/argocd-values.yaml.tmpl", {
      argocd_host = var.argocd_host
    }) : {}
  )
  k0s_file_content = var.enable_k0s ? templatefile("${path.module}/templates/k0sctl.yaml.tmpl", {
    private_ip         = module.instance[local.controller_key].private_ip[0]
    public_ip          = module.instance[local.controller_key].public_ip[0]
    k0s_version        = var.k0s_version
    projects           = var.projects
    enable_argocd      = var.enable_argocd
    enable_argocd_apps = var.enable_argocd_apps
    enable_nginx       = var.enable_nginx
    enable_openebs     = var.enable_openebs
    argocd_values      = <<EOF
${local.argocd_values}
EOF
    ssh_user           = var.ssh_user
  }) : null
}

resource "local_file" "k0sctl" {
  count    = var.enable_k0s && var.k0s_create_file ? 1 : 0
  filename = var.k0s_config_path
  content  = local.k0s_file_content
}
