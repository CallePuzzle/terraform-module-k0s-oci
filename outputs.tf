output "public_ip" {
  value = module.instance[local.controller_key].public_ip[0]
}

output "private_ip" {
  value = module.instance[local.controller_key].private_ip[0]
}

output "k0s_file_content" {
  value     = var.enable_k0s ? local.k0s_file_content : null
  sensitive = false
}

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = module.vcn.vcn_id
}

output "lb_id" {
  description = "OCID of the OCI Load Balancer"
  value       = module.lb.lb_id
}

output "lb_public_ip" {
  description = "Public IP of the OCI Load Balancer"
  value       = module.lb.lb_public_ip
}
