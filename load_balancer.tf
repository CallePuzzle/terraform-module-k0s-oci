module "lb" {
  source = "./lb"

  name = var.name

  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  subnet_ids     = [module.vcn.subnet_id["k0s"]]

  backend_ip_address = module.instance[local.controller_key].private_ip[0]

  certificate_certificate_name   = var.certificate != null ? var.certificate.name : var.certificate_certificate_name
  certificate_public_certificate = var.certificate != null ? var.certificate.public_certificate : var.certificate_public_certificate
  certificate_private_key        = var.certificate != null ? var.certificate.private_key : var.certificate_private_key
  certificate_ca_certificate     = var.certificate != null ? var.certificate.ca_certificate : var.certificate_ca_certificate
}
