SRCS = getname.s
BINS = $(SRCS:.s=.prg)
PDFDOCS = $(SRCS:.s=.pdf)

ASM = 64tass
A2PS = a2ps
PS2PDF = ps2pdf

%.pdf: %.s
	$(A2PS) -E64tass --borders=no -B -R --columns=1 -o- getname.s | $(PS2PDF) - getname.pdf

%.prg: %.s
	$(ASM) -Wall --cbm-prg \
		--vice-labels -l $@.l \
		-L $@.lst \
		-o $@ -a $<

.PHONY: all
all: $(BINS)

.PHONY: pdf
pdf: $(PDFDOCS)

clean:
	rm -f $(BINS) $(PDFDOCS)
