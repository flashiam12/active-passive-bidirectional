output "primary_cluster" {
  sensitive = false
  value = {
    region = var.aws_region
    bootstrap_endpoint = confluent_kafka_cluster.primary.bootstrap_endpoint
    cluster_id = confluent_kafka_cluster.primary.id
    cluster_api_key = confluent_api_key.cluster-api-key-primary.id
    cluster_api_secret = nonsensitive(confluent_api_key.cluster-api-key-primary.secret)
    topic = confluent_kafka_topic.primary.topic_name
    # mirror_topic = confluent_kafka_mirror_topic.primary.id
  }
}

output "secondary_cluster" {
  sensitive = false
  value = {
    region = var.aws_region
    bootstrap_endpoint = confluent_kafka_cluster.secondary.bootstrap_endpoint
    cluster_id = confluent_kafka_cluster.secondary.id
    cluster_api_key = confluent_api_key.cluster-api-key-secondary.id
    cluster_api_secret = nonsensitive(confluent_api_key.cluster-api-key-secondary.secret)
    mirror_topic = confluent_kafka_mirror_topic.secondary.id
    topic = confluent_kafka_topic.secondary.topic_name
  }
}