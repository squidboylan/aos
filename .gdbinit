set architecture aarch64
echo + target remote localhost:1234\n
target remote localhost:1234

echo + symbol-file kernel.elf\n
symbol-file kernel.elf
