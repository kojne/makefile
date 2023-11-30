SHELL := /bin/bash 

GENOME_DIR := /home/ignas/Desktop/Makefile2/unfolded
IMG_DIR := /home/ignas/Desktop/Makefile2/images
REPORT_DIR := /home/ignas/Desktop/Makefile2/reports
SLIDES_DIR := /home/ignas/Desktop/Makefile2/slides
TEMPLATES_DIR := /home/ignas/Desktop/Makefile2/templates

FILES := $(wildcard $(GENOME_DIR)/*.fsa)
PLOTS := $(patsubst $(GENOME_DIR)/%.fsa,$(IMG_DIR)/%_boxplot.png,$(FILES))
REPORTS := $(patsubst $(GENOME_DIR)/%.fsa,$(REPORT_DIR)/%.pdf,$(FILES))
SLIDES := $(patsubst $(GENOME_DIR)/%.fsa,$(SLIDES_DIR)/%.pdf,$(FILES))

all: reports slides

$(IMG_DIR)/%_boxplot.png: $(GENOME_DIR)/%.fsa
	@mkdir -p $(IMG_DIR)
	/home/ignas/Desktop/Makefile2/create_boxplot.py $< $@
	sleep 2

$(REPORT_DIR)/%.tex: $(IMG_DIR)/%_boxplot.png
	@mkdir -p $(REPORT_DIR)
	sed 's|PLACEHOLDER_FOR_IMAGE|$<|' $(TEMPLATES_DIR)/report.tex > $@
	sleep 2
$(SLIDES_DIR)/%.tex: $(IMG_DIR)/%_boxplot.png
	@mkdir -p $(SLIDES_DIR)
	sed 's|PLACEHOLDER_FOR_IMAGE|$<|' $(TEMPLATES_DIR)/slides.tex > $@
	sleep 2
$(REPORT_DIR)/%.pdf: $(REPORT_DIR)/%.tex
	pdflatex -interaction=nonstopmode -output-directory=$(REPORT_DIR) $<

$(SLIDES_DIR)/%.pdf: $(SLIDES_DIR)/%.tex
	pdflatex -output-directory=$(SLIDES_DIR) $<

reports: $(REPORTS)

slides: $(SLIDES)

clean:
	
	rm -f $(REPORT_DIR)/*.aux $(REPORT_DIR)/*.log 
	rm -f $(SLIDES_DIR)/*.aux $(SLIDES_DIR)/*.log $(SLIDES_DIR)/*.toc $(SLIDES_DIR)/*.snm $(SLIDES_DIR)/*.out $(SLIDES_DIR)/*.nav

.PHONY: all clean reports slides


