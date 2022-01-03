APP_NAME="$1"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)

if dokku elasticsearch:exists $APP_NAME
then
  echo "(ELASTICSEARCH) Instancia ja configurada.."
else
  dokku elasticsearch:create $APP_NAME $APP_NAME
  dokku elasticsearch:link $APP_NAME $APP_NAME
fi
