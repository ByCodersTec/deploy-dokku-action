APP_NAME="$1"
PROJECT_NAME="$2"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)
if [ -z "$PROJECT_NAME" ]
then
  echo "project name is empty"
else
  APP_NAME="${PROJECT_NAME}-${APP_NAME}"
fi
if dokku redis:exists $APP_NAME
then
  echo "(REDIS) Instancia ja configurada.."
else
  dokku redis:create $APP_NAME $APP_NAME
  dokku redis:link $APP_NAME $APP_NAME
fi
