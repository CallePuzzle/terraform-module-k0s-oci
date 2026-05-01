locals {
  subnet_cidr_block = "10.2.0.0/24"

  base_security_rules = [
    # TCP 	22 SSH
    {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options = {
        min = 22
        max = 22
      }
    },
    # TCP 	80 HTTP
    {
      protocol = "6"
      source   = local.subnet_cidr_block
      tcp_options = {
        min = 80
        max = 80
      }
    },
    # TCP 	443 HTTPS
    {
      protocol = "6"
      source   = local.subnet_cidr_block
      tcp_options = {
        min = 443
        max = 443
      }
    },
  ]

  # https://docs.k0sproject.io/v1.23.6+k0s.2/networking/?h=netw#required-ports-and-protocols
  k0s_security_rules = [
    # TCP 	2380 	etcd peers
    {
      protocol = "6"
      source   = local.subnet_cidr_block
      tcp_options = {
        min = 2380
        max = 2380
      }
    },
    # TCP 	6443 	kube-apiserver
    {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options = {
        min = 6443
        max = 6443
      }
    },
    # TCP 	179 	kube-router
    {
      protocol = "6"
      source   = local.subnet_cidr_block
      tcp_options = {
        min = 179
        max = 179
      }
    },
    # UDP 	4789 	Calico
    {
      protocol = "17"
      source   = local.subnet_cidr_block
      udp_options = {
        min = 4789
        max = 4789
      }
    },
    # TCP 	10250 	kubelet
    {
      protocol = "6"
      source   = local.subnet_cidr_block
      tcp_options = {
        min = 10250
        max = 10250
      }
    },
    # TCP 	9443 	k0s-api
    {
      protocol = "6"
      source   = local.subnet_cidr_block
      tcp_options = {
        min = 9443
        max = 9443
      }
    },
    # TCP 	8132 	konnectivity
    {
      protocol = "6"
      source   = local.subnet_cidr_block
      tcp_options = {
        min = 8132
        max = 8132
      }
    },
  ]

  additional_default_securty_list_ingress_rules = concat(
    local.base_security_rules,
    [for r in local.k0s_security_rules : r if var.enable_k0s],
  )
}

module "vcn" {
  source = "./vcn"

  vcn_name = "${var.name}-vcn"

  vcn_cidrs                = ["10.2.0.0/16"]
  compartment_id           = var.compartment_id
  create_internet_gateway  = true
  lockdown_default_seclist = false

  additional_default_securty_list_ingress_rules = local.additional_default_securty_list_ingress_rules

  subnets = {
    k0s = { name = var.name, cidr_block = local.subnet_cidr_block },
  }

  freeform_tags = {
    managed_by    = "terraform"
    module        = "oracle-terraform-modules/vcn/oci"
    "component"   = "vcn"
    "environment" = "pro"
    "part_of"     = var.name
  }
}
