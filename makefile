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
ORF_FILES := $(patsubst $(UNFOLDED_DIR)/%.fsa, $(FIND_ORFS_DIR)/%.fsa, $(UNFOLDED_FILES))
GC_FILES := $(patsubst $(FIND_ORFS_DIR)/%.fsa, $(GC_CONTENT_DIR)/%.fsa, $(ORF_FILES))
PLOTS := $(patsubst $(GC_CONTENT_DIR)/%.fsa, $(IMG_DIR)/%_boxplot.png, $(GC_FILES))

.PRECIOUS: $(UNFOLDED_DIR)/%.fsa $(GC_CONTENT_DIR)/%.fsa $(FIND_ORFS_DIR)/%.fsa

all: $(PLOTS) $(REPORT_DIR)/report.pdf $(SLIDES_DIR)/slides.pdf

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

$(REPORT_DIR)/report.pdf:
	@mkdir -p $(REPORT_DIR)
	@echo "\\documentclass{article}\\begin{document}Blank Report\\end{document}" > $(REPORT_DIR)/report.tex
	@pdflatex -interaction=nonstopmode -output-directory=$(REPORT_DIR) $(REPORT_DIR)/report.tex
	@rm -f $(REPORT_DIR)/*.aux $(REPORT_DIR)/*.log $(REPORT_DIR)/*.toc $(REPORT_DIR)/*.nav $(REPORT_DIR)/*.out $(REPORT_DIR)/*.snm

$(SLIDES_DIR)/slides.pdf:
	@mkdir -p $(SLIDES_DIR)
	@echo "\\documentclass{beamer}\\begin{document}\\begin{frame}{Title}\\end{frame}\\end{document}" > $(SLIDES_DIR)/slides.tex
	@pdflatex -interaction=nonstopmode -output-directory=$(SLIDES_DIR) $(SLIDES_DIR)/slides.tex
	@rm -f $(SLIDES_DIR)/*.aux $(SLIDES_DIR)/*.log $(SLIDES_DIR)/*.toc $(SLIDES_DIR)/*.nav $(SLIDES_DIR)/*.out $(SLIDES_DIR)/*.snm

clean:
	@rm -rf $(UNFOLDED_DIR) $(GC_CONTENT_DIR) $(FIND_ORFS_DIR) $(IMG_DIR) $(REPORT_DIR)/*.pdf $(SLIDES_DIR)/*.pdf


