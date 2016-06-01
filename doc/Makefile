.PHONY: all

all: doc.pdf

%.pdf : %.ps
	ps2pdf $< $@
#	pstopdf -i $< -o $@

%.ps : %.ms
	groff -et -ms $< > $@
