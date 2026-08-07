locals {
  has_certificate = var.certificate != null ? var.certificate.public_certificate != null : var.certificate_public_certificate != null
}

data "oci_load_balancer_shapes" "this" {
  compartment_id = var.compartment_id
}

resource "oci_load_balancer_load_balancer" "this" {

  compartment_id = var.compartment_id
  display_name   = "${var.name}-lb"

  subnet_ids                 = var.subnet_ids
  is_private                 = false
  network_security_group_ids = [oci_core_network_security_group.this.id]

  shape = data.oci_load_balancer_shapes.this.shapes[0].name
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }
}

resource "oci_load_balancer_backend_set" "https" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = "${var.name}-backend-set-https"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = 443
    retries           = 3
    timeout_in_millis = 3000
  }
}

resource "oci_load_balancer_backend_set" "http" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = "${var.name}-backend-set-http"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = 80
    retries           = 3
    timeout_in_millis = 3000
  }
}

resource "oci_load_balancer_backend" "https" {
  backendset_name  = oci_load_balancer_backend_set.https.name
  ip_address       = var.backend_ip_address
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  port             = 443
}

resource "oci_load_balancer_backend" "http" {
  backendset_name  = oci_load_balancer_backend_set.http.name
  ip_address       = var.backend_ip_address
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  port             = 80
}

resource "oci_load_balancer_certificate" "this" {
  count = local.has_certificate ? 1 : 0

  load_balancer_id   = oci_load_balancer_load_balancer.this.id
  certificate_name   = var.certificate != null ? var.certificate.name : var.certificate_certificate_name
  public_certificate = var.certificate != null ? var.certificate.public_certificate : var.certificate_public_certificate
  private_key        = var.certificate != null ? var.certificate.private_key : var.certificate_private_key
  ca_certificate     = var.certificate != null ? var.certificate.ca_certificate : var.certificate_ca_certificate
}

resource "oci_load_balancer_listener" "https" {
  default_backend_set_name = oci_load_balancer_backend_set.https.name
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "${var.name}-listener-https"
  port                     = 443
  protocol                 = "TCP"

  dynamic "ssl_configuration" {
    for_each = local.has_certificate ? [1] : []
    content {
      certificate_name        = oci_load_balancer_certificate.this[0].certificate_name
      verify_peer_certificate = false
    }
  }
}

resource "oci_load_balancer_listener" "http" {
  default_backend_set_name = oci_load_balancer_backend_set.http.name
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "${var.name}-listener-http"
  port                     = 80
  protocol                 = "TCP"
}
