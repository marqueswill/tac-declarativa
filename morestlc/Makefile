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
# The recipes below are ordinary Unix commands (mkdir -p, touch, rm -rf, and
# sh ./test.sh).  Started from Git Bash they all resolve and there is nothing
# to do here; started from cmd.exe or PowerShell not one of them is on the
# PATH, and make dies with
#     process_begin: CreateProcess(NULL, sh ./test.sh, ...) failed.
# Git for Windows ships a complete set in <git>\usr\bin, so add that directory,
# located from wherever git.exe itself is.  Override if the guess is wrong:
#     make test GIT_USR_BIN="C:\Program Files\Git\usr\bin"
ifeq ($(OS),Windows_NT)
# cmd.exe echoes $OSTYPE back unchanged, a POSIX shell expands it: a non-empty
# result means make is running the recipes through cmd.exe and needs help.
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
# Happy is silent when the grammar is unambiguous.  Any "shift/reduce" or
# "reduce/reduce" message here means the grammar has to be fixed.
$(LEXER): $(GENDIR)/bnfc.stamp
	$(ALEX) -g $(GENDIR)/Lex$(LANGUAGE).x -o $@

$(PARSER): $(GENDIR)/bnfc.stamp
	$(HAPPY) -gca $(GENDIR)/Par$(LANGUAGE).y -o $@

# --- 3. GHC: generated front end + hand written back end -> interpreter ------
$(EXE): $(LEXER) $(PARSER) $(HS_SOURCES)
	$(GHC) --make -i$(SRCDIR) -i$(GENDIR) -outputdir $(BUILDDIR) -o $(EXE) $(SRCDIR)/Main.hs

test: $(EXE)
	@for file in examples/*.mstlc; do \
		echo "=> Executando $$file"; \
		./$(EXE) "$$file"; \
	done

clean:
	rm -rf $(BUILDDIR) $(EXE) $(EXE).exe

distclean: clean
	rm -rf $(GENDIR)
