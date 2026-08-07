variable "name" {
  description = "The name of the k0s cluster"
  type        = string
  default     = "k0s"
}

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment"
}

variable "vcn_id" {
  type        = string
  description = "The OCID of the VCN"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of subnet OCIDs"
}

variable "backend_ip_address" {
  type        = string
  description = "The IP address of the backend"
}

variable "certificate" {
  type = object({
    name               = string
    public_certificate = string
    private_key        = string
    ca_certificate     = optional(string)
  })
  description = "Certificate configuration for the load balancer"
  sensitive   = true
  default     = null
}

# DEPRECATED: use `certificate` object
variable "certificate_certificate_name" {
  type        = string
  description = "DEPRECATED: use `certificate` object"
  default     = null
}

variable "certificate_public_certificate" {
  type        = string
  description = "DEPRECATED: use `certificate` object"
  default     = null
  sensitive   = true
}

variable "certificate_private_key" {
  type        = string
  description = "DEPRECATED: use `certificate` object"
  default     = null
  sensitive   = true
}

variable "certificate_ca_certificate" {
  type        = string
  description = "DEPRECATED: use `certificate` object"
  default     = null
  sensitive   = true
}
