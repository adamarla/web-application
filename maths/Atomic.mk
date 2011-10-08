include ../../Variables.mk

#.PHONY : plot prepare_tex prepare_tex_with_answers dvi ps jpeg 
.PHONY : plot prepare_tex prepare_tex_with_answers dvi ps

#$(QUESTION_JPEG) $(ANSWER_JPEG) jpeg : ps $(QUESTION_PS) $(ANSWER_PS) 
#	@echo "[$(PREFIX_STITCHED_FILES)] : PS -> JPEG" 
#	@convert -density 125 $(QUESTION_PS) $(QUESTION_JPEG)
#	@convert dvips -density 125 $(ANSWER_PS) $(ANSWER_JPEG)

$(QUESTION_PS) $(ANSWER_PS) ps : dvi $(QUESTION_DVI) $(ANSWER_DVI)
	@echo "[$(PREFIX_STITCHED_FILES)] : DVI -> PS"
	@dvips $(QUESTION_DVI) && dvips $(ANSWER_DVI)

$(QUESTION_DVI) $(ANSWER_DVI) dvi : prepare_tex prepare_tex_with_answers $(QUESTION_TEX) $(ANSWER_TEX)
	@echo "[$(PREFIX_STITCHED_FILES)] : TeX -> DVI" 
	@latex $(QUESTION_TEX) && latex $(ANSWER_TEX)

$(ANSWER_TEX) prepare_tex_with_answers : plot $(STITCH_WITH_ANSWERS) 
	@cat $(STITCH_WITH_ANSWERS) > $(ANSWER_TEX)

$(QUESTION_TEX) prepare_tex : plot $(STITCH_WO_ANSWERS) 
	@cat $(STITCH_WO_ANSWERS) > $(QUESTION_TEX)
	

plot : $(PLOT_FILES)
ifdef $(PLOT_FILES)
	@gnuplot $(PLOT_FILES)
endif 
	
