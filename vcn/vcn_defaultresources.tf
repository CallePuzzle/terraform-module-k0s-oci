# Copyright (c) 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# VCN default Security List Lockdown
// See Issue #22 for the reasoning
resource "oci_core_default_security_list" "lockdown" {
  // If variable is true, removes all rules from default security list
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id

  count = var.lockdown_default_seclist == true ? 1 : 0

  lifecycle {
    ignore_changes = [egress_security_rules, ingress_security_rules, defined_tags]
  }

}

resource "oci_core_default_security_list" "restore_default" {
  // If variable is false, restore all default rules to default security list
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id

  egress_security_rules {
    // allow all egress traffic
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  // SSH (22) is governed exclusively by ssh_allowed_cidrs of the root module
  // (default: caller public IP /32 since v1.6.0); no global SSH rule is injected here.

  ingress_security_rules {
    // allow ICMP for all type 3 code 4
    protocol = "1"
    source   = "0.0.0.0/0"

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  dynamic "ingress_security_rules" {
    //allow all ICMP from all VCN CIDRs
    for_each = oci_core_vcn.vcn.cidr_blocks
    iterator = vcn_cidr
    content {
      protocol = "1"
      source   = vcn_cidr.value
      icmp_options {
        type = "3"
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.additional_default_securty_list_ingress_rules
    iterator = rule
    content {
      protocol = rule.value.protocol
      source   = rule.value.source
      dynamic "tcp_options" {
        for_each = rule.value.tcp_options == null ? [] : [rule.value.tcp_options]
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }
      dynamic "udp_options" {
        for_each = rule.value.udp_options == null ? [] : [rule.value.udp_options]
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }
    }
  }

  count = var.lockdown_default_seclist == false ? 1 : 0
}
