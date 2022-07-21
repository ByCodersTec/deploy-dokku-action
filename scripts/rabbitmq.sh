APP_NAME="$1"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)
if dokku rabbitmq:exists $APP_NAME
then
  echo "(RABBITMQ) Instancia ja configurada.."
else
  dokku rabbitmq:create $APP_NAME $APP_NAME
  dokku rabbitmq:link $APP_NAME $APP_NAME
fi
