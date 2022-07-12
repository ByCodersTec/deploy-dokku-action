APP_NAME="$1"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)

if dokku mongo:exists $APP_NAME
then
  echo "(MONGO) Instancia ja configurada.."
else
  dokku mongo:create $APP_NAME $APP_NAME
  dokku mongo:link $APP_NAME $APP_NAME
fi
