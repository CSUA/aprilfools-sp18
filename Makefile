.PHONY: index clean all

OUTPUT := ./out
SOURCE := ./src
GENERATED := ./gen

PAGES := index politburo officers join constitution
SOURCE_MD := $(patsubst %,$(SOURCE)/%.md,$(PAGES))
OUTPUT_HTML := $(patsubst %.md,%.html,$(subst $(SOURCE),$(OUTPUT),$(SOURCE_MD)))

PANDOC = pandoc -s -H $(SOURCE)/header.html $(SOURCE)/navbar.md $< $(SOURCE)/footer.md -o $@

COMMON := $(SOURCE)/header.html $(SOURCE)/footer.md $(SOURCE)/navbar.md

COPYDIRS := img css

all: index.html $(OUTPUT_HTML) $(foreach c,$(COPYDIRS),$(OUTPUT)/$(c)) \
	$(GENERATED)/officer_usernames.txt $(GENERATED)/officers.yml

# Generate directories if they dont exist
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

$(GENERATED)/officers.yml: $(GENERATED)/officer_usernames.txt
	cat $< | xargs getent passwd | awk '{ split($$_,a,":"); \
		split(a[5],b,","); \
		split(b[1],c," "); \
		print("- first: "c[1]); \
		print("  last: "c[2]); \
		print("  username: "a[1])}' \
		> $@ || rm $@

$(GENERATED)/officer_groups.txt: $(GENERATED)/officer_usernames.txt
	cat $< | xargs id -nG > $@

define SIMPLE_PANDOC

$(1): $(2) $(COMMON)
	$(PANDOC)

endef

index.html: README.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/index.html: $(SOURCE)/index.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/politburo.html: $(SOURCE)/politburo.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/officers.html: $(SOURCE)/officers.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/join.html: $(SOURCE)/join.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/constitution.html: $(SOURCE)/constitution.md $(COMMON)
	$(PANDOC)

$(SOURCE)/header.html: $(SOURCE)/css/base.css
	touch $@

clean:
	rm -rf $(OUTPUT) $(GENERATED) index.html
	@sync
