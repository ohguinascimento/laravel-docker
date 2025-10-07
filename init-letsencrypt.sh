#!/bin/bash

# Verifique se os domínios foram passados como argumento
if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Erro: docker-compose não está instalado.' >&2
  exit 1
fi

domains=(srv1013296.hstgr.cloud) # <<< IMPORTANTE: Substitua com seus domínios
rsa_key_size=4096
data_path="./docker/certbot" # Caminho para os dados do Certbot
email="seu-email@seu-dominio.com" # <<< IMPORTANTE: Adicione um e-mail válido
staging=0 # Mude para 1 para usar o ambiente de teste do Let's Encrypt

if [ -d "$data_path" ]; then
  read -p "Dados existentes encontrados para $domains. Continuar e substituir? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Baixando parâmetros TLS recomendados ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Criando certificado dummy para $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

echo "### Iniciando Nginx ..."
docker-compose up --force-recreate -d nginx
echo

echo "### Deletando certificado dummy ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo

echo "### Solicitando certificado Let's Encrypt para $domains ..."
# Junte os domínios para o certbot
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Selecione o e-mail de registro
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Habilite o modo de teste (staging) se necessário
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Recarregando Nginx ..."
docker-compose exec nginx nginx -s reload