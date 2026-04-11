# Terraform Module: K0s on OCI

## Project Overview

This is a Terraform module that automates the deployment of a [K0s](https://k0sproject.io/) Kubernetes cluster on [Oracle Cloud Infrastructure (OCI)](https://cloud.oracle.com/). It is designed to use **only OCI Always Free tier resources**, making it cost-effective for development, testing, and small production workloads.

The module provisions:
- A Virtual Cloud Network (VCN) with appropriate security rules for K0s
- A single OCI compute instance (VM.Standard.A1.Flex) acting as both controller and worker node
- An optional load balancer for external traffic
- K0s cluster configuration via `k0sctl`
- Optional ArgoCD for GitOps deployment management
- Optional NGINX Ingress Controller

## Technology Stack

### Required Tools
- **Terraform** >= v1.4.6
- **k0sctl** >= v0.15.1
- **OCI Account** with appropriate credentials

### Providers
- `oracle/oci` >= 6.18.0 (Oracle Cloud Infrastructure provider)
- `hashicorp/local` (for generating k0sctl configuration file)

### Key Technologies
- **K0s**: Lightweight Kubernetes distribution (default: v1.27.4+k0s.0)
- **Ubuntu 24.04**: Base operating system for compute instances
- **ArgoCD**: Optional GitOps continuous delivery tool (default: enabled)
- **NGINX Ingress**: Optional ingress controller (default: enabled)

## Project Structure

```
.
├── main.tf                    # Root module - k0sctl config file generation
├── variables.tf               # Input variable definitions
├── outputs.tf                 # Output definitions (public_ip, k0s_file_content)
├── provider.tf                # Terraform provider configuration
├── instances.tf               # OCI compute instance configuration
├── vcn.tf                     # VCN and network security configuration
├── load_balancer.tf           # Load balancer module invocation
├── user-data.sh               # Cloud-init script for instance setup
├── .gitignore                 # Git ignore patterns
├── .releaserc.json            # Semantic-release configuration
├── LICENSE                    # GNU GPL v3 license
├── README.md                  # User documentation
│
├── lb/                        # Load balancer submodule
│   ├── main.tf                # LB resources (backend sets, listeners)
│   ├── nsg.tf                 # Network security group rules
│   ├── provider.tf            # Provider version constraints
│   └── variables.tf           # Submodule variables
│
├── templates/                 # Configuration templates
│   ├── k0sctl.yaml.tmpl       # K0s cluster configuration template
│   └── argocd-values.yaml.tmpl # ArgoCD Helm values template
│
├── test/                      # Test/example configuration
│   └── main.tf                # Example module invocation
│
└── vcn/                       # VCN submodule (oracle-terraform-modules/vcn fork)
    ├── vcn.tf                 # VCN resource definition
    ├── vcn_gateways.tf        # Internet/NAT/Service gateways
    ├── vcn_defaultresources.tf # Default security list management
    ├── variables.tf           # VCN module variables
    ├── outputs.tf             # VCN module outputs
    ├── versions.tf            # Version constraints
    ├── locals.tf              # Local values
    ├── modules/subnet/        # Subnet submodule
    └── examples/              # Usage examples
```

## Module Architecture

### Compute Configuration
- **Shape**: VM.Standard.A1.Flex (ARM-based, Always Free eligible)
- **Resources**: 4 OCPUs, 24 GB RAM
- **Boot Volume**: 200 GB
- **OS**: Canonical Ubuntu 24.04
- **Role**: Combined controller+worker node

### Network Configuration
- **VCN CIDR**: 10.2.0.0/16
- **Subnet CIDR**: 10.2.0.0/24
- **Internet Gateway**: Enabled for external connectivity

### Required Ports (Security List)
The following ports are automatically opened in the VCN security list:
- TCP 80 (HTTP) - Internal
- TCP 443 (HTTPS) - Internal
- TCP 6443 (kube-apiserver) - External (0.0.0.0/0)
- TCP 2380 (etcd peers) - Internal
- TCP 179 (kube-router) - Internal
- TCP 10250 (kubelet) - Internal
- TCP 9443 (k0s-api) - Internal
- TCP 8132 (konnectivity) - Internal
- UDP 4789 (Calico VXLAN) - Internal

## Usage

### 1. Configure OCI Credentials

Create a `provider-vars.profile` file:
```bash
export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..
export TF_VAR_user_ocid=ocid1.user.oc1..
export TF_VAR_fingerprint=xx:xx:xx:...
export TF_VAR_private_key_path=./private_key.pem
export TF_VAR_region=eu-marseille-1
```

### 2. Create Main Configuration

```hcl
provider "oci" {}

module "oci-k0s" {
  source = "path/to/this/module"

  compartment_id  = "ocid1.tenancy.oc1.."
  ssh_public_key  = file("~/.ssh/id_rsa.pub")
  k0s_config_path = "${path.root}/k0sctl.yaml"
}
```

### 3. Deploy Infrastructure

```bash
source provider-vars.profile
terraform init
terraform apply
terraform apply  # Second apply required to get the public IP
```

### 4. Deploy K0s Cluster

```bash
k0sctl apply --disable-telemetry --config k0sctl.yaml
```

## Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `compartment_id` | OCI compartment OCID (required) | - |
| `ssh_public_key` | Public SSH key for instance access | - |
| `k0s_version` | K0s version to install | "1.27.4+k0s.0" |
| `k0s_config_path` | Path to generate k0sctl.yaml | null |
| `enable_argocd` | Deploy ArgoCD | true |
| `enable_nginx` | Deploy NGINX Ingress | true |
| `enable_argocd_apps` | Deploy ArgoCD Apps | true |
| `projects` | List of ArgoCD projects | [] |
| `argocd_values` | Custom ArgoCD Helm values | {} |
| `argocd_host` | ArgoCD ingress hostname | null |

## Accessing the Cluster

### Via SSH
```bash
ssh ubuntu@<public_ip>
sudo su -
kubectl get pods -A
```

### Via Kubeconfig
Retrieve the kubeconfig from the server:
```bash
k0sctl kubeconfig --config k0sctl.yaml > kubeconfig
kubectl --kubeconfig kubeconfig get pods -A
```

### ArgoCD Access
```bash
# Get admin password
echo "Admin password: $(kubectl --kubeconfig kubeconfig -n argocd get secret argocd-initial-admin-secret --template={{.data.password}} | base64 -d)"

# Port-forward ArgoCD server
kubectl --kubeconfig kubeconfig -n argocd port-forward service/argo-cd-argocd-server 8080:80
```

## ArgoCD Project Configuration

Define GitOps projects via the `projects` variable:

```hcl
projects = [
  {
    name = "my-app"
    source = {
      repo_url        = "https://github.com/org/repo"
      target_revision = "main"
      path            = "k8s/"
    }
    destination_namespace = "default"
    auto_sync = true
  }
]
```

## Release Process

This project uses [semantic-release](https://semantic-release.gitbook.io/) for automated versioning and releases.

### Configuration (`.releaserc.json`)
- Branch: `main`
- Plugins:
  - `@semantic-release/commit-analyzer` - Parse commit messages
  - `@semantic-release/release-notes-generator` - Generate release notes
  - `@semantic-release/github` - Create GitHub releases

### Triggering Releases
Push commits to `main` following [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` → Minor version bump
- `fix:` → Patch version bump
- `BREAKING CHANGE:` → Major version bump

## Code Style Guidelines

### Terraform Conventions
- Use snake_case for variable and resource names
- Always include `description` for variables
- Use type constraints for all variables
- Group related resources logically in separate files
- Use `for_each` instead of `count` for resource sets with meaningful keys

### File Organization
- `variables.tf`: All input variables
- `outputs.tf`: All outputs
- `main.tf`: Primary resource logic
- `provider.tf`: Provider configuration
- `<feature>.tf`: Feature-specific resources (e.g., `instances.tf`, `vcn.tf`)

### Tagging Standards
All resources should include consistent freeform tags:
```hcl
freeform_tags = {
  managed_by    = "terraform"
  module        = "module-name"
  component     = "component-name"
  environment   = "pro"
  part_of       = "k0s"
}
```

## Security Considerations

### SSH Access
- The module requires an SSH public key for instance access
- Private key should never be committed to the repository (see `.gitignore`)
- Default user: `ubuntu`

### Network Security
- kube-apiserver (6443) is exposed to 0.0.0.0/0 by default
- Consider restricting access via `additional_default_securty_list_ingress_rules`
- UFW and iptables are disabled on instances via `user-data.sh`

### Sensitive Data
The following files are gitignored:
- `provider-vars.profile` (OCI credentials)
- `private_key.pem` (SSH private key)
- `test/k0sctl.yaml` (generated config)
- `test/kubeconfig` (cluster credentials)
- `*.tfstate*` (Terraform state)
- `.terraform/` (Terraform cache)

### State Management
- Terraform state files may contain sensitive data
- Use remote state (OCI Object Storage, Terraform Cloud) for production
- Enable state encryption

## Troubleshooting

### Common Issues

1. **Public IP not available on first apply**
   - Run `terraform apply` a second time
   - This is a known timing issue with OCI compute instances

2. **k0sctl connection failures**
   - Ensure SSH key is correctly specified
   - Verify security list rules allow port 22
   - Wait for cloud-init to complete (`cloud-init status --wait`)

3. **ArgoCD ingress not working**
   - Verify `argocd_host` is set correctly
   - Check NGINX ingress controller is running
   - Ensure load balancer is in healthy state

## License

This project is licensed under the **GNU General Public License v3.0**.

The VCN submodule contains code derived from [oracle-terraform-modules/terraform-oci-vcn](https://github.com/oracle-terraform-modules/terraform-oci-vcn), licensed under the Universal Permissive License 1.0.
