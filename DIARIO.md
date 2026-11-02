
Dia 01 (02/11/2026|Segunda)

Passo 1 — Criar a pasta e entrar nela
powershell
mkdir C:\projetos\dbt-olist
cd C:\projetos\dbt-olist

Passo 2 — Fixar a versão do Python
powershell
pyenv local 3.12.10
python --version

Passo 3 — Criar e ativar o ambiente virtual
powershell
python -m venv .venv
.venv\Scripts\Activate

Passo 4 — Confirmar que está usando o Python certo
powershell
where.exe python
python -m pip install --upgrade pip
python -m pip --version
A primeira linha do where.exe precisa ser C:\projetos\dbt-olist\.venv\Scripts\python.exe.
O pip --version precisa terminar com ...\dbt-olist\.venv\Lib\site-packages\pip.
Lembre do hábito: sempre python -m pip, nunca pip sozinho. Assim o pip é o do Python ativo.

Passo 5 — Abrir no VS Code a pasta certa
powershell
code .

Não abra uma pasta acima dela, como a analytics_engineer: o VS Code escolhe o Python pela pasta aberta, e foi esse o outro motivo do erro da extensão.

Depois confira na barra de status, canto inferior direito: precisa aparecer .venv (3.12.10). Se aparecer outra coisa, use Ctrl+Shift+P → Python: Select Interpreter → escolha o .venv, marcado como Workspace.

Dia 02 (02/11/2026|Segunda)

Passo 1 — Conferir a configuração global do Git

git config --global user.name
git config --global user.email
git config --global init.defaultBranch
git config --global core.autocrlf

Passo 2 — Iniciar o repositório
powershell
git init
git status

O .venv/ vai aparecer na lista de arquivos não rastreados. É o que vamos impedir agora.

Passo 3 — Criar o .gitignore pelo VS Code

Crie o arquivo .gitignore na raiz pelo VS Code, não com echo (o PowerShell pode gravar em UTF-16, e o Git ignora o arquivo inteiro):

gitignore
# Ambiente Python
.venv/
venv/
__pycache__/

# Gerados pelo dbt
target/
dbt_packages/
logs/
.user.yml

# Segredos
.env
*.json

Repare em duas mudanças em relação à primeira versão:

venv/ sem ponto também foi incluído. É uma rede de segurança: se alguém criar o ambiente sem o ponto, como aconteceu, ele não vai para o Git.
O .env está aqui, e o .env.example não. O padrão .env ignora só o arquivo com esse nome exato, então o .env.example continua indo para o Git, como deve.

Passo 4 — README e primeiro commit

Crie o README.md pelo VS Code, com letras maiúsculas no nome, com o título e uma linha de descrição:

markdown
# dbt-olist

Projeto de estudo de dbt Core com dados públicos de e-commerce da Olist.

Depois:

powershell
git add .
git status
git commit -m "chore: estrutura inicial do projeto"

Passo 5 — Criar o repositório no GitHub

Logado com a conta andersoncarvti, crie o repositório dbt-olist:

Público (no plano gratuito, a proteção de branch só vale em repositório público).
Sem README, sem .gitignore e sem licença (senão o primeiro push é recusado por históricos diferentes).
Passo 6 — Conectar e enviar

Na página do repositório, clique no botão verde Code → HTTPS e copie o endereço. Ele será https://github.com/andersoncarvti/dbt-olist.git.

Agora, coloque o nome da conta no endereço, antes do @github.com:

powershell
git remote add origin https://andersoncarvti@github.com/andersoncarvti/dbt-olist.git
git remote -v
Por que o nome da conta no endereço: você tem duas contas no GitHub. Assim o Git sabe qual login usar neste repositório, e o erro 403 da primeira tentativa não acontece.
Por que o git remote -v: confere o destino antes de enviar. As duas linhas precisam mostrar andersoncarvti.

Então:

powershell
git push -u origin main


Operação específica
Execute no terminal:

powershell
git add README
git commit --amend --no-edit
Dessa forma, o README será incorporado ao commit anterior, e a mensagem do commit permanecerá inalterada .


