.PHONY: index clean all

OUTPUT := ./out
SOURCE := ./src
GENERATED := ./gen

SOURCE_MD := $(wildcard $(SOURCE)/*.md)
SOURCE_MD -= footer.md navbar.md
OUTPUT_HTML := $(patsubst %.md,%.html,$(subst $(SOURCE),$(OUTPUT),$(SOURCE_MD)))

PANDOC = pandoc -s -H $(SOURCE)/header.html $(SOURCE)/navbar.md $< $(SOURCE)/footer.md -o $@

COMMON = $(SOURCE)/header.html $(SOURCE)/footer.md

COPYDIRS := img css

$(OUTPUT) $(GENERATED):
	mkdir -p $@

define COPYDIR

$(OUTPUT)/$(1): $(SOURCE)/$(1)
	mkdir -p $(OUTPUT)
	ln -snf $$(realpath $$<) $$@
	@# Use -n to avoid putting symlink into symlinked directory
	@sync

endef

$(foreach copydir,$(COPYDIRS),$(eval $(call COPYDIR,$(copydir))))

$(GENERATED)/officer_usernames.txt: | $(GENERATED)
	getent group officers | awk '{ split($$1,a,":"); split(a[4],b,","); {for(i in b) print(b[i])}}' > $@

$(GENERATED)/officer_realnames.txt: $(GENERATED)/officer_usernames.txt
	cat $< | xargs getent passwd | awk '{ split($$_,a,":"); split(a[5],b,","); print(b[1])}' > $@

$(GENERATED)/officers.txt: $(GENERATED)/officer_usernames.txt
	cat $< | xargs id -nG > $@

index.html: README.md $(COMMON)
	$(PANDOC)

$(SOURCE)/header.html: $(SOURCE)/css/base.css
	touch $@

all: index.html $(OUTPUT_HTML) $(foreach c,$(COPYDIRS),$(OUTPUT)/$(c)) \
	$(GENERATED)/officer_usernames.txt

clean:
	rm -rf $(OUTPUT) $(GENERATED) index.html
	@sync
