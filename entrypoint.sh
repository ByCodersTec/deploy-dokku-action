#!/bin/sh

set -e

SSH_PATH="$HOME/.ssh"

mkdir -p "$SSH_PATH"
touch "$SSH_PATH/known_hosts"

echo "$INPUT_PRIVATE_KEY" > "$SSH_PATH/deploy_key"
echo "$INPUT_PUBLIC_KEY" > "$SSH_PATH/deploy_key.pub"

chmod 700 "$SSH_PATH"
chmod 600 "$SSH_PATH/known_hosts"
chmod 600 "$SSH_PATH/deploy_key"
chmod 600 "$SSH_PATH/deploy_key.pub"

eval "$(ssh-agent)"
ssh-add "$SSH_PATH/deploy_key"

ssh-keyscan -t rsa "$INPUT_HOST" >> "$SSH_PATH/known_hosts"

git checkout "$INPUT_BRANCH"

APP_NAME=$(echo $INPUT_BRANCH | cut -d'/' -f 2)
APP_NAME="${INPUT_PROJECT}-${APP_NAME}"

CREATE_APP_COMMAND="sh ./scripts/deploy.sh $INPUT_BRANCH $INPUT_PROJECT"
SET_VARIABLES_COMMAND="bash ./scripts/variables.sh $INPUT_PROJECT $INPUT_BRANCH"
POST_DEPLOY_COMMAND="sh ./scripts/after_deploy.sh $INPUT_BRANCH"

echo "========commands======"
echo $CREATE_APP_COMMAND
echo $SET_VARIABLES_COMMAND
echo "======================"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $CREATE_APP_COMMAND
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $SET_VARIABLES_COMMAND

GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git push -f dokku@"$INPUT_HOST":"$APP_NAME" "$INPUT_BRANCH":master

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $POST_DEPLOY_COMMAND
