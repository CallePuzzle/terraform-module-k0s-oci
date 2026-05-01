locals {
  argocd_values = var.argocd_values != {} ? var.argocd_values : templatefile("${path.module}/templates/argocd-values.yaml.tmpl", {
    argocd_host = var.argocd_host
  })
  k0s_file_content = var.enable_k0s ? templatefile("${path.module}/templates/k0sctl.yaml.tmpl", {
    private_ip         = module.instance["controllerworker"].private_ip[0]
    public_ip          = module.instance["controllerworker"].public_ip[0]
    k0s_version        = var.k0s_version
    projects           = var.projects
    enable_argocd      = var.enable_argocd
    enable_argocd_apps = var.enable_argocd_apps
    enable_nginx       = var.enable_nginx
    argocd_values      = <<EOF
${local.argocd_values}
EOF
  }) : null
}

resource "local_file" "k0sctl" {
  count    = var.enable_k0s && var.k0s_create_file ? 1 : 0
  filename = var.k0s_config_path
  content  = local.k0s_file_content
}
