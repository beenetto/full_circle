#!/bin/bash
DOC_URL="https://bynder.atlassian.net/wiki/spaces/BAR/pages/926941209/How+to+run+a+K8s+service+in+development"

echo -e "Have you installed and started MINIKUBE?  \033[1m[y, n]\033[0m"
read input </dev/tty
if [ "$input" = "n" ]; then
		echo "Please reffer to the documentation: ${DOC_URL}"
    open $DOC_URL
		exit 0
fi

echo -e "Have you activated your python VENV?  \033[1m[y, n]\033[0m"
read input </dev/tty
if [ "$input" = "n" ]; then
		echo "Then please do!"
    exit 0
fi

echo -e "Have you logged into OKTA?  \033[1m[y, n]\033[0m"
read input </dev/tty
if [ "$input" = "n" ]; then
	        awscli sts get-caller-identity
                $(aws ecr get-login --registry-ids 893087526002 --no-include-email --region eu-west-1)
fi

echo 'Setting up full circle.'
ROOT_DIR=`pwd`
REPOS=`find . -type d -name '.git' -print | sed 's/.git//g' | cut -c 2-`

status () {
	ST=`git -C ${1} status`
	echo "${ST}"
}

stash_checkout_pull_master () {
	local MSG="Changes stashed by full circle setup"
	git -C $1 stash save $MSG && git -C $1 checkout $BRANCH && git -C $1 pull $REMOTE $BRANCH
	echo "stash-checkout-pull-master @$1 from $REMOTE"
}

awscli sts get-caller-identity
python aws_k8s_cred_parser.py
kubectl delete -f ~/.aws/files-aws-secrets.yaml ; kubectl create -f ~/.aws/files-aws-secrets.yaml

eval $(minikube docker-env)

pull_image = ""
if [ $PULL_IMAGES ]; then
        pull_image="--pull"
fi

while read -r repo; do
	echo ""
	project_location="$ROOT_DIR$repo"
	if ! [[ $project_location == *"full_circle"* ]]; then
                if [ $UPDATE_REPOS ]; then
                        stash_checkout_pull_master $project_location
                fi
		project_name=`echo $repo | sed 's/[/.]//g'`
		cd $project_location && docker build -t $project_name . $pull_image
		echo ""
		echo "Setting up K8s @$project_location"
		kubectl delete -f k8s/ ; kubectl create -f k8s/
	fi
done <<< "$REPOS"

minikube dashboard
