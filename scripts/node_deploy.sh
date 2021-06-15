APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)
if [ -z "$PROJECT_NAME" ]
then
  echo "project name is empty"
else
  APP_NAME="${PROJECT_NAME}-${APP_NAME}"
fi
if dokku apps:exists $APP_NAME
then
  echo "O Applicativo $APP_NAME ja existe... saindo agora!"
else
 echo "Configurando Aplicativo $APP_NAME , aguarde!"
 dokku apps:create $APP_NAME
 dokku domains:add $APP_NAME $APP_NAME.bycodersapp.com
 dokku buildpacks:set $APP_NAME https://github.com/heroku/heroku-buildpack-nodejs#v176
 dokku config:set --no-restart $APP_NAME DOKKU_APP_TYPE=herokuish
 dokku config:set --no-restart $APP_NAME DOKKU_LETSENCRYPT_EMAIL=vanildo@bycoders.com.br
fi