module "lb" {
  source = "./lb"

  name = var.name

  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  subnet_ids     = [module.vcn.subnet_id["k0s"]]

  backend_ip_address = module.instance["controllerworker"].private_ip[0]
}