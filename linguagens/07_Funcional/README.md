# Interpretador de Linguagens Funcionais (LF1 / LF2 / LF3)

Estrutura de desenvolvimento, compilação e evolução de um interpretador em Haskell para a família de linguagens funcionais baseadas em gramáticas BNFC.

---

---

## Pré-requisitos

- **Dependências de Sistema**: Requeridas para a compilação do compilador e das bibliotecas (inclui o `make` e a biblioteca GMP).

```bash
sudo apt update
sudo apt install build-essential curl libgmp-dev
```

- **GHCup** _(Gerenciador de versões do GHC e Cabal)_:
  Instale executando o script oficial:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

Siga as instruções do instalador no terminal e reinicie sua sessão (ou execute `source ~/.bashrc` / `source ~/.zshrc`) para atualizar a variável de ambiente `PATH`.

- **Happy e Alex** _(Geradores de parser e lexer para Haskell)_:
  Com o GHC e Cabal instalados via GHCup, execute:

```bash
cabal update
cabal install happy alex

```

- **BNF Converter (BNFC)** _(Para recriação de sintaxe)_:

```bash
cabal install BNFC

```

- **Make** _(Utilitário de compilação)_:
  Já incluído na instalação do pacote `build-essential` no primeiro passo.

---

## Estrutura do Projeto

O trabalho está dividido em diretórios de acordo com a etapa de evolução da linguagem:

- `LF1-Enunciado`: Extensão da linguagem imperativa/básica LI2 para características funcionais.
- `LF2-Enunciado`: Adição de checagem de tipos estática e otimizações de AST.
- `LF3-Enunciado`: Introdução de funções de primeira classe (expressões lambda, aplicação parcial e composição).

---

## Guia de Compilação e Execução

### Fluxo Básico (Alunos)

1. **Implementação**: Edite a lógica necessária nos módulos do módulo atual (`Interpreter.hs`, `Typechecker.hs`, `Optimizer.hs`).
2. **Compilação do Driver**:

```bash
ghc --make Interpret.hs
```

3. **Execução e Testes**:

```bash
# Windows
Interpret.exe < examples\ex1.li3
```

```bash
# Linux / macOS
./Interpret < examples/ex1.li3
```

### Regeneração de Parser/Lexer (via BNFC)

Caso a sintaxe concreta (`.cf`) seja alterada ou seja necessário reconstruir os arquivos base:

```bash
# 1. Gerar os fontes do parser, lexer e Makefile a partir da gramática
bnfc -m NOME_DA_LINGUAGEM.cf

# 2. Compilar os fontes gerados
make

# 3. Recompilar o driver principal
ghc --make Interpret.hs

```

> **Aviso:** O arquivo `Abs*.hs` (sintaxe abstrata) é gerado automaticamente a partir do arquivo `.cf`. **Não edite arquivos `Abs*.hs` diretamente**. Altere a gramática no arquivo `.cf` e execute o BNFC novamente.

---

## Roteiro das Fases do Trabalho

### Parte 1: LF1 — Introdução ao Paradigma Funcional

- **Objetivo**: Adaptar o interpretador da linguagem LI2 para suportar construção funcional.
- **Sintaxe Abstrata**: Definida em `AbsLF.hs`.
- **Tarefas**:
  1. Estudar a estrutura de sintaxe abstrata.
  2. Implementar/corrigir as trechos marcados com `TODO` e as instruções `@dica` em `Interpreter.hs`.
  3. Validar a execução com os programas no diretório `examples/`.

### Parte 2: LF2 — Checagem de Tipos e Otimizações

- **Objetivo**: Adicionar um sistema de checagem estática de tipos e um módulo de otimização de código.
- **Tarefas**:
  1. Completar a lógica em `Typechecker.hs` (verificações de tipo estáticas).
  2. Implementar reescritas de árvore de sintaxe em `Optimizer.hs`.
  3. Atualizar a semântica em `Interpreter.hs` (reaproveitar o código da LF1, ajustando as funções `getName`, `getParams` e `getExp`).

### Parte 3: LF3 — Funções como Valores de Primeira Classe

- **Objetivo**: Evoluir a linguagem para aceitar:
  - Expressões Lambda.
  - Aplicação Parcial.
  - Composição de Funções.

- **Tarefas**:
  1. Consultar a sintaxe concreta `LF3.cf` (identificar alterações marcadas como `NOVO`).
  2. Gerar o lexer, parser e sintaxe abstrata (`AbsLF.hs`) executando `bnfc -m LF3.cf` e `make`.
  3. Completar os pontos `TODO` nos arquivos `Typechecker.hs`, `Optimizer.hs` e `Interpreter.hs`.
  4. Executar os exemplos fornecidos e criar novos casos de teste em `examples/` cobrindo as novas funcionalidades.

---

## Observações Gerais

- **Preservação de Comentários**: Não apague os comentários `TODO` no código original; eles serão utilizados durante a arguição do trabalho.
- **Submissão**: O trabalho pode ser realizado individualmente ou em dupla. Ambas as pessoas da dupla devem dominar integralmente o código entregue.
