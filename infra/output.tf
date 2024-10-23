output "resources" {
    value = <<-EOT
    Environment: ${confluent_environment.environment.display_name} (${confluent_environment.environment.id})
    
    KAFKA Cluster: ${confluent_kafka_cluster.kafka_cluster.display_name} (${confluent_kafka_cluster.kafka_cluster.id})

    Cluster Owner: ${confluent_service_account.cluster_owner.display_name} (${confluent_service_account.cluster_owner.id})
          API-KEY: ${confluent_api_key.cluster_owner_api_key.id} : ${nonsensitive(confluent_api_key.cluster_owner_api_key.secret)}

    EOT
    sensitive = false
}