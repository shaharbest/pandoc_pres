TOPICS_DIR = topics
OUT_DIR = dist
PDF_DIR = pdfs
WEB_DIR = webpages
IMG_DIR = img
CONFIG_DIR = config

MD_FILE = content.md
HEADER_FILE = header.tex
DEFAULT_FILE = default.yaml

PDF_CONFIG = $(CONFIG_DIR)/pdf
DEFAULT_PDF = $(PDF_CONFIG)/$(DEFAULT_FILE)
HEADER_PDF = $(PDF_CONFIG)/$(HEADER_FILE)

WEB_CONFIG = $(CONFIG_DIR)/webpage
DEFAULT_WEB_DOC = $(WEB_CONFIG)/doc/$(DEFAULT_FILE)
DEFAULT_WEB_SLIDY = $(WEB_CONFIG)/slidy/$(DEFAULT_FILE)

PRES_DIRS := $(wildcard $(TOPICS_DIR)/*/*)
PDF_FILES := $(patsubst $(TOPICS_DIR)/%,$(OUT_DIR)/$(PDF_DIR)/%.pdf,$(PRES_DIRS))
HTML_FILES := $(patsubst $(TOPICS_DIR)/%,$(OUT_DIR)/$(WEB_DIR)/%.html,$(PRES_DIRS))

GLOBAL_IMG_DIR = $(TOPICS_DIR)/$*/$(IMG_DIR)

HEADER_INCLUDE = "\graphicspath{{$(IMG_DIR)}{$(GLOBAL_IMG_DIR)}} \
		 $(shell cat $(HEADER_PDF))"

RESOURCE_PATH = $(GLOBAL_IMG_DIR):$(IMG_DIR)
RESOURCE_OPT = --resource-path=$(RESOURCE_PATH)

COMMON_DEPS = $(TOPICS_DIR)/%/$(MD_FILE) \
	      $(wildcard $(TOPICS_DIR)/%/$(IMG_DIR)/*) \
	      $(wildcard $(IMG_DIR)/*)

PDF_DEPS = $(COMMON_DEPS) $(DEFAULT_PDF) $(HEADER_PDF)

WEB_DEPS = $(COMMON_DEPS) \
	       $(shell find $(WEB_CONFIG)/**/* -type f)

PRES_OPTS = \
	    	$(RESOURCE_OPT) \
		-d $(DEFAULT_PDF) \
		-H <(echo $(HEADER_INCLUDE))

WEB_OPTS = $(RESOURCE_OPT) --embed-resources

WEB_SLIDY_OPTS = \
		$(WEB_OPTS) \
		-d $(DEFAULT_WEB_SLIDY) \
	        -t slidy

WEB_DOC_OPTS = $(WEB_OPTS) -d $(DEFAULT_WEB_DOC)

all: $(PDF_FILES) $(HTML_FILES)

$(OUT_DIR)/$(PDF_DIR)/%.pdf: $(PDF_DEPS)
	@mkdir -p $(dir $@)
	pandoc -o $@ $< $(PRES_OPTS)

$(OUT_DIR)/$(WEB_DIR)/%.html: $(WEB_DEPS)
	@mkdir -p $(dir $@)
	pandoc -o $@ $< $(WEB_SLIDY_OPTS)

# pandoc -o $@ $< $(WEB_DOC_OPTS)

clean:
	rm -rf $(OUT_DIR)

server:
	live-server $(OUT_DIR)/$(WEB_DIR)

rebuild: clean all

.PHONY: rebuild dist
