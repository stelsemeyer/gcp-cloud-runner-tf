variable "billing_account_name" {
  # needs to be the literal name
  # default = "Mein Rechnungskonto"
}

variable "user" {
  # your user email address, xy@gmail.com
  # default = "xy@gmail.com"
}

variable "project_id" {
  # your project id
  # default = "project_id"
}

locals {
  project_name = "stocks"
  # suffix project (id) with some random id to avoid namespace clashes
  project = "${local.project_name}-${random_id.id.hex}"
  region  = "us-east4"

  service_name  = "stocks-service"
  input_bucket  = "stocks-input-bucket"
  output_bucket = "stocks-output-bucket"

  image_name = "gcr.io/${local.project}/stocks"
  image_tag  = "latest"
  image_uri  = "${local.image_name}:${local.image_tag}"
}

resource "random_id" "id" {
  byte_length = 2
}
