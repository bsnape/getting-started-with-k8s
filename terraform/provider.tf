variable "gcp_credentials_file" {}

provider "google" {
  version     = "~> 1.4"
  credentials = "${file("${var.gcp_credentials_file}")}"
  project     = "${var.project}"
  region      = "${var.region}"
}
