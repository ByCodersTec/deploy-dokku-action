APP_NAME="$1"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)

if dokku postgres:exists $APP_NAME
then
  echo "(POSTGRES) Instancia ja configurada.."
else
  dokku postgres:create $APP_NAME $APP_NAME
  dokku postgres:link $APP_NAME $APP_NAME
fi
