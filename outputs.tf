output "public_ip" {
  value = module.instance["controllerworker"].public_ip[0]
}

output "private_ip" {
  value = module.instance["controllerworker"].private_ip[0]
}

output "k0s_file_content" {
  value     = var.enable_k0s ? local.k0s_file_content : null
  sensitive = false
}
