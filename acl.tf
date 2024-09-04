# Primary

resource "confluent_kafka_acl" "source_topic_read_describe_configs" {
  kafka_cluster {
    id = confluent_kafka_cluster.primary.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.primary.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.default.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.primary.rest_endpoint
  credentials {
    key    = confluent_api_key.cluster-api-key-primary.id
    secret = confluent_api_key.cluster-api-key-primary.secret
  }
}

resource "confluent_kafka_acl" "source_topic_describe_configs" {
  kafka_cluster {
    id = confluent_kafka_cluster.primary.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.primary.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.default.id}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.primary.rest_endpoint
  credentials {
    key    = confluent_api_key.cluster-api-key-primary.id
    secret = confluent_api_key.cluster-api-key-primary.secret
  }
}

resource "confluent_kafka_acl" "source_cluster_describe" {
  kafka_cluster {
    id = confluent_kafka_cluster.primary.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.default.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.primary.rest_endpoint
  credentials {
    key    = confluent_api_key.cluster-api-key-primary.id
    secret = confluent_api_key.cluster-api-key-primary.secret
  }
}

resource "confluent_kafka_acl" "source_cluster_alter" {
  kafka_cluster {
    id = confluent_kafka_cluster.primary.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.default.id}"
  host          = "*"
  operation     = "ALTER"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.primary.rest_endpoint
  credentials {
    key    = confluent_api_key.cluster-api-key-primary.id
    secret = confluent_api_key.cluster-api-key-primary.secret
  }
}

# Secondary

resource "confluent_kafka_acl" "destination_topic_read_describe_configs" {
  kafka_cluster {
    id = confluent_kafka_cluster.secondary.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_mirror_topic.secondary.mirror_topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.default.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.secondary.rest_endpoint
  credentials {
    key    = confluent_api_key.cluster-api-key-secondary.id
    secret = confluent_api_key.cluster-api-key-secondary.secret
  }
}

resource "confluent_kafka_acl" "destination_topic_describe_configs" {
  kafka_cluster {
    id = confluent_kafka_cluster.secondary.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_mirror_topic.secondary.mirror_topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.default.id}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.secondary.rest_endpoint
  credentials {
    key    = confluent_api_key.cluster-api-key-secondary.id
    secret = confluent_api_key.cluster-api-key-secondary.secret
  }
}

resource "confluent_kafka_acl" "destination_cluster_describe" {
  kafka_cluster {
    id = confluent_kafka_cluster.secondary.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.default.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.secondary.rest_endpoint
  credentials {
    key    = confluent_api_key.cluster-api-key-secondary.id
    secret = confluent_api_key.cluster-api-key-secondary.secret
  }
}

resource "confluent_kafka_acl" "destination_cluster_alter" {
  kafka_cluster {
    id = confluent_kafka_cluster.secondary.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${data.confluent_service_account.default.id}"
  host          = "*"
  operation     = "ALTER"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.secondary.rest_endpoint
  credentials {
    key    = confluent_api_key.cluster-api-key-secondary.id
    secret = confluent_api_key.cluster-api-key-secondary.secret
  }
}