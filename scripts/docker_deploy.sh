APP_NAME="$1"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)

if dokku apps:exists $APP_NAME
then
  echo "O Applicativo $APP_NAME ja existe... saindo agora!"
else
  echo "O Aplicativo $APP_NAME ainda nao existe...criando o aplicativo, aguarde!"
  dokku apps:create $APP_NAME
  dokku domains:add $APP_NAME $APP_NAME.bycodersapp.com
  dokku buildpacks:clear $APP_NAME
  dokku config:set --no-restart $APP_NAME DOKKU_APP_TYPE=dockerfile
  dokku config:set --no-restart $APP_NAME DOKKU_LETSENCRYPT_EMAIL=vanildo@bycoders.com.br
fi
