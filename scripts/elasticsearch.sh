APP_NAME="$1"
PROJECT_NAME="$2"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)
if [ -z "$PROJECT_NAME" ]
then
  echo "project name is empty"
else
  APP_NAME="${PROJECT_NAME}-${APP_NAME}"
fi
if dokku elasticsearch:exists $APP_NAME
then
  echo "(ELASTICSEARCH) Instancia ja configurada.."
else
  dokku elasticsearch:create $APP_NAME $APP_NAME
  dokku elasticsearch:link $APP_NAME $APP_NAME
fi
