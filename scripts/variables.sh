#!/bin/bash
PROJECT_NAME="$1"
APP_NAME="$2"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)
if [ -z "$PROJECT_NAME" ]
then
  echo "project name is empty"
else
  APP_NAME="${PROJECT_NAME,,}-${APP_NAME}"
fi
echo $APP_NAME
while IFS= read -r line; do
 ID=`expr index "$line" '='`
 STR=$line
 dokku config:set --no-restart $APP_NAME $line
done < ./scripts/$PROJECT_NAME
