args = $(filter-out $@, $(MAKECMDGOALS))

setup.node:
	@scp setup-node ${node}:/home/ubuntu/
	@scp docker-daemon.json ${node}:/home/ubuntu/
	@ssh ${node} bash setup-node

setup.master:
	@scp setup-master ${master}:/home/ubuntu/
	@ssh ${master} bash setup-master ${ip}

print.join.command:
	@ssh ${master} kubeadm token create --print-join-command

join.node:
	@ssh ${node} sudo `ssh ${master} kubeadm token create --print-join-command` --ignore-preflight-errors=all

import.kubectl.config:
	@ssh ${master} "cat ~/.kube/config" > kubectl-config

get.pods:
	@kubectl --kubeconfig=kubectl-config get pods

run.nginx:
	@kubectl --kubeconfig=kubectl-config \
		create deployment nginx-pod --image=nginx --dry-run=client -o yaml > ./nginx/pod.yaml
	@kubectl --kubeconfig=kubectl-config apply -f ./nginx/pod.yaml

expose.nginx:
	@kubectl --kubeconfig=kubectl-config \
		expose deployment nginx-pod --name=nginx-svc --port=80 --target-port=80 --type=NodePort --dry-run=client -o yaml > ./nginx/svc.yaml
	@kubectl --kubeconfig=kubectl-config apply -f ./nginx/svc.yaml

pf.nginx:
	@kubectl --kubeconfig=kubectl-config \
		port-forward deployment/nginx-pod 4242:80

%:
	@:
