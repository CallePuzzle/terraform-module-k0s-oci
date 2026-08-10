variable "name" {
  description = "The name of the k0s cluster"
  type        = string
  default     = "k0s"
}

variable "environment" {
  description = "Environment tag applied to all resources (e.g. dev, staging, prod). Defaults to 'dev' since the module is intended for Always Free tier."
  type        = string
  default     = "dev"
}

variable "enable_k0s" {
  description = "Enable k0s deployment and its associated resources. If false, a plain instance with only basic networking is created."
  type        = bool
  default     = true
}

variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

variable "source_ocid" {
  description = "The OCID of the source image"
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "The public SSH key to use for the k0s cluster"
  type        = string
}

variable "ssh_user" {
  description = "The SSH user to use for connecting to instances"
  type        = string
  default     = "ubuntu"
}

variable "k0s_config_path" {
  description = "The path to the k0s config file"
  type        = string
  default     = null
}

variable "k0s_version" {
  description = "The version of k0s to install"
  type        = string
  default     = "1.30.4+k0s.0"

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+\\+k0s\\.\\d+$", var.k0s_version))
    error_message = "k0s_version must follow the format MAJOR.MINOR.PATCH+k0s.N (e.g. 1.30.0+k0s.0)."
  }
}

variable "k0s_create_file" {
  description = "Create the k0s config file"
  type        = bool
  default     = true
}

variable "enable_argocd" {
  description = "Enable ArgoCD"
  type        = bool
  default     = true
}

variable "enable_nginx" {
  description = "Enable nginx"
  type        = bool
  default     = true
}

variable "enable_argocd_apps" {
  description = "Enable ArgoCD apps"
  type        = bool
  default     = true
}

variable "enable_openebs" {
  description = "Deploy OpenEBS local storage via the extensions.helm chart (https://docs.k0sproject.io/head/examples/openebs/). Replaces the deprecated no-op extensions.storage.type field."
  type        = bool
  default     = false
}

variable "argocd_host" {
  description = "The hostname of the ArgoCD server. Required when enable_argocd=true and argocd_values is left empty (default), because the default values deploy an ingress that needs a host."
  type        = string
  default     = null

  validation {
    condition     = var.enable_k0s && var.enable_argocd && var.argocd_values == {} ? var.argocd_host != null && var.argocd_host != "" : true
    error_message = "argocd_host is required when enable_k0s=true, enable_argocd=true and argocd_values is empty. Either set argocd_host or provide a custom argocd_values object."
  }
}

variable "projects" {
  description = "ArgoCD projects"
  type = list(object({
    name = string
    source = object({
      repo_url        = string
      target_revision = string
      path            = optional(string, ".")
      plugin          = optional(string, "")
    })
    destination_namespace = string
    auto_sync             = optional(bool, true)
  }))
  default = []
}

variable "argocd_values" {
  description = "Replace the default ArgoCD values.yaml with this yaml object"
  default     = {}
}

variable "additional_security_list_rules" {
  description = "Additional ingress rules for the default security list"
  type = list(object({
    protocol    = string
    source      = string
    tcp_options = optional(map(number), null)
    udp_options = optional(map(number), null)
  }))
  default = []
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to access the instances via SSH (TCP 22). Defaults to 0.0.0.0/0 for Always Free convenience; restrict this in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "api_allowed_cidrs" {
  description = "CIDR blocks allowed to reach the Kubernetes API server (TCP 6443). Defaults to 0.0.0.0/0 for Always Free convenience; restrict this in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
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
