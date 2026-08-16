Notação:
"=>" edição de arquivo
"==>" execução de comando no prompt do sistema operacional


** Passos principais (requerido no curso, feito pelo aluno)

1) estudar a sintaxe abstrata, ou seja, o(s) tipo(s) algébrico(s) com a estrutura da linguagem 
  => arquivo "AbsLI.hs"

2) definir/editar o interpretador com base na sintaxe abstrata 
  => arquivo "Interpreter.hs"

3) compilar o driver (main) do interpretador 
  ==> ghc --make Interpret.hs

4) testar o executável com exemplos:
  ==> Interpret < examples\ex1.li3

** Passos preliminares (feito pelo professor)
-3) Definir/editar a sintaxe concreta (feito pelo professor)
  ==> arquivo LI2.cf

-2) Gerar os fontes do analisador sintático (parser) e léxico (lexer), assim como o Makefile usando o BNF Converter
  ==> bnfc  -m  LI2.cf

-1) Compilar os fontes do parser e lexer 
  ==> make

0) Definir o driver (main) do interpretador
  => arquivo "Interpret.hs"
   

---------------------

Observações

-> O arquivo "AbsLI.hs" é gerado a partir do arquivo "LI2.cf". Assim, caso o último seja editado, o primeiro terá que ser gerado
novamente. Para fazer alterações desejadas no arquivo "AbsLI.hs", o mesmo não deve ser editado diretamente: 
deve-se alterar o "LI2.cf" e gerar o "AbsLI.hs" novamente usando o BNF Converter.

-> Para a execução dos "Passos Principais", é necessário ter a plataforma Haskell instalada.
https://www.haskell.org/platform/

-> Para a execução dos "Passos Preliminares", é necessário:
1) instalar o BNF Converter
http://bnfc.digitalgrammars.com/

2) Caso o sistema operacional não tenha nativamente o "make" (p.ex. Windows),
é necessário instalá-lo
http://www.steve.org.uk/Software/make/   