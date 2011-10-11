
# Commands we need for TeX -> PS -> PDF conversion

DVIPS = dvips -q
DVIPDF = dvipdf -q
LATEX = latex
PS2PDF = ps2pdf

# Shell commands of the type 'cat a/{b,c}.tex > X' are not supported
# in the default make shell - sh. Hence, change the value of SHELL variable 
# to what is now more common on modern Linux systems - bash 

SHELL := /bin/bash

# Some useful variable definitions

QBANK_HOME := $(VTA_ROOT)
QBANK_COMMON := $(VTA_ROOT)/common
Q_SPACE_LIST := $(strip $(QLIST))

# Spaces and commas require special handling when using $(subst ...)
# The key is to define variables for space and comma and use these 
# in calls to $(subst ...) 

comma := ,
empty :=
space := $(empty) $(empty)

# There should be no space at the end. Of what? $(Q_SPACE_LIST), you say?
# Wrong !! At the end of this next variable declaration

Q_COMMA_LIST := $(subst $(space),$(comma),$(Q_SPACE_LIST))

# Variables for output file names MINUS the extensions {.tex, .dvi etc} !!!! 
# As above, make sure there is no space at the end of variable declaration 

QFILE := Q-$(shell date +%b-%d-%Y)
AFILE := A-$(shell date +%b-%d-%Y)

QPATH := $(SESSION_ID)/$(QFILE)
APATH := $(SESSION_ID)/$(AFILE)

# List of all sessions in the staging area 
SESSIONS = $(wildcard sessions-*)

.PHONY : $(SESSION_ID) pull $(Q_SPACE_LIST) open_shells close_shells clean 

$(SESSION_ID) : pull open_shells add_pearls close_shells compile ;

open_shells : pull 
	@echo $(QPATH).tex
	@cat $(QBANK_COMMON)/{preamble,doc_begin}.tex >> $(QPATH).tex 
	@cat $(QBANK_COMMON)/{preamble,printanswers,doc_begin}.tex >> $(APATH).tex

add_pearls : open_shells 
	@cat $(QBANK_HOME)/{$(Q_COMMA_LIST)}/question.tex >> $(QPATH).tex 
	@cat $(QBANK_HOME)/{$(Q_COMMA_LIST)}/question.tex >> $(APATH).tex

close_shells : add_pearls 
	@cat $(QBANK_COMMON)/doc_end.tex >> $(QPATH).tex
	@cat $(QBANK_COMMON)/doc_end.tex >> $(APATH).tex

compile : close_shells
	@cd $(SESSION_ID) && $(LATEX) $(QFILE).tex && $(DVIPS) $(QFILE).dvi && $(PS2PDF) $(QFILE).ps
	@cd $(SESSION_ID) && $(LATEX) $(AFILE).tex && $(DVIPS) $(AFILE).dvi && $(PS2PDF) $(AFILE).ps

pull : clean $(Q_SPACE_LIST) ; 

$(Q_SPACE_LIST) : 
	@$(MAKE) plot -C $(VTA_ROOT)/$@
	@- cp $(VTA_ROOT)/$@/*.table $(SESSION_ID)
	
clean : 
	-@cd $(SESSION_ID) && rm -f $(QFILE).{tex,aux,dvi,ps,pdf,out,log}
	-@cd $(SESSION_ID) && rm -f $(AFILE).{tex,aux,dvi,ps,pdf,out,log}
