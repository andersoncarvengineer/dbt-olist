# dbt-olist

Projeto de estudo de dbt Core com dados públicos de e-commerce da Olist.

## Pré-requisitos

- Python 3.12 (veja `.python-version`)
- PostgreSQL 17 com o banco `olist` e o usuário `dbt_user` como dono do banco
- VS Code com a extensão dbt Power User

## Configuração

```powershell
python -m venv .venv
.venv\Scripts\Activate
python -m pip install -r requirements.txt
```

1. Copie `olist/.env.example` para `olist/.env`
2. Preencha `DBT_ENV_SECRET_PG_PASSWORD` com a senha do `dbt_user`
3. Abra a pasta `dbt-olist` no VS Code e selecione o interpretador `.venv`

## Como rodar

Os comandos do dbt rodam de dentro da pasta `olist`, que é de onde o `.env` e o `profiles.yml` são lidos:

```powershell
cd olist
dbt debug
```