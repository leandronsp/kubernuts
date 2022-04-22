# Kubernuts

Deploying a Kubernetes cluster on EC2 Ubuntu 20.04.

## Provisioning the AWS instances

* 3 nodes (1 master, 2 nodes)
* Type: `t3.small`
* 2 vCPUs
* 2GB RAM
* Security groups:
```bash
22          <my IP>
80          0.0.0.0/0
443         0.0.0.0/0
6443        172.31.0.0/16 <-- allow nodes in the same VPC
10250       0.0.0.0/0     <-- allow port-fowarding using kubectl
30000-32767 0.0.0.0/0     <-- k8s service type=NodePort exposes these range
```

## Setup

1. On each node (including master):
```bash
make setup.node node=<node>
```

2. Only master:
```bash
make setup.master master=<master-node> ip=<master-public-ip>
```

3. On each node (not including master):
```bash
make join.node node=<node> master=<master-node>
```

4. Import kubectl config (from master):
```bash
make import.kubectl.config master=<master-node>
```

## Running an NGINX application

1. Run NGINX deployment/pod:
```bash
make run.nginx
```

2. Expose the NGINX deployment via Service type=NodePort:
```bash
make expose.nginx
```

Now, open `http://<public-node-IP>:<node-port>` or, if you prefer doing port-forward, run:
```bash
make pf.nginx
```
...and open `http://localhost:4242`. Cheers!
