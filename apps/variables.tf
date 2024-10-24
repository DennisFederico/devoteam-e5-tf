variable environment_name {
    description = "The name of the environment to create"
    type        = string
}

variable "kafka_cluster_name" {
    type = string
}

variable "provider_region" {
    type = string
}

variable "application_id" {
    type = string
}

variable "topics" {
  description = "A map of topics with their attributes - key is the name of the topic"
  type = map(object({
    partitions = number
    config = map(string)
  }))
  sensitive   = false
}