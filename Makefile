# Combined target to retrieve Helm label, get service IP, and test cluster health by running curl request
test:
	@read -p "Enter namespace: " namespace; \
	label=$$(helm show values elasticsearch-on-k8s/ | grep 'appName' | awk '{print $$2}'); \
	service_ip=$$(kubectl get svc -n $$namespace -l app=$$label -o jsonpath='{.items[0].spec.clusterIP}'); \
	kubectl exec -it elasticsearch-busybox -n $$namespace -- curl "http://$$service_ip:9200/_cluster/health?pretty"; \

