.PHONY: all

all: doc.pdf

%.pdf : %.ms
	groff -ms -e -t $< | pstopdf -i -o $@
