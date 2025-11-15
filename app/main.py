import os
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, Field
from sqlalchemy import create_engine, Column, Integer, String, Sequence
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

# --- Configuração do Banco de Dados ---

# Lê as variáveis de ambiente
DB_USER = os.getenv("APP_DB_USER")
DB_PASS = os.getenv("APP_DB_PASS")
DB_HOST = os.getenv("DB_HOST", "db") # "db" é o nome do serviço no docker-compose
DB_NAME = os.getenv("POSTGRES_DB")

# String de conexão
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:5432/{DB_NAME}"

# Configuração do SQLAlchemy
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- Modelos (Pydantic e SQLAlchemy) ---

# Modelo SQLAlchemy
class JogadorDB(Base):
    __tablename__ = "jogadores"
    id = Column(Integer, Sequence("jogadores_id_seq"), primary_key=True, index=True)
    nome_completo = Column(String(100), nullable=False)
    time_atual = Column(String(50))
    posicao = Column(String(50))
    numero_camisa = Column(Integer)

# Modelo Pydantic (Base)
class JogadorBase(BaseModel):
    nome_completo: str
    time_atual: str | None = None
    posicao: str | None = None
    numero_camisa: int | None = None

# Modelo Pydantic para Criar
class JogadorCreate(JogadorBase):
    pass

# Modelo Pydantic para Ler
class Jogador(JogadorBase):
    id: int

    class Config:
        from_attributes = True # Antigo orm_mode = True

# --- Inicialização da API ---
app = FastAPI(title="API de Jogadores Brasileiros")

# Dependência para obter a sessão do banco
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- Endpoints do CRUD ---

@app.post("/jogadores/", response_model=Jogador, tags=["Jogadores"])
def create_jogador(jogador: JogadorCreate, db: Session = Depends(get_db)):
    """Cria um novo jogador no banco de dados."""
    db_jogador = JogadorDB(**jogador.model_dump())
    db.add(db_jogador)
    db.commit()
    db.refresh(db_jogador)
    return db_jogador

@app.get("/jogadores/", response_model=list[Jogador], tags=["Jogadores"])
def read_jogadores(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Lista todos os jogadores."""
    jogadores = db.query(JogadorDB).offset(skip).limit(limit).all()
    return jogadores

@app.get("/jogadores/{jogador_id}", response_model=Jogador, tags=["Jogadores"])
def read_jogador(jogador_id: int, db: Session = Depends(get_db)):
    """Busca um jogador específico pelo ID."""
    db_jogador = db.query(JogadorDB).filter(JogadorDB.id == jogador_id).first()
    if db_jogador is None:
        raise HTTPException(status_code=404, detail="Jogador não encontrado")
    return db_jogador

@app.put("/jogadores/{jogador_id}", response_model=Jogador, tags=["Jogadores"])
def update_jogador(jogador_id: int, jogador: JogadorCreate, db: Session = Depends(get_db)):
    """Atualiza os dados de um jogador."""
    db_jogador = db.query(JogadorDB).filter(JogadorDB.id == jogador_id).first()
    if db_jogador is None:
        raise HTTPException(status_code=404, detail="Jogador não encontrado")
    
    # Atualiza os campos
    for key, value in jogador.model_dump().items():
        setattr(db_jogador, key, value)
        
    db.commit()
    db.refresh(db_jogador)
    return db_jogador

@app.delete("/jogadores/{jogador_id}", response_model=Jogador, tags=["Jogadores"])
def delete_jogador(jogador_id: int, db: Session = Depends(get_db)):
    """Deleta um jogador do banco."""
    db_jogador = db.query(JogadorDB).filter(JogadorDB.id == jogador_id).first()
    if db_jogador is None:
        raise HTTPException(status_code=404, detail="Jogador não encontrado")
        
    db.delete(db_jogador)
    db.commit()
    return db_jogador

# Endpoint "ping" para testar
@app.get("/", tags=["Root"])
def read_root():
    return {"status": "API de Jogadores online!"}