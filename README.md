# Kubernuts

Deploying a Kubernetes cluster on EC2 Ubuntu 20.04 LTS.

## Requirements

* An AWS account
* AWS CLI
* jq
* `make iac.install.macos.deps`
* `make iac.configure profile=personal`

## Provisioning the AWS instances

* 2 instances (1 master, 1 node)
* Type: `t3.small`
* 2 vCPUs
* 2GB RAM
* Security groups:
```bash
22          <my IP>
80          0.0.0.0/0
443         0.0.0.0/0
6443        0.0.0.0/0 <-- allow nodes in the same VPC
10250       0.0.0.0/0 <-- allow port-fowarding using kubectl
30000-32767 0.0.0.0/0 <-- k8s service type=NodePort exposes these range
```

1. Build the master node

```bash
make iac.build.instance \
  profile=personal \
  instance-name=k8s-master \
  sg-name=k8s-node-sg \
  keypair-name=aws-k8s-key
```

2. Build the worker node

```bash
make iac.build.instance \
  profile=personal \
  instance-name=k8s-worker \
  sg-name=k8s-node-sg \
  keypair-name=aws-k8s-key
```

3. Setup SSH configs

```bash
# master
make iac.setup.ssh.config \
  profile=personal \
  instance=k8s-master \
  keypair=aws-k8s-key

# worker
make iac.setup.ssh.config \
  profile=personal \
  instance=k8s-worker \
  keypair=aws-k8s-key
```

4. Setup Nodes (install Docker, Kubernetes components and dependencies)
  ```bash
make iac.setup.node instance=k8s-master
make iac.setup.node instance=k8s-worker
```

5. Initialize the Kubernetes cluster on master node
  ```bash
make iac.fetch.public.ip profile=personal instance=k8s-master
make iac.setup.master instance=k8s-master publicip=<public-ip>
```

6. Join worker node on the cluster
```bash
make iac.join.node instance=k8s-worker master=k8s-master
```

7. Import kubectl config
```bash
make import.kubectl.config master=k8s-master
```

8. Test it
```bash
make get.pods
```

## Deploying a simple NGINX app

Create the NGINX deployment
```bash
make run.nginx
```

Expose the NGINX deployment thru a Service
```bash
make expose.nginx
```

Port-forward the NGINX service to the localhost:4242
```bash
make pf.nginx
```

Open `localhost:4242` and cheers!
