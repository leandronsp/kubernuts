args = $(filter-out $@, $(MAKECMDGOALS))

iac.install.macos.deps:
	@brew install jq awscli

iac.configure:
	@aws configure --profile ${profile}

iac.build.instance:
	@bash -c "./iac/build-instance --profile ${profile} --instance-name ${instance-name} --security-group-name ${sg-name} --keypair-name ${keypair-name}"

iac.fetch.public.ip:
	@bash -c "./iac/fetch-public-ip ${profile} ${instance}"

iac.setup.ssh.config:
	@mkdir -p ~/.ssh/config.d/
	@echo "\
	Host ${instance} \
	\nHostname `bash -c \"./iac/fetch-public-ip ${profile} ${instance}\"` \
	\nUser ubuntu \
	\nIdentityFile ~/.ssh/${keypair}.pem" > ~/.ssh/config.d/${instance}

iac.setup.node:
	@scp ./iac/setup-node ${instance}:/home/ubuntu/
	@ssh ${instance} bash setup-node

iac.setup.master:
	@scp ./iac/setup-master ${instance}:/home/ubuntu/
	@ssh ${instance} bash setup-master ${publicip}

iac.join.node:
	@ssh ${instance} sudo `ssh ${master} kubeadm token create --print-join-command` --ignore-preflight-errors=all --cri-socket unix:///var/run/cri-dockerd.sock

import.kubectl.config:
	@ssh ${master} "cat ~/.kube/config" > kubectl-config

get.pods:
	@kubectl --kubeconfig=kubectl-config get pods

run.nginx:
	@kubectl --kubeconfig=kubectl-config \
		create deployment nginx-pod --image=nginx --dry-run=client -o yaml > ./app/nginx-pod.yaml
	@kubectl --kubeconfig=kubectl-config apply -f ./app/nginx-pod.yaml

expose.nginx:
	@kubectl --kubeconfig=kubectl-config \
		expose deployment nginx-pod --name=nginx-svc --port=80 --target-port=80 --type=NodePort --dry-run=client -o yaml > ./app/nginx-svc.yaml
	@kubectl --kubeconfig=kubectl-config apply -f ./app/nginx-svc.yaml

pf.nginx:
	@kubectl --kubeconfig=kubectl-config port-forward svc/nginx-svc 4242:80

%:
	@:
