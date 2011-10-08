include ../../Variables.mk

#.PHONY : plot prepare_tex prepare_tex_with_answers dvi ps jpeg 
.PHONY : plot prepare_tex prepare_tex_with_answers dvi ps

#$(QUESTION_JPEG) $(ANSWER_JPEG) jpeg : ps $(QUESTION_PS) $(ANSWER_PS) 
#	@echo "[$(PREFIX_STITCHED_FILES)] : PS -> JPEG" 
#	@convert -density 125 $(QUESTION_PS) $(QUESTION_JPEG)
#	@convert dvips -density 125 $(ANSWER_PS) $(ANSWER_JPEG)

ps : dvi $(QUESTION_PS) $(ANSWER_PS) ;
$(QUESTION_PS) : $(QUESTION_DVI)
	@echo "[$(PREFIX_STITCHED_FILES)] : Question dvi -> ps"
	@dvips $(QUESTION_DVI) 
$(ANSWER_PS) : $(ANSWER_DVI)  
	@echo "[$(PREFIX_STITCHED_FILES)] : Answer dvi -> ps"
	dvips $(ANSWER_DVI)

dvi : prepare_tex prepare_tex_with_answers $(QUESTION_DVI) $(ANSWER_DVI) ;
$(QUESTION_DVI) : $(QUESTION_TEX)
	@echo "[$(PREFIX_STITCHED_FILES)] : Question TeX -> dvi" 
	@latex $(QUESTION_TEX)
$(ANSWER_DVI) : $(ANSWER_TEX)
	@echo "[$(PREFIX_STITCHED_FILES)] : Answer TeX -> dvi" 
	@latex $(ANSWER_TEX)


prepare_tex prepare_tex_with_answers : plot $(QUESTION_TEX) $(ANSWER_TEX) ;
$(QUESTION_TEX) : $(STITCH_WO_ANSWERS) 
	@echo "[$(PREFIX_STITCHED_FILES)] : Preparing Question Tex" 
	@cat $(STITCH_WO_ANSWERS) > $(QUESTION_TEX)
$(ANSWER_TEX) : $(STITCH_WITH_ANSWERS) 
	@echo "[$(PREFIX_STITCHED_FILES)] : Preparing Answer TeX" 
	@cat $(STITCH_WITH_ANSWERS) > $(ANSWER_TEX)

	

# [IMP] : Unlike normal C/C++ compilation where one .c/.cpp generates one .o, 
# one .gnuplot can lead to the creation of multiple .table files. Moreover, the names
# of the .table files are not derived from the .gnuplot but are specified -
# at the developers discretion - within the .gnuplot file itself. Hence, it is 
# not possible to define what the target files should be in the clause below
plot : $(PLOT_FILES)
ifdef $(PLOT_FILES)
	@echo "[$(PREFIX_STITCHED_FILES)] : Generating Plots" 
	@gnuplot $(PLOT_FILES)
else 
	@echo "[$(PREFIX_STITCHED_FILES)] : No Plots to Generate" 
endif 
	
