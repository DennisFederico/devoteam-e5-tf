terraform {
  required_providers {
    confluent = {
      source = "confluentinc/confluent"
      version = "2.7.0"
    }
  }
}

provider "confluent" {
  # kafka_rest_endpoint = var.kafka_rest_endpoint        # optionally use KAFKA_REST_ENDPOINT env var
  # kafka_api_key       = var.kafka_api_key              # optionally use KAFKA_API_KEY env var
  # kafka_api_secret    = var.kafka_api_secret           # optionally use KAFKA_API_SECRET env var
}

module "application" {
  for_each = var.apps
  source = "./modules/application"
  environment_name  = var.environment_name
  kafka_cluster_name = var.kafka_cluster_name
  application_id = each.key
  topics = each.value.app_topics
  external_topics = each.value.external_topics
}

#### ITERATE OVER APPLICATIONS AND FETCH module.application.keys AND USE IT IN A "VAULT" GCP RESOURCE