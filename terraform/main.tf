provider "google" {
  project = local.project
  region  = local.region
}

data "google_billing_account" "account" {
  # this needs to be the literal name
  display_name = var.billing_account_name
}

resource "google_project" "project" {
  name            = local.project_name
  project_id      = local.project
  billing_account = data.google_billing_account.account.id
}

resource "google_project_iam_member" "project_owner" {
  role   = "roles/owner"
  member = "user:${var.user}"

  depends_on = [
    google_project.project,
  ]
}

resource "google_storage_bucket" "storage_input_bucket" {
  name = local.input_bucket

  depends_on = [
    google_project_iam_member.project_owner,
  ]
}

resource "google_storage_bucket" "storage_output_bucket" {
  name = local.output_bucket

  depends_on = [
    google_project_iam_member.project_owner,
  ]
}

resource "google_project_service" "cloud_run_service" {
  service = "run.googleapis.com"

  depends_on = [
    google_project.project,
  ]
}

resource "google_cloud_run_service" "cloud_run_service" {
  name     = local.service_name
  location = local.region

  template {
    spec {
      containers {
        image = local.image_uri

        resources {
          limits = {
            cpu    = "2000m"
            memory = "2048Mi"
          }
        }

        env {
          name  = "OUTPUT_BUCKET"
          value = google_storage_bucket.storage_output_bucket.url
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project.project,
    google_project_service.cloud_run_service,
    null_resource.app_container,
  ]
}

# use null resource provisioner to build initial image which is required by runner
resource "null_resource" "app_container" {
  provisioner "local-exec" {
    command = "(cd ../app && ./build.sh && IMAGE_URI=${local.image_uri} ./push.sh)"
  }

  depends_on = [
    google_project.project,
  ]
}

resource "google_service_account" "service_account" {
  account_id = "cloud-runner-service-account"

  depends_on = [
    google_project_iam_member.project_owner,
  ]
}

resource "google_cloud_run_service_iam_member" "iam_member" {
  service  = google_cloud_run_service.cloud_run_service.name
  location = google_cloud_run_service.cloud_run_service.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_storage_notification" "storage_notification" {
  bucket         = google_storage_bucket.storage_input_bucket.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.pubsub_topic.id
  # only watch out for new objects being successfully created
  event_types = ["OBJECT_FINALIZE"]

  depends_on = [
    google_pubsub_topic_iam_binding.iam_binding,
  ]
}

// enable notifications by giving the correct IAM permission to the unique service account.
data "google_storage_project_service_account" "gcs_account" {
  depends_on = [
    google_project.project,
  ]
}

resource "google_pubsub_topic_iam_binding" "iam_binding" {
  topic   = google_pubsub_topic.pubsub_topic.id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]

  depends_on = [
    google_pubsub_topic.pubsub_topic,
  ]
}
// end enabling notifications

resource "google_pubsub_topic" "pubsub_topic" {
  name = "cloud-runner-topic"

  depends_on = [
    google_project_iam_member.project_owner,
  ]
}

resource "google_pubsub_subscription" "pubsub_subcription" {
  name  = "cloud-runner-subscription"
  topic = google_pubsub_topic.pubsub_topic.name

  ack_deadline_seconds = 600

  retry_policy {
    minimum_backoff = "60s"
    maximum_backoff = "600s"
  }

  push_config {
    push_endpoint = google_cloud_run_service.cloud_run_service.status[0].url

    attributes = {
      x-goog-version = "v1"
    }

    # service to service auth, as this is not deployed publicly
    oidc_token {
      service_account_email = google_service_account.service_account.email
    }
  }

  depends_on = [
    google_project.project,
  ]
}

# service account for cloud run to work properly
resource "google_project_iam_binding" "project" {
  role = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:service-${google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com",
  ]

  depends_on = [
    google_pubsub_subscription.pubsub_subcription,
  ]
}
