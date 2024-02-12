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

echo "INPUT_WORKING_DIR ... $INPUT_WORKING_DIR"
if [[ -v INPUT_WORKING_DIR ]];then
  echo "ls -lah /github/workspace"
  ls -lah /github/workspace

  echo "movendo arquivos"
  mv /github/workspace/"$INPUT_WORKING_DIR"/* /github/workspace/
  echo "ls -lah /github/workspace"
  ls -lah /github/workspace

  git config --global user.email "dokku@bycoders.com.br"
  git config --global user.name "dokku deploy"
  git init
  git checkout -b "$INPUT_BRANCH"
  git add . --all
  git commit -m "dokku deploy"

  #echo "ls -lah /github/workspace/$INPUT_WORKING_DIR"
  #ls -lah /github/workspace/$INPUT_WORKING_DIR

  
  #cp /github/workspace.tmp/* /github/workspace -R
  #ls -lah /github/workspace
  #rm -rf /github/workspace.tmp
else 
  echo "checkout git branch...$INPUT_BRANCH"
  git checkout "$INPUT_BRANCH"
fi

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
elif [[ "$INPUT_PROJECT_TYPE" == "ruby" ]];then
  CREATE_APP_COMMAND="sh ./scripts/ruby_deploy.sh $APP_NAME"
elif [[ "$INPUT_PROJECT_TYPE" == "rails_mvc" ]];then
  CREATE_APP_COMMAND="sh ./scripts/rails_deploy.sh $APP_NAME"
elif [[ "$INPUT_PROJECT_TYPE" == "java" ]];then
  CREATE_APP_COMMAND="sh ./scripts/java_deploy.sh $APP_NAME"
elif [[ "$INPUT_PROJECT_TYPE" == "dockerfile" ]];then
  CREATE_APP_COMMAND="sh ./scripts/docker_deploy.sh $APP_NAME $INPUT_DOCKERFILE_NAME"
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

if [ "$INPUT_MONGO" = true ]; then
  CREATE_MONGO_COMMAND="sh ./scripts/mongo.sh $APP_NAME"
  echo "Configurando instancia MONGO...aguarde!"
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $CREATE_MONGO_COMMAND
fi

if [ "$INPUT_RABBITMQ" = true ]; then
  CREATE_RABBITMQ_COMMAND="sh ./scripts/rabbitmq.sh $APP_NAME"
  echo "Configurando instancia RABBITMQ...aguarde!"
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $CREATE_RABBITMQ_COMMAND
fi

GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git push dokku@"$INPUT_HOST":"$APP_NAME" "$INPUT_BRANCH":master --force

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$INPUT_HOST $POST_DEPLOY_COMMAND
