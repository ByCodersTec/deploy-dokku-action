APP_NAME="$1"
PROJECT_NAME="$2"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)
if [ -z "$PROJECT_NAME" ]
then
  echo "project name is empty"
else
  APP_NAME="${PROJECT_NAME}-${APP_NAME}"
fi
DB_NAME="${APP_NAME}_production"

if dokku apps:exists $APP_NAME
then
  echo "O Applicativo $APP_NAME ja existe... saindo agora!"
else
  echo "O Aplicativo $APP_NAME ainda nao existe...criando o aplicativo, aguarde!"
  dokku apps:create $APP_NAME
  dokku postgres:create "${APP_NAME}_production"
  dokku postgres:link "${APP_NAME}_production" $APP_NAME
  dokku domains:add $APP_NAME $APP_NAME.bycodersapp.com
  dokku buildpacks:add $APP_NAME https://github.com/heroku/heroku-buildpack-ruby.git
  dokku config:set --no-restart $APP_NAME DOKKU_APP_TYPE=herokuish
  dokku config:set --no-restart $APP_NAME DOKKU_LETSENCRYPT_EMAIL=vanildo@bycoders.com.br
fi
