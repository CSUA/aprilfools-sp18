.PHONY: index

index: index.html

index.html: README.md
	pandoc -o $@ README.md


