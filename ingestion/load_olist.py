"""Carrega os CSVs da Olist no schema raw do Postgres."""

import logging
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

RAIZ = Path(__file__).resolve().parents[1]
PASTA_DADOS = RAIZ / "data" / "raw"
SCHEMA = "raw"

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)


def criar_engine():
    load_dotenv(RAIZ / "olist" / ".env")
    url = URL.create(
        drivername="postgresql+psycopg2",
        username=os.getenv("DBT_PG_USER", "dbt_user"),
        password=os.environ["DBT_ENV_SECRET_PG_PASSWORD"],
        host=os.getenv("DBT_PG_HOST", "localhost"),
        port=5432,
        database="olist",
    )
    return create_engine(url)


def nome_da_tabela(arquivo: Path) -> str:
    return arquivo.stem.removeprefix("olist_").removesuffix("_dataset")


def carregar(engine, arquivo: Path) -> None:
    tabela = nome_da_tabela(arquivo)
    df = pd.read_csv(arquivo, dtype=str)
    df["_loaded_at"] = pd.Timestamp.now(tz="UTC")
    df.to_sql(tabela, engine, schema=SCHEMA, if_exists="replace",
              index=False, chunksize=10_000, method="multi")
    log.info("%s: %s linhas carregadas", tabela, f"{len(df):,}")


def main() -> None:
    arquivos = sorted(PASTA_DADOS.glob("*.csv"))
    if not arquivos:
        raise FileNotFoundError(f"Nenhum CSV encontrado em {PASTA_DADOS}")

    engine = criar_engine()
    with engine.begin() as conn:
        conn.execute(text(f"create schema if not exists {SCHEMA}"))

    for arquivo in arquivos:
        carregar(engine, arquivo)


if __name__ == "__main__":
    main()