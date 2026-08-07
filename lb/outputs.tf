output "lb_id" {
  description = "OCID of the OCI Load Balancer"
  value       = oci_load_balancer_load_balancer.this.id
}

output "lb_public_ip" {
  description = "Public IP of the OCI Load Balancer (first reserved IP)"
  value       = length(oci_load_balancer_load_balancer.this.ip_address_details) > 0 ? oci_load_balancer_load_balancer.this.ip_address_details[0].ip_address : null
}
