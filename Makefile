KERNBIN := kernel.elf
OBJ := start.o \
	kmain.o

CFLAGS := -O0 -ffreestanding -nostdlib -Wall -Wextra

all: $(KERNBIN)

LDSCRIPT := linker.ld

$(KERNBIN): $(OBJ)
	$(LD) -T $(LDSCRIPT) -o $@ $^

.PHONY: clean
clean:
	@rm -f $(OBJ) $(KERNBIN)
