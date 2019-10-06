KERNBIN := kernel.elf
LDSCRIPT := linker.ld

OBJ := start.o \
       kmain.o

CFLAGS := -O0 -ffreestanding -nostdlib -Wall -Wextra -g

all: $(KERNBIN)

$(KERNBIN): $(OBJ)
	$(LD) -T $(LDSCRIPT) -o $@ $^

.PHONY: clean docker-image docker-qemu docker-build docker-qemu-gdb docker-gdb qemu qemu-gdb
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

# Build the docker image
docker-image:
	@docker rmi squidboylan/aos ; docker build . -t squidboylan/aos

# Run make all inside a docker container
docker-build:
	@docker run --rm --user $$(id -u) -v "$$(pwd)":/home/user/source -w /home/user/source squidboylan/aos make all

# Run qemu in a docker container
# This is necessary because only very new qemu has the raspi3 machine available
docker-qemu:
	@docker run --rm --user $$(id -u) -v "$$(pwd)":/home/user/source -w /home/user/source -e DISPLAY=$${DISPLAY} -it -v /tmp/.X11-unix:/tmp/.X11-unix squidboylan/aos make qemu

docker-qemu-gdb:
	@docker run --rm --user $$(id -u) -v "$$(pwd)":/home/user/source -w /home/user/source -e DISPLAY=$${DISPLAY} -it -v /tmp/.X11-unix:/tmp/.X11-unix squidboylan/aos make qemu-gdb

# Find the docker container running qemu and run gdb in it
docker-gdb:
	@docker exec -it $$(docker ps | grep "make qemu" | awk '{print $$1}') aarch64-elf-gdb
