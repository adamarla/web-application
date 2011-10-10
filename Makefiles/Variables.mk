# Variable definitions for various folders 

QBANK_HOME = $(VTA_ROOT)
QBANK_MATHS = $(QBANK_HOME)/maths
QBANK_PHYSICS = $(QBANK_HOME)/physics
QBANK_CHEMISTRY = $(QBANK_HOME)/chemistry
QBANK_COMMON = $(QBANK_HOME)/common

# Commands 
DVIPS = dvips -q 
LATEX = latex
PS2PDF = ps2pdf

# Variable defs for various files types within a question folder
PLOT_FILES = $(wildcard *.gnuplot)  
PLOT_TABLES = 

# For consistency's sake, name the .tex for question as question.tex 
# If, however, you decide to name it something else, then make sure
# to modify the local Makefile accordingly
JUST_QUES_TEX = question.tex 

# These next should not need to change. They represent files
# that are stitched together in the following order : 
# 	1. $(PREAMBLE_TEX) 
#	2. [optional] $(PRINTANSWERS_TEX) 
#	3. $(DOC_BEGIN_TEX) 
#	4. $(JUST_QUES_TEX) 
#	5. $(DOC_END_TEX)

PREAMBLE_TEX = $(QBANK_COMMON)/preamble.tex 
DOC_BEGIN_TEX = $(QBANK_COMMON)/doc_begin.tex 
DOC_END_TEX = $(QBANK_COMMON)/doc_end.tex 
PRINTANSWERS_TEX = $(QBANK_COMMON)/printanswers.tex

STITCH_WO_ANSWERS = $(PREAMBLE_TEX) $(DOC_BEGIN_TEX) $(JUST_QUES_TEX) $(DOC_END_TEX)
STITCH_WITH_ANSWERS = $(PREAMBLE_TEX) $(PRINTANSWERS_TEX) $(DOC_BEGIN_TEX) $(JUST_QUES_TEX) $(DOC_END_TEX)

FOLDER_NAME := $(notdir $(CURDIR))
# These next files are generated post stitching 
QUESTION_TEX = $(FOLDER_NAME).tex 
ANSWER_TEX = $(FOLDER_NAME)-answer.tex

QUESTION_DVI = $(FOLDER_NAME).dvi
ANSWER_DVI = $(FOLDER_NAME)-answer.dvi

QUESTION_PS = $(FOLDER_NAME).ps
ANSWER_PS = $(FOLDER_NAME)-answer.ps

QUESTION_PDF = $(FOLDER_NAME).pdf
ANSWER_PDF = $(FOLDER_NAME)-answer.pdf

QUESTION_JPEG = $(FOLDER_NAME).jpeg
ANSWER_JPEG = $(FOLDER_NAME)-answer.jpeg

# Variable defs for files in other folders 
