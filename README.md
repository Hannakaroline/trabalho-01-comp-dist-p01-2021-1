# trabalho-01-comp-dist-p01-2021-1

## Pré-requisitos

- Docker: [Guia de Instalação Docker](https://docs.docker.com/get-docker/)
- Docker compose: [Guia de Instalação Docker Compose](https://docs.docker.com/compose/install/) (Desnecessário se for no mac, o instalador do docker já instala docker compose também)

## Como fazer o setup da aplicação

- Vá atá a pasta `reservas_api` no raiz do repositório.
```
cd reservas_api
```

- Faça o setup dos containers da API e do Banco de Dados, no terminal de comando:
```
docker-compose build
```

- Crie o banco de dados e faça as migrações necessárias
```
docker-compose run api rake db:create
docker-compose run api rake db:migrate
```

- Pronto, agora você pode rodar a API via
```
docker-compose up
```

A aplicação estará disponível em `localhost:3000`
Para fazer testes você pode usar a coleção do Postman: https://www.getpostman.com/collections/c891544b11d6d38bad11A
A coleção serve como um cliente básico da API e também como uma documentação simplificada do funcionamento da API.
