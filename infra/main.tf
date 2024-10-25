terraform {
  required_providers {
    confluent = {
      source = "confluentinc/confluent"
      version = "2.7.0"
    }
  }
}

provider "confluent" {
#     cloud_api_key    = var.confluent_cloud_api_key    # optionally use CONFLUENT_CLOUD_API_KEY env var
#     cloud_api_secret = var.confluent_cloud_api_secret # optionally use CONFLUENT_CLOUD_API_SECRET env var
}

module "cluster" {
  source = "./modules/cluster"

  environment_name = var.environment_name
  kafka_cluster_name = var.kafka_cluster_name
  kafka_cluster_type = var.kafka_cluster_type
  dedicated_cku = var.dedicated_cku
  provider_region = var.provider_region
}