.PHONY: index clean all

OUTPUT := ./out
SOURCE := ./src

SOURCE_MD := $(wildcard $(SOURCE)/*.md)
OUTPUT_HTML := $(patsubst %.md,%.html,$(subst $(SOURCE),$(OUTPUT),$(SOURCE_MD)))

COPYDIRS := img css

all: index.html $(OUTPUT_HTML) $(foreach c,$(COPYDIRS),$(OUTPUT)/$(c))

index.html: README.md
	pandoc -o $@ README.md

$(OUTPUT):
	mkdir $(OUTPUT)

# Just copy the directories over ... maybe I should symlink these :thinking:
define COPYDIR

$(OUTPUT)/$(1): $(SOURCE)/$(1) $(OUTPUT)
	cp -rf $$< $$@
	@sync

endef

$(foreach copydir,$(COPYDIRS),$(eval $(call COPYDIR,$(copydir))))

$(OUTPUT)/%.html: $(SOURCE)/%.md $(OUTPUT) $(SOURCE)/header.html $(OUTPUT)/css
	pandoc -s -o $@ $< -H $(SOURCE)/header.html

clean:
	rm -rf $(OUTPUT)
	@sync
