# ---------------------------------------------------------------------------
# MoreSTLC -- front end (BNFC) + interpreter skeleton (Haskell)
#
#   make            build the interpreter        -> ./morestlc
#   make test       build and run the test suite
#   make clean      remove compiled objects
#   make distclean  also remove everything BNFC generated
#
# The three tools in the pipeline can be overridden, e.g.
#   make GHC=ghc-9.4.7
# ---------------------------------------------------------------------------

BNFC  ?= bnfc
ALEX  ?= alex
HAPPY ?= happy
GHC   ?= ghc

# --- Windows: put a POSIX toolset on the PATH -------------------------------
ifeq ($(OS),Windows_NT)
USING_CMD := $(findstring $$OSTYPE,$(shell echo $$OSTYPE))
ifneq ($(USING_CMD),)
GIT_USR_BIN ?= $(subst \cmd\git.exe,\usr\bin,$(shell where git 2>NUL))
export PATH := $(PATH);$(GIT_USR_BIN)
ifneq ($(shell if exist "$(GIT_USR_BIN)\sh.exe" echo yes),yes)
$(warning no POSIX shell found: install Git for Windows, or set GIT_USR_BIN to)
$(warning the usr\bin of an existing install, or run make from Git Bash)
endif
endif
endif

LANGUAGE = MoreSTLC
GRAMMAR  = $(LANGUAGE).cf
GENDIR   = gen
SRCDIR   = src
BUILDDIR = build
EXE      = morestlc

HS_SOURCES = $(wildcard $(SRCDIR)/*.hs)
LEXER      = $(GENDIR)/Lex$(LANGUAGE).hs
PARSER     = $(GENDIR)/Par$(LANGUAGE).hs

.PHONY: all test clean distclean

all: $(EXE)

# --- 1. BNFC: one grammar -> abstract syntax + lexer + parser + printer ------
$(GENDIR)/bnfc.stamp: $(GRAMMAR)
	mkdir -p $(GENDIR)
	$(BNFC) --haskell -o $(GENDIR) $(GRAMMAR)
	touch $@

# --- 2. Alex and Happy: the specifications -> Haskell ------------------------
$(LEXER): $(GENDIR)/bnfc.stamp
	$(ALEX) -g $(GENDIR)/Lex$(LANGUAGE).x -o $@

$(PARSER): $(GENDIR)/bnfc.stamp
	$(HAPPY) -gca $(GENDIR)/Par$(LANGUAGE).y -o $@

# --- 3. GHC: generated front end + hand written back end -> interpreter ------
$(EXE): $(LEXER) $(PARSER) $(HS_SOURCES)
	$(GHC) --make -i$(SRCDIR) -i$(GENDIR) -outputdir $(BUILDDIR) -o $(EXE) $(SRCDIR)/Main.hs

# --- 4. Testes baseados nas funcionalidades da Main.hs -----------------------
test: $(EXE)
	@echo "=== 1/3: Sanity Check (Parser Roundtrip) ==="
	./$(EXE) --roundtrip examples/*.mstlc
	@echo "\n=== 2/3: Executando cenários válidos ==="
	./$(EXE) --run examples/*.mstlc
	@echo "\n=== 3/3: Executando cenários inválidos (devem gerar type/parse error) ==="
	./$(EXE) examples/bad/*.mstlc || true

clean:
	rm -rf $(BUILDDIR) $(EXE) $(EXE).exe

distclean: clean
	rm -rf $(GENDIR)