Passo 7 — Proteger a main com um ruleset

No repositório: Settings → Rules → Rulesets → New ruleset → New branch ruleset.

Ruleset Name: protege-main.
Enforcement status: Active.
Bypass list: deixe vazia.
Target branches: clique em Add target → Include default branch. Este é o passo que faltou da primeira vez. O nome do ruleset é só um rótulo; quem define a branch protegida é o alvo.
Marque Require a pull request before merging, com Required approvals = 0.
Confira que Block force pushes e Restrict deletions estão marcados.
Clique em Create, no fim da página.

Depois de salvar, abra o ruleset de novo e confira: a faixa amarela dizendo que o ruleset não tem alvo não pode aparecer.

Por que um nome diferente de main: chamando o ruleset de protege-main, fica claro que o nome é um rótulo, e não o alvo. Isso evita repetir a confusão.
Por que 0 aprovações: o GitHub não deixa você aprovar o próprio PR. Com 1, você nunca conseguiria fazer merge trabalhando sozinho.

Passo 8 — Quebre de propósito
powershell
git commit --allow-empty -m "teste: protecao da main"
git push

O push precisa ser recusado com push declined due to repository rule violations. Depois, desfaça o commit local:

powershell
git status
git reset --hard origin/main

Confira o git status antes do reset: ele precisa dizer que não há alterações pendentes. Lembre que o reset --hard descarta tudo que não foi enviado.

Desta vez, nenhum commit de teste vai vazar para a main.




Dia 03(02/11/2026|Segunda)

Passo 0 — Branch e prompt
powershell
cd C:\projetos\dbt-olist
.venv\Scripts\Activate
git checkout -b feat/setup-dbt

Se a branch já foi criada no fim do Dia 2, o Git vai avisar que ela já existe. Nesse caso, use git checkout feat/setup-dbt.


Passo 1 — Criar o usuário e o banco
powershell
psql -U postgres
sql
CREATE ROLE dbt_user WITH LOGIN;
\password dbt_user

O \password pede a senha duas vezes, sem mostrar na tela. Depois:

sql
CREATE DATABASE olist OWNER dbt_user;
\du
\l
\q

Confira que o \du lista o dbt_user e que o \l mostra o olist com dono dbt_user.

Por que \password em vez de PASSWORD '...' no comando: o psql grava num arquivo de histórico tudo que você digita. Com a senha dentro do CREATE ROLE, ela fica salva em texto puro nesse arquivo. O \password não deixa a senha no histórico.
Por que OWNER dbt_user: a partir do Postgres 15, só o dono do banco cria objetos no schema public sem permissões extras.
Se o dono ficar errado: o dbt debug passa, mas o primeiro dbt run falha com permission denied.

Dica para a senha: letras, números, hífen e underline. Evite :, #, aspas e @, que têm significado especial no YAML e em URLs de conexão.

Passo 2 — Testar o login fora do dbt
powershell
psql -U dbt_user -d olist -h localhost

Se conectar, saia com \q. Só siga quando isso funcionar. Se o psql conecta, qualquer erro restante está na configuração do dbt, e não no banco.

Passo 3 — Instalar o dbt
powershell
python -m pip install "dbt-core~=1.12.0" dbt-postgres
dbt --version
python -m pip check
python -m pip freeze | Out-File -Encoding utf8 requirements.txt
No dbt --version, confira Core: 1.12.x e o plugin postgres. O aviso de que o dbt v2 existe é esperado: o Postgres ainda não está disponível no v2.
O pip check precisa responder No broken requirements found.

Abra o requirements.txt e confira duas coisas:

Devem aparecer dbt-core, dbt-postgres e o python-dotenv (que o dbt usa para ler o .env).
Se a barra de status mostrar UTF-8 with BOM, clique nela → Save with Encoding → UTF-8.


Passo 4 — Criar o projeto sem tocar no profiles.yml global
powershell
dbt init olist --skip-profile-setup
Por que --skip-profile-setup: sem essa opção, o dbt init faz as perguntas de conexão e grava as respostas, com a senha, no profiles.yml global em C:\Users\ander\.dbt. Exatamente o que você não quer.
Com a opção: ele só cria a estrutura do projeto, e o profiles.yml você mesmo cria no próximo passo.

