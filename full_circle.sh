#!/bin/bash

echo 'Setting up full circle.'
ROOT_DIR=`pwd`
REPOS=`find . -type d -name '.git' -print | sed 's/.git//g' | cut -c 2-`

status () {
	ST=`git -C ${1} status`
	echo "${ST}"
}

stash_checkout_pull_master () {
	local MSG="Changes stashed by full circle setup"
	STASH_CHECKOUT_PULL=`git -C ${1} stash save "${MSG}" && git -C ${1} checkout master && git -C ${1} pull upstream master`
	echo "${STASH} @${1}"
}

echo `awscli sts get-caller-identity`
echo `python aws_k8s_cred_parser.py`
echo `kubectl delete -f ~/.aws/files-aws-secrets.yaml ; kubectl create -f ~/.aws/files-aws-secrets.yaml`
echo `eval $(minikube docker-env)`

while read -r repo; do
	echo ""
	project_location="$ROOT_DIR$repo"
	stash_checkout_pull_master $project_location
	project_name=`echo $repo | sed 's/[/.]//g'`
	echo `cd ${project_location} && docker build -t ${project_name} .`
	echo ""
	echo `pwd`
	echo `cd ${project_location} && kubectl delete -f k8s/ ; kubectl create -f k8s/`
done <<< "$REPOS"