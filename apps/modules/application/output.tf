output "application_user" {
    value = "User: ${confluent_service_account.application_sa.display_name} (${confluent_service_account.application_sa.id})"
}

output "api_key" {
    value = "${confluent_api_key.application_apikey.id}:${nonsensitive(confluent_api_key.application_apikey.secret)}"
    sensitive = false
}

output "app_properties" {
    value = <<-EOT
#### CLIENT CONNECTION PROPERTIES
bootstrap.servers=${data.confluent_kafka_cluster.kafka_cluster.bootstrap_endpoint}
security.protocol=SASL_SSL
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username='${confluent_api_key.application_apikey.id}' password='${nonsensitive(confluent_api_key.application_apikey.secret)}';
sasl.mechanism=PLAIN
# Required for correctness in Apache Kafka clients prior to 2.6
client.dns.lookup=use_all_dns_ips
# Best practice for higher availability in Apache Kafka clients prior to 3.0
session.timeout.ms=45000
# Best practice for Kafka producer to prevent data loss
acks=all
EOT
    sensitive = false
}