from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "API de Jogadores online!"}

# Nota: Testes de CRUD reais exigiriam configurar um banco de teste
# Para este desafio, testar a raiz garante que a API sobe sem erros.