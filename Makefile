setup.node:
	@scp setup-node ${node}:/home/ubuntu/
	@scp docker-daemon.json ${node}:/home/ubuntu/
	@ssh ${node} bash setup-node

setup.master:
	@scp setup-master ${master}:/home/ubuntu/
	@ssh ${master} bash setup-master

print.join.command:
	@ssh ${master} kubeadm token create --print-join-command

join.node:
	@ssh ${node} sudo `ssh ${master} kubeadm token create --print-join-command` --ignore-preflight-errors=all

import.kubectl.config:
	@ssh ${master} "cat ~/.kube/config" > kubectl-config
