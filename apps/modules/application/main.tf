data "confluent_environment" "environment" {
  display_name = var.environment_name
}

data "confluent_kafka_cluster" "kafka_cluster" {
  display_name = var.kafka_cluster_name
 
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_schema_registry_cluster" "schema_registry" {

  environment {
    id = data.confluent_environment.environment.id
  }
}

resource "confluent_service_account" "application_sa" {
  display_name = "${var.application_id}-sa"
  description  = "Service Account for ${var.application_id} app"
}

resource "confluent_api_key" "application_apikey" {
  display_name = "${confluent_service_account.application_sa.display_name}-apikey"
  description  = "Kafka API Key that is owned by '${confluent_service_account.application_sa.id}' service account"
  
  owner {
    id          = confluent_service_account.application_sa.id
    api_version = confluent_service_account.application_sa.api_version
    kind        = confluent_service_account.application_sa.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.kafka_cluster.id
    api_version = data.confluent_kafka_cluster.kafka_cluster.api_version
    kind        = data.confluent_kafka_cluster.kafka_cluster.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "confluent_kafka_topic" "topics" {
  for_each = var.topics

  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint      = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  # credentials {
  #   key    = var.cluster_owner_key
  #   secret = var.cluster_owner_secret
  # }

  topic_name       = each.key
  partitions_count = each.value.partitions
  config           = each.value.config
  
  # lifecycle {
  #   prevent_destroy = true
  # }
}

##### ACLS FOR EACH TOPIC TO DESCRIBE
resource "confluent_kafka_acl" "topic_describe" {
  for_each = var.topics
  
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "TOPIC"
  resource_name = each.key
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}


##### ACLS FOR EACH TOPIC TO READ
resource "confluent_kafka_acl" "topic_read" {
  for_each = var.topics
  
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "TOPIC"
  resource_name = each.key
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}

#### ACLS EACH TOPIC TO WRITE
resource "confluent_kafka_acl" "topic_write" {
  for_each = var.topics
  
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "TOPIC"
  resource_name = each.key
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}

### ACLS FOR THE APP CONSUMER GROUP
resource "confluent_kafka_acl" "consumer_group" {
  
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "GROUP"
  resource_name = "${var.application_id}_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}

#### READ_ACCESS FOR EXTRENAL TOPICS
##### ACLS FOR EACH TOPIC TO DESCRIBE
resource "confluent_kafka_acl" "external_topic_describe" {
  count = length(var.external_topics)
  
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "TOPIC"
  resource_name = var.external_topics[count.index]
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}


##### ACLS FOR EACH TOPIC TO READ
resource "confluent_kafka_acl" "external_topic_read" {
  count = length(var.external_topics)
  
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "TOPIC"
  resource_name = var.external_topics[count.index]
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}


#### KSTREAM APPLICATIONS
### Usually require create, read, write, describe for any topic that start with app_id
resource "confluent_kafka_acl" "app_topic_create" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "TOPIC"
  resource_name = "${var.application_id}_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}

resource "confluent_kafka_acl" "app_topic_describe" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "TOPIC"
  resource_name = "${var.application_id}_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}

resource "confluent_kafka_acl" "app_topic_read" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "TOPIC"
  resource_name = "${var.application_id}_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}

resource "confluent_kafka_acl" "app_topic_write" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.kafka_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.kafka_cluster.rest_endpoint

  resource_type = "TOPIC"
  resource_name = "${var.application_id}_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.application_sa.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  
  # credentials {
  #   key    = confluent_api_key.app-manager-kafka-api-key.id
  #   secret = confluent_api_key.app-manager-kafka-api-key.secret
  # }
}