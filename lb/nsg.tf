resource "oci_core_network_security_group" "this" {
  compartment_id = var.compartment_id
  display_name   = "${var.name}-lb"
  vcn_id         = var.vcn_id
}

# One rule per CIDR (keyed by CIDR) so allowlists such as the Cloudflare ranges
# can be passed as a plain list.
resource "oci_core_network_security_group_security_rule" "http" {
  for_each = toset(var.allowed_cidrs)

  network_security_group_id = oci_core_network_security_group.this.id
  description               = "Allow http access from public load balancer"
  direction                 = "INGRESS"
  protocol                  = 6 # TCP
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "https" {
  for_each = toset(var.allowed_cidrs)

  network_security_group_id = oci_core_network_security_group.this.id
  description               = "Allow https access from public load balancer"
  direction                 = "INGRESS"
  protocol                  = 6 # TCP
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

# Rules were single resources before allowed_cidrs existed; keep the default
# 0.0.0.0/0 rule in place instead of recreating it.
moved {
  from = oci_core_network_security_group_security_rule.http
  to   = oci_core_network_security_group_security_rule.http["0.0.0.0/0"]
}

moved {
  from = oci_core_network_security_group_security_rule.https
  to   = oci_core_network_security_group_security_rule.https["0.0.0.0/0"]
}
