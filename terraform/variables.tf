variable "billing_account_name" {
  # needs to be the literal name
  # default = "Mein Rechnungskonto"
}

variable "user" {
  # your user email address, xy@gmail.com
  # default = "xy@gmail.com"
}

locals {
  project_name = "cloud-runner"
  # suffix project (id) with some random id to avoid namespace clashes
  project = "${local.project_name}-${random_id.id.hex}"
  region  = "europe-west3"

  service_name  = "cloud-runner-service"
  input_bucket  = "cloud-runner-input-bucket"
  output_bucket = "cloud-runner-output-bucket"

  image_name = "gcr.io/${local.project}/cloud-runner"
  image_tag  = "latest"
  image_uri  = "${local.image_name}:${local.image_tag}"
}

resource "random_id" "id" {
  byte_length = 2
}
