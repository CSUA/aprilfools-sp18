.PHONY: index clean all

OUTPUT := ./out
SOURCE := ./src
GENERATED := ./gen

SOURCE_MD := $(wildcard $(SOURCE)/*.md)
OUTPUT_HTML := $(patsubst %.md,%.html,$(subst $(SOURCE),$(OUTPUT),$(SOURCE_MD)))

COPYDIRS := img css

all: index.html $(OUTPUT_HTML) $(foreach c,$(COPYDIRS),$(OUTPUT)/$(c)) \
	$(GENERATED)/officer_usernames.txt

index.html: README.md
	pandoc -o $@ README.md

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

$(OUTPUT)/%.html: $(SOURCE)/%.md $(SOURCE)/header.html $(OUTPUT)/css | $(OUTPUT)
	pandoc -s $< $(SOURCE)/footer.md -o $@ -H $(SOURCE)/header.html

$(GENERATED)/officer_usernames.txt: | $(GENERATED)
	getent group officers | awk '{ split($$1,a,":"); split(a[4],b,","); {for(i in b) print(b[i])}}' > $@

$(GENERATED)/officer_realnames.txt: $(GENERATED)/officer_usernames.txt
	cat $< | xargs getent passwd | awk '{ split($$_,a,":"); split(a[5],b,","); print(b[1])}' > $@

$(GENERATED)/officers.txt: $(GENERATED)/officer_usernames.txt
	cat $< | xargs id -nG > $@
clean:
	rm -rf $(OUTPUT) $(GENERATED) index.html
	@sync
