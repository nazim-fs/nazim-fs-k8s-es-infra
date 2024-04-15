# Elasticsearch Cluster Deployment on Kubernetes: Setup and Management Guide

## Introduction:

This repository houses the code necessary to establish and deploy a highly available and scalable Elasticsearch cluster on a Kubernetes cluster. The setup leverages the Helm utility for seamless deployment.


## Architecture:

In accordance with the default values specified in `values.yaml`, this setup encompasses the following Elasticsearch components:

- Master nodes: 3
- Data nodes: 3
- Client nodes: 3

The deployment configuration entails:

- Helm chart deployment for the components.
- Utilization of a dedicated namespace to encapsulate the setup.
- Deployment of a statefulset for Master, Client, and Data nodes.
- Implementation of a headless service for inter-node communication.
- Provision of a load balancer service utilizing Client nodes for endpoint access.
- Allocation of a persistent volume claim for data nodes to store data.
- Inclusion of a configmap containing common cluster configurations.
- Enforcement of RBAC to restrict access to cluster components.
- Application of a network policy to regulate traffic to cluster components.
- Establishment of a pod disruption budget to ensure pod availability during maintenance.
- Integration of a simple busybox container for conducting tests against the cluster.


## Pre-requisites:

To successfully deploy the Elasticsearch cluster, the following pre-requisites must be satisfied:

- Access to git and git CLI on the local machine for repository cloning.
- A running Kubernetes cluster, preferably EKS.
- A kubeconfig file, ensuring access to the cluster.
- Installation of kubectl, helm, and the make utility.


## Diagram:




## Deployment Procedure:

Upon ensuring all pre-requisites are met, clone the repository:
```
git clone https://github.com/nazim-fs/nazim-fs-k8s-es-infra.git && cd nazim-fs-k8s-es-infra
```

Ensure access to the cluster and adequate permissions to create/update/delete the following resources:
```
namespace, statefulset, service, pvc, configmap, roles, rolebinding, clusterrole, clusterrolebinding, netpol, pdb
```

Carefully review and adjust the values in `values.yaml` as per requirements. Execute the following command to deploy Elasticsearch onto the cluster:
```
$ make deploy
Enter Release name: es-cluster
Enter namespace: es
```

Allow at least 5 minutes for the configuration process to complete. Once finished, verify the status of all cluster components and pods:
```
kubectl -n <namespace> get all,pvc,cm,netpol,pdb
```
Replace <namespace> with the appropriate value.


## Testing Procedure:

Pre-configured make utilities facilitate testing cluster health, indexing, and replication. Utilize the following commands:
- Check cluster health:
```
$ make test
Enter Release name: es-cluster
Enter namespace: es
```

- Inject the test index with replicas:
```
$ make inject
Enter Release name: es-cluster
Enter namespace: es
```

- Verify shard & replica allocation of the test index:
```
$ make retrieve
Enter Release name: es-cluster
Enter namespace: es
```


## Destruction Procedure:

Destroying the cluster is as straightforward as provisioning and can be accomplished using the following make command:
```
$ make destroy
Enter Release name: es-cluster
Enter namespace: es
```


## Possible Troubleshooting:

In case of pods being in a pending state, ensure sufficient resources are available on the nodes. Check for error messages using:
```
kubectl -n <namespace> describe pod <pod_name>
```
- Sample error message:
```
0/3 nodes are available: 1 Insufficient cpu, 2 node(s) had volume node affinity conflict.
```

Adjust resource allocations in the values.yaml file if necessary.


## Known Issues & Future Improvements:

While efforts have been made to deliver quality work, certain lingering issues remain due to time constraints.
- During testing, discrepancies in the number of master or data nodes may occur, potentially due to split-brain problems or inadequate configurations, causing situations where the Elasticsearch cluster is unable to safely elect a Master node.
Sample error message:
```
Warning  Unhealthy               20m (x6 over 20m)  kubelet                  Readiness probe failed: Get "http://10.0.2.7:9200/_cluster/health": dial tcp 10.0.2.7:9200: connect: connection refused
Warning  Unhealthy               20m                kubelet                  Liveness probe failed: Get "http://10.0.2.7:9200/_cluster/health": dial tcp 10.0.2.7:9200: connect: connection refused
```
- There is also a room for future improvements to the Makefile for dynamic retrieval of `Release Name` and `namespace` values.


## Reference Links:

- [Elastic Learn](https://www.elastic.co/learn)
- [Elastic Guide](https://www.elastic.co/guide/index.html)
- [Helm Installation Documentation](https://helm.sh/docs/intro/install/)
- [Helm Tips and Tricks](https://helm.sh/docs/howto/charts_tips_and_tricks/)
- [Kubernetes Glossary](https://kubernetes.io/docs/reference/glossary/?all=true)
- [Opster - Elasticsearch Cluster State Issue Analysis](https://opster.com/analysis/elasticsearch-received-a-cluster-state-from-a-different-master-than-the-current-one-rejecting-received-current/)

