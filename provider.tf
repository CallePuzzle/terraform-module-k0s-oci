terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 9.0.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}
