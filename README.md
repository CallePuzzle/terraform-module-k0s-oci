# Terraform Module to install K0s on Oracle Cloud Infrastructure

This module installs a K0s cluster on Oracle Cloud Infrastructure, using only free tier resources.

## Prerequisites

- Terraform v1.4.6 or higher
- k0sctl v0.15.1 or higher
- An account with Oracle Cloud Infrastructure

## Usage

Get required variables from OCI: [https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm)

```bash
$ cat provider-vars.profile
export TF_VAR_tenancy_ocid=xxxx
export TF_VAR_user_ocid=xxxxx
export TF_VAR_fingerprint=xxxx
export TF_VAR_private_key_path=./private_key.pem
export TF_VAR_region=eu-marseille-1
```

### Required variables

| Variable | Description |
|----------|-------------|
| `compartment_id` | OCI compartment OCID in which to create all resources. |
| `ssh_public_key` | Public SSH key for instance access (e.g. `file("~/.ssh/id_rsa.pub")`). The default user is `ubuntu` (configurable via `ssh_user`). |

Configure the module, see an example in [test/main.tf](test/main.tf)

```terraform
provider "oci" {
}

module "oci-k0s" {
  source = "../"

  compartment_id  = "ocid1.tenancy.oc1..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  ssh_public_key  = file("~/.ssh/id_rsa.pub")
  k0s_config_path = "${path.root}/k0sctl.yaml"
}
```

```bash
source provider-vars.profile
terraform init
terraform apply
terraform apply # the second apply is required to get the public IP of the instance
k0sctl apply --disable-telemetry --config k0sctl.yaml
```

### Network security

By default, the cluster provisions with the following wide-open rules:

- TCP 22 (SSH) from `0.0.0.0/0`
- TCP 6443 (Kubernetes API) from `0.0.0.0/0`

These defaults are convenient for Always Free cloud-shell testing. For any
non-toy deployment, restrict them via:

```hcl
module "oci-k0s" {
  # ...
  ssh_allowed_cidrs = ["203.0.113.0/24"]   # your office / VPN
  api_allowed_cidrs = ["203.0.113.0/24"]
}
```

## Connect to Kubernetes API

[https://docs.k0sproject.io/v1.30.4+k0s.0/FAQ/?h=kubeconfig#how-do-i-connect-to-the-cluster](https://docs.k0sproject.io/v1.30.4+k0s.0/FAQ/?h=kubeconfig#how-do-i-connect-to-the-cluster)

```bash
ssh ubuntu@<public_ip>
sudo su -
kubectl get pods -A
```

## Connect to ArgoCD

```bash
echo "Admin password: $(kubectl --kubeconfig kubeconfig -n argocd get secret argocd-initial-admin-secret --template={{.data.password}} | base64 -D)"
kubectl --kubeconfig kubeconfig -n argocd port-forward service/argo-cd-argocd-server 8080:80
```
