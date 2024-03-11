#!/bin/bash
URL_STACKS=https://portainer.confessaai.com.br/api/stacks
URL=https://portainer.confessaai.com.br/api/endpoints/2
API_KEY=ptr_Tj0M++bM4NmYxQiAx/6ycAe/aq691iYQGMXx/Kkd6RY=
STACK_NAME=confessai_backend
CONTAINER_NAME=confessai_backend-api-1
FILE_PATH="./stack-portainer.yml"
ENDPOINT=2
api_docker=https://portainer.confessaai.com.br/api/endpoints/2/docker
MANIPULA_CONTAINER=$api_docker/containers
GET_IMAGE_SHA=$api_docker/images/json
DELETE_IMAGE=$api_docker/images
tags=guiinfo3333/confessai_backend:latest

echo "printando variaveis"
echo $URL_STACKS
echo $URL
echo $API_KEY
echo $STACK_NAME
echo $CONTAINER_NAME
echo $FILE_PATH
echo $ENDPOINT
echo $api_docker
echo $MANIPULA_CONTAINER
echo $MANIPULA_CONTAINER
echo $GET_IMAGE_SHA
echo "finalizando print variaveis"


VARIAVEL="curl -k -X GET "$URL_STACKS" -H "X-API-Key: $API_KEY" --insecure" 
response=$($VARIAVEL)
  echo "*******************************"
  echo $VARIAVEL
  echo "fim da chamada do response"
  echo "*******************************"
response_get_sha=$(curl -k -X GET "$GET_IMAGE_SHA" -H "X-API-Key: $API_KEY" --insecure)
  echo "*******************************"
  echo "fim da chamada do response do response_get_sha"
  echo "*******************************"

  # Obtenha o ID do contêiner com base no nome
  CONTAINER_ID=$(curl -k -X GET "$MANIPULA_CONTAINER/json" -H "X-Api-Key: $API_KEY" | jq -r '.[] | select(.Names[] | contains("'$CONTAINER_NAME'")) | .Id')

  echo "*******************************"
  echo "fim da chamada do CONTAINER_ID" $CONTAINER_ID
  echo "*******************************"

  IMAGE_SHA=$(echo "$response_get_sha" | jq -r '.[] | select(.RepoTags | index("'"$tags"'") // null != null) | .Id')

  echo "*******************************"
  echo "fim da chamada do IMAGEM_SHA" $IMAGE_SHA
  echo "*******************************"

# Obtém o ID da stack
  id=$(echo "$response" | jq -r '.[] | select(.Name == "'"$STACK_NAME"'") | .Id')
# Monta a URL para a exclusão
  DELETE_URL="$URL_STACKS/$id"
   echo "id da stack" $id
  # Extrai o valor do campo "Name" usando jq
  name=$(echo "$response" | jq -r '.[] | select(.Name == "'"$STACK_NAME"'") | .Name')

  # Imprime o nome da stack
  echo "A Stack chamada $name está criada."

# Verifica se a stack está criada
if echo "$response" | jq -e '.[] | select(.Name == "'"$STACK_NAME"'")' > /dev/null; then

  # verifica se o container existe. 
  if [ ! -z "$CONTAINER_ID" ]; then

    echo "pausando container"
    curl -k -X POST "$MANIPULA_CONTAINER/$CONTAINER_NAME/stop" -H "X-API-Key: $API_KEY"
    sleep 5

    echo "deletando container"
    curl -k -X DELETE "$MANIPULA_CONTAINER/$CONTAINER_NAME" -H "X-API-Key: $API_KEY"
    sleep 5

    echo "deletando imagem"
    echo "================"
    curl -X DELETE "$DELETE_IMAGE/$IMAGE_SHA" -H "X-API-Key: $API_KEY" --insecure
    sleep 10
    echo "deletando stack"
    curl -X DELETE "$DELETE_URL" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure
    echo "Stack $STACK_NAME deletada. ID: $id"

    echo "=========================================="
    echo "CRIANDO A STACK $name"
    echo "=========================================="
    response=$(curl -X POST "$URL_STACKS" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure)

    # Imprimir a resposta da requisição 
    echo "Resposta da solicitação POST: $response"

    # Extrair o valor do campo "Id" da nova stack usando jq
    id=$(echo "$response" | jq -r '.Id')

    # Imprimir o valor do Id
    echo "Nova Stack criada. Id: $id"
  else
    echo "stack encontrada, mas container não encontrado"

    echo "deletando container"
    curl -k -X DELETE "$MANIPULA_CONTAINER/$CONTAINER_NAME" -H "X-API-Key: $API_KEY"
    sleep 5

    echo "deletando imagem"
    curl -X DELETE "$deleteimagem/$IMAGE_SHA" -H "X-API-Key: $API_KEY" --insecure
    sleep 5
    
    echo "================"
    echo "DELETANDO STACK"
    echo "================"
    curl -X DELETE "$DELETE_URL" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure
    echo "Stack deletada. ID: $id"

    echo "============================"
    echo "CRIANDO A STACK $name"
    echo "============================"
    response=$(curl -X POST "$URL_STACKS" \
    -H "X-API-Key: $API_KEY" \
    -F "type=2" \
    -F "method=file" \
    -F "file=@$FILE_PATH" \
    -F "endpointId=$ENDPOINT" \
    -F "Name=$STACK_NAME" --insecure)
  fi

else
  echo "======================================"
  echo "NENHUMA STACK DA APLICAÇÃO ENCONTRADA."
  echo "======================================"

  # VALIDAR PROCESSO DE EXCLUSAO DA IMAGEM
  echo "deletando imagem"
    curl -X DELETE "$deleteimagem/$IMAGE_SHA" -H "X-API-Key: $API_KEY" --insecure
    sleep 5

  echo "CRIANDO A NOVA STACK"
  echo "===================="
  response=$(curl -X POST "$URL_STACKS" \
  -H "X-API-Key: $API_KEY" \
  -F "type=2" \
  -F "method=file" \
  -F "file=@$FILE_PATH" \
  -F "endpointId=$ENDPOINT" \
  -F "Name=$STACK_NAME" --insecure)

  # Imprimir a resposta da requisição 
  echo "Resposta da solicitação POST: $response"

  # Extrair o valor do campo "Id" da nova stack usando jq
  id=$(echo "$response" | jq -r '.Id')

  # Imprimir o valor do Id
  echo "Nova Stack criada. Id: $id"
fi