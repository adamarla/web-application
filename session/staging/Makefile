
####################################################################
# Given that session folders are deleted once the question paper
# and answer key have been generated, it makes no sense to support 
# recursive build in the 'staging' area. The only sensible 
# use-case is building a specific session. Hence, we will enforce 
# the following invocation only : make session=<session_id>
#
# Moreover, I do not foresee this Makefile being invoked manually 
# from the command line ( other than for internal testing purposes ). 
# It will almost always be called from within some controller in
# the Rails application. If it is called manually, then make sure 
# that any .gnuplot and .sk files are copied first into the right 
# sessions folder ( tasks that the controller would do automatically )
####################################################################

# Commands we need for TeX -> PS -> PDF conversion

DVIPS := dvips -q
DVIPDF := dvipdf -q
LATEX := latex
PS2PDF := ps2pdf
RUBY := ruby

# Shell commands of the type 'cat a/{b,c}.tex > X' are not supported
# in the default make shell - sh. Hence, change the value of SHELL variable 
# to what is now more common on modern Linux systems - bash 

SHELL := /bin/bash

# Some useful variable definitions
TARGET_SESSION = $(subst session=,,$(strip $(session)))
DB_DIR := $(VTA_ROOT)/session/db-test/$(TARGET_SESSION)
STAGING_DIR := $(VTA_ROOT)/session/staging/$(TARGET_SESSION)
SCRIPTS_DIR := $(VTA_ROOT)/session/scripts

PLOT_FILES := $(wildcard $(STAGING_DIR)/*.gnuplot) 

#.PHONY : xml2tex db2xml 
.PHONY : plot dvi ps pdf $(PLOT_FILES)

pdf : ps 
	@cd $(STAGING_DIR) && $(PS2PDF) question_paper.ps && $(PS2PDF) answer_key.ps

ps : dvi
	@cd $(STAGING_DIR) && $(DVIPS) question_paper.dvi && $(DVIPS) answer_key.dvi

dvi : plot 
	@cd $(STAGING_DIR) && $(LATEX) question_paper.tex && $(LATEX) answer_key.tex

plot : $(PLOT_FILES) ;

$(PLOT_FILES) : 
	@cd $(STAGING_DIR) && gnuplot $@
