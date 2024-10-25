variable environment_name {
    description = "The name of the environment to create"
    type        = string
}

variable "kafka_cluster_name" {
    type = string
}

variable apps {
  description = "A map of applications with their attributes - key is the name of the application"
  type = map(object({
    app_topics = map(object({
      partitions = number
      config = map(string)
    }))
    external_topics = list(string)
  }))
  sensitive   = false
}

# variable "application_id" {
#     type = string
# }

# variable "topics" {
#   description = "A map of topics with their attributes - key is the name of the topic"
#   type = map(object({
#     partitions = number
#     config = map(string)
#   }))
#   sensitive   = false
# }

# variable "external_topics" {
#   description = "A list of topics owned by other apps for which this app needs to create consumer groups"
#   type = list(string)
#   sensitive   = false
#   default = []
# }