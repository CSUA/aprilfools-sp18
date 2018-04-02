# Makefile: the magical sauce that powers this website
# Read about GNU make if you want to figure out how this works exactly
.PHONY: index clean all

OUTPUT := ./out
SOURCE := ./src
GENERATED := ./gen

# $(PAGES) is only used for the 'all' target for now
PAGES := index politburo officers join constitution tutoring computing-resources events hackathon industry readme

# Unused for now
SOURCE_MD := $(patsubst %,$(SOURCE)/%.md,$(PAGES))
OUTPUT_HTML := $(patsubst %.md,%.html,$(subst $(SOURCE),$(OUTPUT),$(SOURCE_MD)))

PANDOC = pandoc -s -H $(SOURCE)/header.html $(SOURCE)/navbar.md $< $(SOURCE)/footer.md -o $@

COMMON := $(SOURCE)/header.html $(SOURCE)/footer.md $(SOURCE)/navbar.md

COPYDIRS := img css

all: index.html $(OUTPUT_HTML) $(foreach c,$(COPYDIRS),$(OUTPUT)/$(c)) \
	$(GENERATED)/officer_usernames.txt $(GENERATED)/officers.yml

# Generate these directories if they dont exist since make clean removes them
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

##### Targets for website files ###############################################

$(GENERATED)/officer_usernames.txt: | $(GENERATED)
	getent group officers | awk '{ split($$1,a,":"); split(a[4],b,","); {for(i in b) print(b[i])}}' > $@

$(GENERATED)/officers.yml: $(GENERATED)/officer_usernames.txt
	echo "---" > $@
	echo "officers:" >> $@
	cat $< | sort | xargs getent passwd | awk '{ split($$_,a,":"); \
		split(a[5],b,","); \
		split(b[1],c," "); \
		print("- first: "c[1]); \
		print("  last: "c[2]); \
		print("  username: "a[1])}' \
		>> $@ || rm $@
	echo "---" >> $@

$(GENERATED)/officer_groups.txt: $(GENERATED)/officer_usernames.txt
	cat $< | xargs id -nG > $@

define SIMPLE_PANDOC

$(1): $(2) $(COMMON)
	$(PANDOC)

endef

index.html: README.md $(common)
	$(pandoc)

$(OUTPUT)/readme.html: README.md $(common)
	$(PANDOC)


# TODO: join all the simple page targets using a define block.

$(OUTPUT)/index.html: $(SOURCE)/index.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/politburo.html: $(SOURCE)/politburo.md $(COMMON)
	$(PANDOC)

$(GENERATED)/officers.md: $(SOURCE)/officers.md $(GENERATED)/officers.yml
	pandoc --template $< $(GENERATED)/officers.yml -o $@

$(OUTPUT)/officers.html: $(GENERATED)/officers.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/join.html: $(SOURCE)/join.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/constitution.html: $(SOURCE)/constitution.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/tutoring.html: $(SOURCE)/tutoring.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/computing-resources.html: $(SOURCE)/computing-resources.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/events.html: $(SOURCE)/events.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/hackathon.html: $(SOURCE)/hackathon.md $(COMMON)
	$(PANDOC)

$(OUTPUT)/industry.html: $(SOURCE)/industry.md $(COMMON)
	$(PANDOC)

clean:
	rm -rf $(OUTPUT) $(GENERATED) index.html
	@sync
