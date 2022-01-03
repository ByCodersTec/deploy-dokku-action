APP_NAME="$1"
APP_NAME=$(echo $APP_NAME | cut -d'/' -f 2)

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