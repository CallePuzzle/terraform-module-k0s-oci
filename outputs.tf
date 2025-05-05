output "public_ip" {
  value = module.instance["controllerworker"].public_ip
}

output "k0s_file_content" {
  value = local.k0s_file_content
}
