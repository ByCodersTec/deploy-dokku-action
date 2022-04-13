#!/bin/bash

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

echo "adding deploy key..."

ssh-add "$SSH_PATH/deploy_key"

echo "setting safe directory /github/workspace"

git config --global --add safe.directory /github/workspace

echo "adding host address to known hosts..."

ssh-keyscan -t rsa "$INPUT_HOST" >> "$SSH_PATH/known_hosts"

echo "checkout git branch...$INPUT_BRANCH"

git checkout "$INPUT_BRANCH"

echo "calling deploy scripts.."

APP_NAME=$(echo $INPUT_BRANCH | cut -d'/' -f 2)

echo "REVIEW APP= $INPUT_REVIEW_APP"
if [ "$INPUT_REVIEW_APP" = false ]; then
  APP_NAME="${INPUT_PROJECT}"
else
  APP_NAME="${INPUT_PROJECT}-${APP_NAME}"
fi

echo "APP NAME=$APP_NAME"

if [[ "$INPUT_PROJECT_TYPE" == "node" ]];then
  CREATE_APP_COMMAND="sh ./scripts/node_deploy.sh $APP_NAME"
elif [[ "$INPUT_PROJECT_TYPE" == "python" ]];then
  CREATE_APP_COMMAND="sh ./scripts/python_deploy.sh $APP_NAME"
else
  CREATE_APP_COMMAND="sh ./scripts/deploy.sh $APP_NAME"
fi

SET_VARIABLES_COMMAND="bash ./scripts/variables.sh $INPUT_PROJECT $APP_NAME"
POST_DEPLOY_COMMAND="sh ./scripts/after_deploy.sh $APP_NAME"

echo "======== $INPUT_PROJECT_TYPE project ========"
echo $CREATE_APP_COMMAND
echo $SET_VARIABLES_COMMAND
echo "======================================="

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $CREATE_APP_COMMAND
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $SET_VARIABLES_COMMAND

if [ "$INPUT_POSTGRES" = true ]; then
  CREATE_POSTGRES_COMMAND="sh ./scripts/postgres.sh $APP_NAME"
  echo "Configurando instancia POSTGRES...aguarde!"
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $CREATE_POSTGRES_COMMAND
fi

if [ "$INPUT_REDIS" = true ]; then
  CREATE_REDIS_COMMAND="sh ./scripts/redis.sh $APP_NAME"
  echo "Configurando instancia REDIS...aguarde!"
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $CREATE_REDIS_COMMAND
fi

if [ "$INPUT_ELASTICSEARCH" = true ]; then
  CREATE_ELASTICSEARCH_COMMAND="sh ./scripts/elasticsearch.sh $APP_NAME"
  echo "Configurando instancia ELASTICSEARCH.. aguarde!"
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $CREATE_ELASTICSEARCH_COMMAND
fi

GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git push -f dokku@"$INPUT_HOST":"$APP_NAME" "$INPUT_BRANCH":master

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $POST_DEPLOY_COMMAND
