environment_name = "devoteam_dev"
kafka_cluster_name = "dev_cluster"

application_id = "second_app"
topics = {
  "second_topic1" = {
    partitions = 1
    config = {
      "cleanup.policy" = "compact"
    }
  }
  "second_topic2" = {
    partitions = 1
    config = {
      "cleanup.policy" = "delete"
    }
  }
}

external_topics = [ "myapp_topic2" ]