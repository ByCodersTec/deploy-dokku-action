APP_NAME="$1"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)
if dokku apps:exists $APP_NAME
then
  echo "O Applicativo $APP_NAME ja existe... saindo agora!"
else
 echo "Configurando Aplicativo $APP_NAME , aguarde!"
 dokku apps:create $APP_NAME
 dokku domains:add $APP_NAME $APP_NAME.bycodersapp.com
 dokku buildpacks:set $APP_NAME https://github.com/heroku/heroku-buildpack-java.git
 dokku config:set --no-restart $APP_NAME DOKKU_APP_TYPE=herokuish
 dokku config:set --no-restart $APP_NAME DOKKU_LETSENCRYPT_EMAIL=vanildo@bycoders.com.br
fi
