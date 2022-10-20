output "project_id" {
  value = local.project
}

# output "project_number" {
#   value = data.google_project.project.number
# }
output "image_uri" {
  value = local.image_uri
}

output "service_name" {
  value = local.service_name
}

output "input_bucket" {
  value = local.input_bucket
}

output "output_bucket" {
  value = local.output_bucket
}
