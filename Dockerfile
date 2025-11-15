FROM python:3.11-alpine AS builder

# Diretório de trabalho
WORKDIR /opt/venv

# Ambiente virtual
RUN python -m venv .

# Venv para os próximos comandos
ENV PATH="/opt/venv/bin:$PATH"

COPY app/requirements.txt .

# Dependências dentro do venv
# Usamos --no-cache-dir para manter a imagem limpa
RUN pip install --no-cache-dir -r requirements.txt

# Imagem python alpine limpa com o venv já preparado
FROM python:3.11-alpine

# Diretório de trabalho da API
WORKDIR /api

# AMBIENTE VIRTUAL PRONTO do estágio 'builder'
COPY --from=builder /opt/venv /opt/venv

# CÓDIGO da aplicação
COPY app/ .

# Adicionando o venv ao PATH da imagem final
ENV PATH="/opt/venv/bin:$PATH"

# Comando para executar a aplicação quando o container iniciar
# O Uvicorn vai rodar na porta 8000 e escutar em todas as interfaces (0.0.0.0)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]