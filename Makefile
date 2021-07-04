SRCS = getname.s
BINS = $(SRCS:.s=.prg)
ASM = 64tass

%.prg: %.s
	$(ASM) -Wall --cbm-prg \
		--vice-labels -l $@.l \
		-L $@.lst \
		-o $@ -a $<

all: $(BINS)

clean:
	rm -f $(BINS)
