[![CI/CD Pipeline](https://github.com/dev-rian/projeto-jogadores-api-docker/actions/workflows/cicd.yml/badge.svg)](https://github.com/dev-rian/projeto-jogadores-api-docker/actions/workflows/cicd.yml)

# Projeto API de Futebol com Docker e CI/CD

Este projeto implementa uma API CRUD simples em Python (FastAPI) para gerenciar jogadores de futebol, rodando em um ambiente multi-container com Docker e Docker Compose. O projeto inclui um pipeline completo de CI/CD utilizando GitHub Actions.

Objetivos do Projeto:

- Dockerfile multi-stage com imagens Alpine (leves e otimizadas).
- Docker Compose para orquestrar serviços (API + Banco de Dados).
- Redes personalizadas para isolamento de comunicação.
- Volumes nomeados para persistência de dados do banco.
- Variáveis de ambiente para configuração segura de credenciais.
- Segurança: Configuração de usuário não-root para a aplicação acessar o banco.
- CI/CD: Automação de testes, build e deploy em VPS.

## Pré-requisitos (Rodando localmente)

- Docker
- Docker Compose

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
- Insira a URL: `http://localhost:8000/jogadores/`.
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

Listar Jogadores (GET)

URL: `http://localhost:8000/jogadores/`

## CI/CD Pipeline

Este projeto utiliza GitHub Actions para automação completa. O workflow está definido em `.github/workflows/cicd.yml`.

Como funciona o Pipeline:

- Testes (CI): A cada push na branch main, testes unitários são executados automaticamente com pytest para garantir a integridade do código.
- Build & Push (CD): Se os testes passarem, uma nova imagem Docker é construída e enviada para o Docker Hub, versionada com o hash do commit.
- Deploy (CD): O GitHub conecta-se via SSH ao servidor VPS, baixa a nova imagem e recria os containers com a versão atualizada.

Segredos (Secrets) configurados no GitHub:

Para que o pipeline funcione, as seguintes variáveis foram configuradas em Settings > Secrets and variables > Actions:

- DOCKER_USERNAME: Usuário do Docker Hub.
- DOCKER_PASSWORD: Token de acesso ou senha do Docker Hub.
- HOST: Endereço IP do servidor VPS.
- USERNAME: Usuário SSH do servidor.
- KEY: Chave privada SSH para acesso ao servidor.
- PORT: Porta SSH (padrão 22).

## Configuração no Servidor de Produção (VPS)

Para o deploy funcionar, o ambiente de produção requer:

- Docker e Docker Compose instalados.
- Estrutura de pastas criada (~/app).
- Arquivo .env com as credenciais de produção criado manualmente no servidor (não versionado no Git por segurança).