Passo 5 — Criar os três arquivos de configuração

Crie os três pelo VS Code, dentro da pasta olist.

olist/profiles.yml (vai para o Git):

yaml
olist:
  target: dev
  outputs:
    dev:
      type: postgres
      host: "{{ env_var('DBT_PG_HOST', 'localhost') }}"
      port: 5432
      user: "{{ env_var('DBT_PG_USER', 'dbt_user') }}"
      pass: "{{ env_var('DBT_ENV_SECRET_PG_PASSWORD') }}"
      dbname: olist
      schema: "{{ env_var('DBT_SCHEMA', 'dbt_anderson') }}"
      threads: 4

olist/.env (não vai para o Git):

DBT_ENV_SECRET_PG_PASSWORD=SUA-SENHA

Sem aspas e sem espaços ao redor do =.

olist/.env.example (vai para o Git):

DBT_ENV_SECRET_PG_PASSWORD=
# Opcionais (têm valor padrão no profiles.yml)
# DBT_PG_HOST=localhost
# DBT_PG_USER=dbt_user
# DBT_SCHEMA=dbt_seunome

Revisando as decisões:

O nome olist na primeira linha do profiles.yml precisa ser igual ao profile: do dbt_project.yml. Confira lá.
O prefixo DBT_ENV_SECRET_ faz o dbt esconder o valor da senha nos logs.
Variáveis com valor padrão (host, user, schema) não são segredo. A senha não tem padrão, de propósito: sem ela, o dbt falha com erro claro.
A ligação entre os arquivos é o nome da variável, que precisa ser idêntico no .env e no env_var do profiles.yml.

Passo 6 — Provar que o .env está ignorado

Da raiz do repositório:

powershell
git check-ignore -v olist/.env
git check-ignore -v olist/.env.example
O primeiro precisa mostrar a regra que ignora o arquivo, algo como .gitignore:13:.env olist/.env.
O segundo não deve mostrar nada, porque o .env.example precisa ir para o Git.


Passo 7 — O teste do dia
powershell
cd olist
dbt debug

Além do All checks passed!, procure esta linha no começo da saída:

Using profiles.yml file at C:\projetos\dbt-olist\olist\profiles.yml

Ela prova que o dbt está usando o arquivo do projeto, e não o global.

Agora quebre de propósito, um comando por vez:

powershell
Rename-Item .env .env.bak
dbt debug

Precisa falhar com Env var required but not provided: 'DBT_ENV_SECRET_PG_PASSWORD'.

powershell
Rename-Item .env.bak .env
dbt debug

Precisa passar de novo.

Passo 8 — Commit

Volte para a raiz, porque o git add . só alcança a pasta atual:

powershell
cd ..
git status

Na lista devem aparecer a pasta olist/ e o requirements.txt, e nada de .venv, logs ou .env. Então:

powershell
git add .
git commit -m "feat: projeto dbt com profiles no projeto e senha via .env"
git ls-files olist/.env olist/.env.example olist/profiles.yml
git push -u origin feat/setup-dbt

O git ls-files precisa listar só o .env.example e o profiles.yml. Se o .env aparecer, não faça o push e me avise.

Dia 04(02/11/2026|Segunda)

Passo 1 — Abrir a pasta certa e conferir o interpretador

No VS Code, confira no topo do Explorer que a pasta aberta é dbt-olist, e não uma pasta acima. Se não for, use File → Open Folder → C:\projetos\dbt-olist.

Na barra de status, canto inferior direito, precisa aparecer .venv (3.12.10). Se não aparecer: Ctrl+Shift+P → Python: Select Interpreter → .venv, marcado como Workspace.

Depois, Ctrl+Shift+P → Developer: Reload Window.

