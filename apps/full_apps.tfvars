environment_name = "devoteam_dev"
kafka_cluster_name = "dev_cluster"

apps = {
  "first_app" = {
    app_topics = {
      "first_topic1" = {
        partitions = 1
        config = {
          "cleanup.policy" = "compact"
        }
      }
      "first_topic2" = {
        partitions = 1
        config = {
          "cleanup.policy" = "delete"
        }
      }
    }
    external_topics = [ "second_topic2" ]
  },
  "second_app" = {
    app_topics = {
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
    external_topics = [ "first_topic2" ]
  }
}