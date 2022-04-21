# Kubernuts

Deploying a Kubernetes cluster on EC2 Ubuntu 20.04.

## Provisioning the AWS instances

* 3 nodes (1 master, 2 nodes)
* Type: `t3.small`
* 2 vCPUs
* 2GB RAM
* Security groups:
```bash
80    0.0.0.0/0
443   0.0.0.0/0
22    <my IP>
6443  172.31.0.0/16 <-- allow nodes in the same VPC
```

## Setup

1. On each node (including master):
```bash
make setup.node node=<node>
```

2. Only master:
```bash
make setup.master master=<master-node>
```

3. On each node (not including master):
```bash
make join.node node=<node> master=<master-node>
```

4. Import kubectl config (from master):
```bash
make import.kubectl.config master=<master-node>
```
