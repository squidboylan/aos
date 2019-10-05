KERNBIN := kernel.elf
LDSCRIPT := linker.ld

OBJ := start.o \
       kmain.o

CFLAGS := -O0 -ffreestanding -nostdlib -Wall -Wextra -g

all: $(KERNBIN)

$(KERNBIN): $(OBJ)
	$(LD) -T $(LDSCRIPT) -o $@ $^

.PHONY: clean qemu qemu-gdb
clean:
	@rm -f $(OBJ) $(KERNBIN)

QEMU := $(shell which qemu-system-aarch64)
QEMUOPTS := -machine raspi3\
	    -display none\
	    -serial null\
	    -serial stdio\
	    -kernel $(KERNBIN)

qemu: all
	$(QEMU) $(QEMUOPTS)

qemu-gdb: all
	$(QEMU) $(QEMUOPTS) -s -S
