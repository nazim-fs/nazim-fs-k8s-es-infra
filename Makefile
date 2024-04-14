# Make target to deploy the Elasticsearch cluster in a single-mode via Helm:
deploy:
	@read -p "Enter Release name: " release; \
	read -p "Enter namespace: " namespace; \
	helm install $$release elasticsearch-on-k8s/ --namespace $$namespace --create-namespace

# Make target to retrieve Helm label, get elasticsearch service IP, and test cluster health by running curl request against it:
test:
	@read -p "Enter namespace: " namespace; \
	label=$$(helm show values elasticsearch-on-k8s/ | grep 'appName' | awk '{print $$2}'); \
	service_ip=$$(kubectl get svc -n $$namespace -l app=$$label -o jsonpath='{.items[0].spec.clusterIP}'); \
	kubectl exec -it elasticsearch-busybox -n $$namespace -- curl "http://$$service_ip:9200/_cluster/health?pretty";

# Make target to inject an index named "test" with one shards and one replica each:
inject:
	@read -p "Enter namespace: " namespace; \
        label=$$(helm show values elasticsearch-on-k8s/ | grep 'appName' | awk '{print $$2}'); \
        service_ip=$$(kubectl get svc -n $$namespace -l app=$$label -o jsonpath='{.items[0].spec.clusterIP}'); \
	kubectl exec -it elasticsearch-busybox -n $$namespace -- curl -X PUT "http://$$service_ip:9200/test?pretty" -H 'Content-Type: application/json' -d' { "settings" : { "index" : { "number_of_shards" : 1, "number_of_replicas" : 1 } } }'

# Make target to verify the shard & replica allocation:
retrieve:
	@read -p "Enter namespace: " namespace; \
        label=$$(helm show values elasticsearch-on-k8s/ | grep 'appName' | awk '{print $$2}'); \
        service_ip=$$(kubectl get svc -n $$namespace -l app=$$label -o jsonpath='{.items[0].spec.clusterIP}'); \
        kubectl exec -it elasticsearch-busybox -n $$namespace -- curl "http://$$service_ip:9200/_cat/shards/test?pretty=true";

# Make target to destroy the Elasticsearch cliuster via Helm:
destroy:
	@read -p "Enter Release name: " release; \
	read -p "Enter namespace: " namespace; \
	helm uninstall $$release --namespace $$namespace && kubectl delete namespace $$namespace
