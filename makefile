SHELL := /bin/bash


INPUT_DIR := ./inputs
UNFOLDED_DIR := ./unfolded
GC_CONTENT_DIR := ./gc-content
FIND_ORFS_DIR := ./find-orfs
IMG_DIR := ./images
REPORT_DIR := ./reports
SLIDES_DIR := ./slides
TEXT_PARTS_DIR := ./text-parts

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
	@pdflatex -interaction=nonstopmode -output-directory=$(REPORT_DIR) $(REPORT_DIR)/report.tex
	@bibtex $(REPORT_DIR)/report
	@pdflatex -interaction=nonstopmode -output-directory=$(REPORT_DIR) $(REPORT_DIR)/report.tex
	@pdflatex -interaction=nonstopmode -output-directory=$(REPORT_DIR) $(REPORT_DIR)/report.tex
	@rm -f $(REPORT_DIR)/*.aux $(REPORT_DIR)/*.log $(REPORT_DIR)/*.toc $(REPORT_DIR)/*.nav $(REPORT_DIR)/*.out $(REPORT_DIR)/*.snm $(REPORT_DIR)/*.bbl $(REPORT_DIR)/*.blg



$(SLIDES_DIR)/slides.pdf:
	@mkdir -p $(SLIDES_DIR)
	@pdflatex -interaction=nonstopmode -output-directory=$(SLIDES_DIR) $(SLIDES_DIR)/slides.tex
	@bibtex $(SLIDES_DIR)/slides
	@pdflatex -interaction=nonstopmode -output-directory=$(SLIDES_DIR) $(SLIDES_DIR)/slides.tex
	@pdflatex -interaction=nonstopmode -output-directory=$(SLIDES_DIR) $(SLIDES_DIR)/slides.tex
	@rm -f $(SLIDES_DIR)/*.aux $(SLIDES_DIR)/*.log $(SLIDES_DIR)/*.toc $(SLIDES_DIR)/*.nav $(SLIDES_DIR)/*.out $(SLIDES_DIR)/*.snm $(SLIDES_DIR)/*.bbl $(SLIDES_DIR)/*.blg



clean:
	@rm -rf $(UNFOLDED_DIR) $(GC_CONTENT_DIR) $(FIND_ORFS_DIR) $(IMG_DIR) $(REPORT_DIR)/*.pdf $(SLIDES_DIR)/*.pdf


