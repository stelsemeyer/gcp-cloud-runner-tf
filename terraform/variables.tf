variable "billing_account_name" {
  # needs to be the literal name
  # default = "My billing account"
}

variable "user" {
  # user email address, xy@gmail.com
  # default = "xy@gmail.com"
}

variable "project_id" {
  #  project id
  # default = "project_id"
}

locals {
  project_name = "cloud-runner"
  # suffix project (id) with some random id to avoid namespace clashes
  project = "${local.project_name}-${random_id.id.hex}"
  region  = "us-east4"

  service_name  = "cloud-runner-service"
  input_bucket  = "cloud-runner-input"
  output_bucket = "cloud-runner-output"

  image_name = "gcr.io/${local.project}/cloud-runner"
  image_tag  = "latest"
  image_uri  = "${local.image_name}:${local.image_tag}"
}

resource "random_id" "id" {
  byte_length = 2
}
