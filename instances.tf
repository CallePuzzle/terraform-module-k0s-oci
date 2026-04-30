data "oci_core_images" "this" {
  for_each = local.instances

  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = each.value.shape
}

locals {
  instances = {
    controllerworker = {
      instance_count              = 1
      instance_display_name       = "${var.name}-controller-worker"
      shape                       = "VM.Standard.A1.Flex"
      instance_flex_memory_in_gbs = 24
      instance_flex_ocpus         = 4
      boot_volume_size_in_gbs     = 200
    }
  }
}

module "instance" {
  source = "oracle-terraform-modules/compute-instance/oci"

  for_each = local.instances

  compartment_ocid      = var.compartment_id
  ad_number             = 1
  instance_count        = each.value.instance_count
  instance_display_name = each.value.instance_display_name
  instance_state        = "RUNNING"

  source_ocid = var.source_ocid != null ? var.source_ocid : data.oci_core_images.this[each.key].images.0.id
  source_type = "image"

  shape                       = each.value.shape
  instance_flex_memory_in_gbs = each.value.instance_flex_memory_in_gbs
  instance_flex_ocpus         = each.value.instance_flex_ocpus
  baseline_ocpu_utilization   = "BASELINE_1_1"
  boot_volume_size_in_gbs     = each.value.boot_volume_size_in_gbs

  cloud_agent_plugins = {
    java_management_service = "DISABLED"
    autonomous_linux        = "ENABLED"
    bastion                 = "DISABLED"
    vulnerability_scanning  = "ENABLED"
    osms                    = "ENABLED"
    management              = "DISABLED"
    custom_logs             = "ENABLED"
    run_command             = "ENABLED"
    monitoring              = "ENABLED"
    block_volume_mgmt       = "DISABLED"
  }

  ssh_public_keys = var.ssh_public_key
  user_data       = base64encode(templatefile("${path.module}/templates/user-data.sh.tmpl", {
    deployment_mode = var.deployment_mode
  }))

  public_ip    = "EPHEMERAL"
  subnet_ocids = [module.vcn.subnet_id["k0s"]]

  freeform_tags = {
    managed_by    = "terraform"
    module        = "oracle-terraform-modules/compute-instance/oci"
    "component"   = "instance"
    "environment" = "pro"
    "part_of"     = var.deployment_mode
  }
}
