provider "oci" {
}

module "oci-k0s" {
  source = "../"

  compartment_id  = "ocid1.tenancy.oc1..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  k0s_config_path = "${path.root}/k0sctl.yaml"
}
