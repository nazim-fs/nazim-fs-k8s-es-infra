# Make target to deploy the Elasticsearch cluster in a single-mode via Helm:
deploy:
	@read -p "Enter Release name: " release; \
	read -p "Enter namespace: " namespace; \
	helm install $$release elasticsearch-on-k8s/ --namespace $$namespace --create-namespace

# Make target to retrieve elasticsearch Master IP, and test cluster health by running curl request against it:
test:
	@read -p "Enter Release name: " release; \
	read -p "Enter namespace: " namespace; \
	master_ip=$$(kubectl get pod -n $$namespace $$release-es-master-0 -o jsonpath=''{.status.podIP}''); \
	kubectl exec -it elasticsearch-busybox -n $$namespace -- curl "http://$$master_ip:9200/_cluster/health?pretty";

# Make target to inject an index named "test" with one shards and one replica each:
inject:
	@read -p "Enter Release name: " release; \
	read -p "Enter namespace: " namespace; \
	master_ip=$$(kubectl get pod -n $$namespace $$release-es-master-0 -o jsonpath=''{.status.podIP}''); \
	kubectl exec -it elasticsearch-busybox -n $$namespace -- curl -X PUT "http://$$master_ip:9200/test?pretty" -H 'Content-Type: application/json' -d' { "settings" : { "index" : { "number_of_shards" : 3, "number_of_replicas" : 1 } } }'

# Make target to verify the shard & replica allocation:
retrieve:
	@read -p "Enter Release name: " release; \
	read -p "Enter namespace: " namespace; \
	master_ip=$$(kubectl get pod -n $$namespace $$release-es-master-0 -o jsonpath=''{.status.podIP}''); \
        kubectl exec -it elasticsearch-busybox -n $$namespace -- curl "http://$$master_ip:9200/_cat/shards/test?pretty=true"

# Make target to destroy the Elasticsearch cliuster via Helm:
destroy:
	@read -p "Enter Release name: " release; \
	read -p "Enter namespace: " namespace; \
	helm uninstall $$release --namespace $$namespace && kubectl delete namespace $$namespace
