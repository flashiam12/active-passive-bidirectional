## Active Passive Bidirectional Cluster Linking Dry Run

### Pre-requisite 
#### 1. AWS Account with transit gateway & VPC to host forward proxy nginx server
#### 2. Bastion server in EC2 with public access and forward proxy nginx server
#### 3. Confluent Service account, environment & Cloud API Keys

### Scaffold

![Alt text](./scaffold.png)

#### 1. Copy the terraform.sample.tfvars into terraform.tfvars
```bash
cp terraform.sample.tfvars terraform.tfvars
```
#### 2. Update the values in terrform.tfvars

#### 3. Setup the initial infrastructure
```bash
terraform init
terraform apply
```

#### 4. Above command will fail while accessing the data plane for CC - like creating mirror topics, topics, acls, rbac, cluster links etc. For this, you required to setup a forward proxy with NGINX. Follow these steps: https://docs.confluent.io/cloud/current/networking/ccloud-console-access.html#configure-a-proxy. Add Both the clusters bootstrap endpoint url in /etc/hosts 

#### 5. After setting up nginx proxy, you must be able to access the cc endpoints. Check with: 
```bash
nc -vz <CC_PRIMARY_BOOTSTRAP_URL> 9092
nc -vz <CC_SECONDARY_BOOTSTRAP_URL> 9092
```

#### 6. Re-run the apply command
```bash
terraform apply 
```


### Runbook

#### 1. Check the active links on both clusters
```bash
curl -X GET https://{{src_cluster_bootstrap}}/kafka/v3/clusters/{{src_cluster_id}}/links \
  -u {{src_cluster_api_key}}:{{src_cluster_api_secret}}

curl -X GET https://{{dest_cluster_bootstrap}}/kafka/v3/clusters/{{dest_cluster_id}}/links \
  -u {{dest_cluster_api_key}}:{{dest_cluster_api_secret}}

```

#### 2. Check the topics on both clusters
```bash
curl -X GET https://{{src_cluster_bootstrap}}/kafka/v3/clusters/{{src_cluster_id}}/topics \
  -u {{src_cluster_api_key}}:{{src_cluster_api_secret}}

curl -X GET https://{{dest_cluster_bootstrap}}/kafka/v3/clusters/{{dest_cluster_id}}/topics \
  -u {{dest_cluster_api_key}}:{{dest_cluster_api_secret}}
```

#### 3. Check the mirror topics on both clusters
```bash
curl -X GET https://{{src_cluster_bootstrap}}/kafka/v3/clusters/{{src_cluster_id}}/links/{{cl_link_id}}/mirrors \
  -u {{src_cluster_api_key}}:{{src_cluster_api_secret}}

curl -X GET https://{{dest_cluster_bootstrap}}/kafka/v3/clusters/{{dest_cluster_id}}/links/{{cl_link_id}}/mirrors \
  -u {{dest_cluster_api_key}}:{{dest_cluster_api_secret}}
```

#### 4. Start a producer & consumer on primary

![Alt text](./steady.png)

#### 5. Induce a networking issue by destroying confluent cloud transit gateway attachment on primary
```bash
terraform destroy -target confluent_network.primay-network-transit-gateway
```

#### 6. Check the producer & consumer on primary

![Alt text](./stop.png)

#### 7. Run the mirror and start command on destination cluster
```bash
curl -X POST https://{{dest_cluster_bootstrap}}/kafka/v3/clusters/{{dest_cluster_id}}/links/{{cl_link_id}}/mirrors:reverse-and-start-mirror \
  -u {{dest_cluster_api_key}}:{{dest_cluster_api_secret}} \
  -H "Content-Type: application/json" \
  -d '{
    "mirror_topic_names": ["active-passive-a"]
  }'
```

![Alt text](./reverse-and-start-mirror.png)

#### 8. (Optional) If the above command fails, verify the acls 
```bash
# Source Cluster:

confluent kafka acl create --allow --service-account {{source_service_account}} --operations read,describe-configs --topic {{source_topic}} --cluster {{source_cluster_id}} --environment {{source_environment_id}}

confluent kafka acl create --allow --service-account {{source_service_account}} --operations describe,alter --cluster-scope --cluster {{source_cluster_id}} --environment {{source_environment_id}}

#     Principal          | Permission |    Operation     | Resource Type |  Resource Name   | Pattern Type  
# -----------------------+------------+------------------+---------------+------------------+---------------
#   User:{{source_service_account}} | ALLOW      | ALTER            | CLUSTER       | kafka-cluster    | LITERAL       
#   User:{{source_service_account}} | ALLOW      | DESCRIBE         | CLUSTER       | kafka-cluster    | LITERAL       
#   User:{{source_service_account}} | ALLOW      | DESCRIBE_CONFIGS | TOPIC         | {{source_topic}} | LITERAL       
#   User:{{source_service_account}} | ALLOW      | READ             | TOPIC         | {{source_topic}} | LITERAL  


# Destination Cluster: 

confluent kafka acl create --allow --service-account {{destination_service_account}} --operations read,describe-configs --topic {{destination_topic}} --cluster {{destination_cluster_id}} --environment {{destination_environment_id}}

confluent kafka acl create --allow --service-account {{destination_service_account}} --operations describe,alter --cluster-scope --cluster {{destination_cluster_id}} --environment {{destination_environment_id}}

#     Principal          | Permission |    Operation     | Resource Type |  Resource Name   | Pattern Type  
# -----------------------+------------+------------------+---------------+------------------+---------------
#   User:{{destination_service_account}} | ALLOW      | ALTER            | CLUSTER       | kafka-cluster    | LITERAL       
#   User:{{destination_service_account}} | ALLOW      | DESCRIBE         | CLUSTER       | kafka-cluster    | LITERAL       
#   User:{{destination_service_account}} | ALLOW      | DESCRIBE_CONFIGS | TOPIC         | {{destination_topic}} | LITERAL       
#   User:{{destination_service_account}} | ALLOW      | READ             | TOPIC         | {{destination_topic}} | LITERAL  

```

#### 9. If the command passes, move the producer and consumer to secondary & also check offset lag between the clusters

![Alt text](./failover.png)

#### 10. Start the network connection back
```bash
terraform apply -target confluent_network.primay-network-transit-gateway
```

#### 11. Check the secondary to primary mirroring on primary mirror topic
```bash
curl -X GET 'https://{{src_cluster_bootstrap}}/kafka/v3/clusters/{{src_cluster_id}}/links/{{cl_link_id}}/mirrors' --header 'Authorization: Basic {{auth_src_cl}}' --header 'Accept: */*'
```

![Alt text](./resume.png)

#### 12. Failback to primary by running the reverse-and-start-mirror on the primary mirror topic 
```bash
curl -X POST 'https://{{src_cluster_bootstrap}}/kafka/v3/clusters/{{src_cluster_id}}/links/{{cl_link_id}}/mirrors:reverse-and-start-mirror' --header 'Authorization: Basic {{auth_src_cl}}' --header 'Content-Type: application/json' --data '{
    "mirror_topic_names": ["{{primary_mirror_topic}}"]
  }'

```

![Alt text](./failback.png)

#### 13. Move the producer and consumer clients back to primary 

![Alt text](./steady-after-failback.png)


### Teardown

```bash
terraform destroy
```

