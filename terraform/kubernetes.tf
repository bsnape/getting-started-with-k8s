variable "k8s_username" {}
variable "k8s_password" {}
variable "k8s_cluster_name" {}

resource "google_container_cluster" "primary" {
  name               = "${var.k8s_cluster_name}"
  zone               = "${var.region}-a"
  initial_node_count = 1 # single node cluster

  master_auth {
    username = "${var.k8s_username}"
    password = "${var.k8s_password}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels {
      foo = "bar"
    }

    tags = ["foo", "bar"]
  }
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}
