APP_NAME="$1"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)

if dokku mysql:exists $APP_NAME
then
  echo "(MYSQL) Instancia ja configurada.."
else
  dokku mysql:create $APP_NAME $APP_NAME
  dokku mysql:link $APP_NAME $APP_NAME
fi