Por quê: a extensão detecta o Python e o projeto dbt quando inicia. Se o interpretador mudou depois, ela pode continuar com a detecção antiga até o VS Code recarregar.
Passo 2 — Testar as três ações da extensão
Abra olist/models/example/my_second_dbt_model.sql e use Ctrl+Shift+P → Compile dbt preview. No painel ao lado, o {{ ref('my_first_dbt_model') }} deve aparecer como "olist"."dbt_anderson"."my_first_dbt_model".
Clique na aba Lineage no painel de baixo. Devem aparecer os dois modelos ligados.
Abra o my_first_dbt_model.sql e aperte Ctrl+Enter (Execute dbt SQL). Na aba Query Results devem aparecer duas linhas: id = 1 e id vazio.

O terceiro teste só funciona se a extensão conseguir se conectar ao banco, então ele também prova que a extensão está lendo o .env.

Se aparecer o erro “dbt is not installed in the selected Python environment”, é o mesmo caso da primeira tentativa: a pasta aberta ou o interpretador estão errados. Volte ao Passo 1.

Passo 3 — README com o passo a passo de configuração

Edite o README.md da raiz:

markdown
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
Por que cada detalhe está no README: cada item corresponde a um erro real que você encontrou. O .venv com ponto, a pasta aberta no VS Code, o .env lido da pasta atual e o dono do banco.
Se não documentar: a próxima pessoa vai tropeçar nos mesmos erros, e vai procurar você para perguntar. É bom ser procurado, mas pelas perguntas difíceis.
Passo 4 — Commit e push

Da raiz:

powershell
git status
git add .
git commit -m "docs: pre-requisitos e configuracao no readme"
git push

Como a branch já está ligada ao GitHub desde ontem, basta o git push, sem o nome da branch.



Dia 05(02/11/2026|Segunda)

Bora para o Dia 5, o fechamento da Fase 0. Hoje você vai fazer o ciclo completo que usa todo dia num time: branch → Pull Request → revisão → merge → atualizar a máquina.

Passo 1 — Conferir que está tudo enviado
powershell
cd C:\projetos\dbt-olist
.venv\Scripts\Activate
git status

A resposta precisa dizer nothing to commit, working tree clean e Your branch is up to date with 'origin/feat/setup-dbt'.

Se houver algo pendente: faça o commit e o git push antes. Um PR só mostra o que já está no GitHub.

Passo 2 — Uma configuração útil no repositório

No GitHub: Settings → General → seção Pull Requests → marque Automatically delete head branches.

Por quê: depois do merge, o GitHub apaga sozinho a branch de trabalho. Ela já cumpriu o papel dela.
Se não marcar: em poucos meses o repositório acumula dezenas de branches velhas, e ninguém sabe quais ainda estão em uso.
Passo 3 — Abrir o Pull Request

No GitHub: aba Pull requests → New pull request. Selecione:

base: main (para onde as mudanças vão)
compare: feat/setup-dbt (de onde as mudanças vêm)

Título: feat: setup do projeto dbt com Postgres

Descrição:

markdown
## Contexto
Estrutura inicial do projeto dbt-olist, conectado ao PostgreSQL local.

## O que mudou
- Projeto dbt criado em `olist/` (dbt Core 1.12, adapter postgres)
- `profiles.yml` dentro do projeto, só com `env_var`
- Senha lida de `olist/.env` (ignorado pelo Git); modelo em `.env.example`
- `requirements.txt` com versões fixadas
- README com pré-requisitos e configuração

## Como testar
1. Seguir o README
2. `cd olist` e `dbt debug` → All checks passed

## Checklist
- [ ] Nenhuma senha ou chave nos arquivos
- [ ] `.env` fora do repositório
Por que escrever a descrição mesmo trabalhando sozinho: em time, quem revisa não estava na sua cabeça. A descrição diz o que olhar e como testar. Também vira documentação: daqui a um ano, você vai abrir este PR para lembrar por que o profiles.yml está dentro do projeto.
Se deixar em branco: o revisor precisa adivinhar a intenção pelo código, e a revisão vira superficial ou demorada.

Clique em Create pull request.

Passo 4 — Revisar como se fosse de outra pessoa

Abra a aba Files changed e leia arquivo por arquivo. Procure especialmente:

