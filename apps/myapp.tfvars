environment_name = "devoteam_dev"
kafka_cluster_name = "dev_cluster"

application_id = "myapp"
topics = {
  "myapp_topic1" = {
    partitions = 1
    config = {
      "cleanup.policy" = "compact"
    }
  }
  "myapp_topic2" = {
    partitions = 1
    config = {
      "cleanup.policy" = "delete"
    }
  }
}