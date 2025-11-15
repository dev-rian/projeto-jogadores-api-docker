# Projeto API de Futebol com Docker

Este projeto implementa uma API CRUD simples em Python (FastAPI) para gerenciar jogadores de futebol, rodando em um ambiente multi-container com Docker e Docker Compose.

O objetivo é demonstrar o uso de:
- Dockerfile multi-stage com imagens Alpine
- Docker Compose para orquestrar serviços (API + Banco)
- Redes personalizadas
- Volumes nomeados para persistência de dados
- Variáveis de ambiente para configuração segura
- Práticas de segurança de banco (usuário não-root)

## Pré-requisitos

- Docker
- Docker Compose (geralmente já vem com o Docker Desktop)

## Como Rodar

1.  **Clone o repositório**
    ```sh
    git clone https://github.com/dev-rian/projeto-jogadores-api-docker
    cd projeto-docker-futebol
    ```

2.  **Configure as Variáveis de Ambiente**
    Crie um arquivo `.env` na raiz do projeto, baseado no exemplo abaixo.
    **Importante:** O `APP_DB_USER` e `APP_DB_PASS` devem ser os mesmos definidos em `db_init/init.sql`.

    ```
    # Configuração do Super-usuário do Postgres
    POSTGRES_USER=adicione o user sem aspas
    POSTGRES_PASSWORD=adicione a senha sem aspas
    POSTGRES_DB=futebol_db

    # Credenciais do Usuário da Aplicação
    APP_DB_USER=adicione o user sem aspas
    APP_DB_PASS=adicione a senha sem aspas

    # Host do DB
    DB_HOST=db
    ```

3.  **Suba os Containers**
    Use o Docker Compose para construir as imagens e iniciar os serviços. O comando `--build` força a reconstrução da imagem da API.

    ```sh
    docker-compose up -d --build
    ```

## Como Testar

A API estará disponível em `http://localhost:8000`.

### 1. Documentação Interativa (Swagger)

Acesse a documentação gerada automaticamente pelo FastAPI para ver e testar todos os endpoints:

**[http://localhost:8000/docs](http://localhost:8000/docs)**

### 2. Teste via Insomnia

- Criar um Jogador (POST)
- Abra o Insomnia e crie uma nova requisição (New Request).

- Defina o método como POST.

- Insira a URL: http://localhost:8000/jogadores/.

- Vá para a aba Body e selecione o formato JSON.

- Cole o JSON do jogador que deseja criar:

```json
{
  "nome_completo": "Arrascaeta",
  "time_atual": "Flamengo",
  "posicao": "Meio-campo",
  "numero_camisa": 10
}
```