Nenhum .env na lista de arquivos.
O profiles.yml sem nenhuma senha escrita, só env_var.
O .env.example com o valor vazio.
O requirements.txt legível, sem caracteres estranhos (sinal de UTF-16).

Marque os itens do checklist da descrição conforme confere.

Exercício: deixe um comentário numa linha do profiles.yml. Passe o mouse sobre a linha do pass, clique no + azul e escreva algo como “Senha via env_var com prefixo DBT_ENV_SECRET_, mascarada nos logs”. Em time, é assim que se conversa sobre o código.

Por que revisar o próprio PR: essa aba é a última barreira antes da main. Ver o diff numa tela diferente do editor revela coisas que passaram despercebidas.
Se pular: um .env commitado por engano vai direto para a main pública.
Passo 5 — Fazer o merge

No fim da página do PR, clique na setinha do botão de merge e escolha Squash and merge.

Opção	Resultado na main
Create a merge commit	Todos os commits da branch, mais um commit de merge
Squash and merge	Um único commit com todas as mudanças do PR
Rebase and merge	Todos os commits da branch, em linha, sem commit de merge
Por que squash: cada PR vira um commit na main, com uma mensagem clara. O histórico fica fácil de ler e de desfazer, porque reverter uma mudança é reverter um commit só.
O custo: os commits intermediários da branch não aparecem na main. Para PRs pequenos de um time de dados, isso quase nunca faz falta.

Confira a mensagem do commit (pode deixar o título do PR) e confirme. Como você ativou o Passo 2, a branch some do GitHub automaticamente.

Passo 6 — Trazer o merge para a sua máquina
powershell
git checkout main
git pull
git log --oneline -3

O git log deve mostrar o commit do squash no topo.

Agora apague a branch local:

powershell
git branch -d feat/setup-dbt

Atenção, pegadinha do squash: o Git provavelmente vai recusar, dizendo que a branch “is not fully merged”. Isso acontece porque o squash criou um commit novo na main, e o Git não reconhece os commits da branch lá dentro, mesmo com o conteúdo idêntico. Como você acabou de conferir o merge no GitHub, é seguro forçar:

powershell
git branch -D feat/setup-dbt
git fetch --prune
git branch -a
Por que o -D maiúsculo só agora: ele apaga sem verificar. Use apenas depois de confirmar que o PR foi mergeado.
Por que o fetch --prune: remove da sua máquina a referência origin/feat/setup-dbt, que aponta para uma branch que não existe mais no GitHub.
O git branch -a deve mostrar só a main e a remotes/origin/main.
Passo 7 — O teste do README

Este é o teste mais importante do dia. Em vez de só apagar o .venv, você vai clonar o projeto numa pasta nova, como faria um colega no primeiro dia de trabalho. Assim, o teste não depende de nada que esteja só na sua máquina.

powershell
deactivate
cd C:\projetos
git clone https://github.com/andersoncarvengineer/dbt-olist.git teste-readme
cd teste-readme

A partir daqui, siga só o que está escrito no README, sem consultar esta conversa. Faça uma anotação a cada ponto em que você hesitar ou precisar adivinhar algo.

O teste passa quando o dbt debug dentro de teste-readme\olist der All checks passed!.

Por que clonar: no clone não existe o seu .env, nem o seu .venv. Se o README esqueceu algum passo, você vai descobrir agora, e não um colega daqui a três meses.
Se o teste falhar ou você hesitar: não é um problema, é o resultado do teste. Volte ao projeto original, corrija o README numa branch nova e abra um segundo PR.

Depois, apague a pasta de teste:

powershell
cd C:\projetos
Remove-Item -Recurse -Force teste-readme
Passo 8 — Segundo PR: o DIARIO.md

Para fixar o fluxo, repita o ciclo sozinho, sem roteiro detalhado:

Na pasta dbt-olist, crie a branch docs/diario.
Crie o DIARIO.md na raiz com os aprendizados dos Dias 1 a 5.
Commit, push, PR, revisão, squash and merge.
checkout main, pull, apagar a branch local.