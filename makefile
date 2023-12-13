SHELL := /bin/bash

INPUT_DIR := ./inputs
UNFOLDED_DIR := ./unfolded
GC_CONTENT_DIR := ./gc-content
FIND_ORFS_DIR := ./find-orfs
IMG_DIR := ./images
REPORT_DIR := ./reports
SLIDES_DIR := ./slides

INPUT_FILES := $(wildcard $(INPUT_DIR)/*.fsa)
UNFOLDED_FILES := $(patsubst $(INPUT_DIR)/%.fsa, $(UNFOLDED_DIR)/%.fsa, $(INPUT_FILES))
GC_FILES := $(patsubst $(UNFOLDED_DIR)/%.fsa, $(GC_CONTENT_DIR)/%.fsa, $(UNFOLDED_FILES))
ORF_FILES := $(patsubst $(UNFOLDED_DIR)/%.fsa, $(FIND_ORFS_DIR)/%.fsa, $(UNFOLDED_FILES))
PLOTS := $(patsubst $(GC_CONTENT_DIR)/%.fsa, $(IMG_DIR)/%_boxplot.png, $(GC_FILES))
REPORTS := $(patsubst $(GC_CONTENT_DIR)/%.fsa, $(REPORT_DIR)/%.pdf, $(GC_FILES))
SLIDES := $(patsubst $(GC_CONTENT_DIR)/%.fsa, $(SLIDES_DIR)/%.pdf, $(GC_FILES))

.PRECIOUS: $(UNFOLDED_DIR)/%.fsa $(GC_CONTENT_DIR)/%.fsa $(FIND_ORFS_DIR)/%.fsa

all: $(PLOTS) $(REPORTS) $(SLIDES) $(ORF_FILES)

$(UNFOLDED_DIR)/%.fsa: $(INPUT_DIR)/%.fsa
	@echo "Running fasta-unfold on $<"
	@mkdir -p $(UNFOLDED_DIR)
	./fasta-unfold.sh $< > $@

$(FIND_ORFS_DIR)/%.fsa: $(UNFOLDED_DIR)/%.fsa
	@echo "Running find-orfs on $<"
	@mkdir -p $(FIND_ORFS_DIR)
	./find-orfs-j.sh $< > $@

$(GC_CONTENT_DIR)/%.fsa: $(FIND_ORFS_DIR)/%.fsa
	@echo "Running gc-content on $<"
	@mkdir -p $(GC_CONTENT_DIR)
	./gc-content.sh $< | sed 's/,/./g' > $@

$(IMG_DIR)/%_boxplot.png: $(GC_CONTENT_DIR)/%.fsa
	@mkdir -p $(IMG_DIR)
	./create_boxplot.py $<

$(REPORT_DIR)/%.pdf:
	@mkdir -p $(REPORT_DIR)
	@echo "\\documentclass{article}\\begin{document}Blank Report\\end{document}" > $(REPORT_DIR)/temp.tex
	@pdflatex -interaction=nonstopmode -output-directory=$(REPORT_DIR) $(REPORT_DIR)/temp.tex
	@-mv $(REPORT_DIR)/temp.pdf $@
	@-rm -f $(REPORT_DIR)/temp.*

$(SLIDES_DIR)/%.pdf:
	@mkdir -p $(SLIDES_DIR)
	@echo "\\documentclass{beamer}\\begin{document}\\begin{frame}{Title}\\end{frame}\\end{document}" > $(SLIDES_DIR)/temp.tex
	@pdflatex -interaction=nonstopmode -output-directory=$(SLIDES_DIR) $(SLIDES_DIR)/temp.tex
	@-mv $(SLIDES_DIR)/temp.pdf $@
	@-rm -f $(SLIDES_DIR)/temp.*

print:
	@echo "INPUT_FILES: $(INPUT_FILES)"
	@echo "UNFOLDED_FILES: $(UNFOLDED_FILES)"
	@echo "GC_FILES: $(GC_FILES)"
	@echo "ORF_FILES: $(ORF_FILES)"
	@echo "PLOTS: $(PLOTS)"
	@echo "REPORTS: $(REPORTS)"
	@echo "SLIDES: $(SLIDES)"

