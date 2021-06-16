APP_NAME="$1"
PROJECT_NAME="$2"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)
if [ -z "$PROJECT_NAME" ]
then
  echo "project name is empty"
else
  APP_NAME="${PROJECT_NAME}-${APP_NAME}"
fi

echo "Verificando se existe certificado digital..."

RESULT=$(dokku letsencrypt:list | grep "$APP_NAME")

if [ -z "$RESULT" ]
then
  echo "Nenhum certificado encontrado, gerando um novo.."
  dokku letsencrypt:enable $APP_NAME 
  dokku proxy:build-config $APP_NAME
else
  echo "O certificado $APP_NAME ja existe... saindo agora!"
  dokku proxy:build-config $APP_NAME
fi