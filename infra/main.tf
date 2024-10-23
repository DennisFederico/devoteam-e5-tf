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

resource "confluent_environment" "environment" {
  display_name = var.environment_name
  
  stream_governance {
    package = "ESSENTIALS"
  }
}

resource "confluent_kafka_cluster" "kafka_cluster" {
  display_name = var.kafka_cluster_name
  availability = "SINGLE_ZONE"
  cloud        = "GCP"
  region       =  var.provider_region
  
  standard {}

  environment {
    id = confluent_environment.environment.id
  }
}

data "confluent_schema_registry_cluster" "schema_registry" {

  environment {
    id = confluent_environment.environment.id
  }

  depends_on = [ confluent_kafka_cluster.kafka_cluster ]

  # lifecycle {
  #   prevent_destroy = true
  # }
}

## Service Account for the cluster
resource "confluent_service_account" "cluster_owner" {
  display_name = "${confluent_kafka_cluster.kafka_cluster.display_name}_SA"
  description  = "${confluent_kafka_cluster.kafka_cluster.display_name} Service Account that owns the cluster"
}

resource "confluent_api_key" "cluster_owner_api_key" {
  display_name = "${confluent_service_account.cluster_owner.display_name}_API_KEY"
  description  = "Kafka API Key that is owned by '${confluent_service_account.cluster_owner.display_name}' service account"

  owner {
    id          = confluent_service_account.cluster_owner.id
    api_version = confluent_service_account.cluster_owner.api_version
    kind        = confluent_service_account.cluster_owner.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.kafka_cluster.id
    api_version = confluent_kafka_cluster.kafka_cluster.api_version
    kind        = confluent_kafka_cluster.kafka_cluster.kind

    environment {
      id = confluent_environment.environment.id
    }
  }

  ## TODO ACLs

}