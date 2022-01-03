APP_NAME="$1"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)
if dokku redis:exists $APP_NAME
then
  echo "(REDIS) Instancia ja configurada.."
else
  dokku redis:create $APP_NAME $APP_NAME
  dokku redis:link $APP_NAME $APP_NAME
fi
