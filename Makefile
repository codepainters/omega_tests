OBJS=01_hello_ppi.rom 02_write_ssl.rom 03_ram_rw.rom

%.rom : %.asm
	zasm -wu $<

all: $(OBJS)


.PHONY: clean
clean:
	rm -f ${OBJS}
	rm -f *.lst
