QUESTIONS := $(wildcard math-*)

# 'subdirs' is the default target. And we want 
# each of its prerequisites - also phony targets - to execute
.PHONY : subdirs $(QUESTIONS)
subdirs : $(QUESTIONS) 
	@echo "[subdirs] = $(QUESTIONS)"

$(QUESTIONS) :
	$(MAKE) -C $@

