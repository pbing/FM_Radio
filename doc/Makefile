.PHONY: all

all: doc.pdf

%.pdf : %.ps
	ps2pdf $< $@
#	pstopdf $< -o $@

%.ps : %.ms
	groff -et -ms $< > $@
