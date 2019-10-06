From ubuntu:19.10

RUN apt-get update && apt-get install -y build-essential make wget tar texinfo libgmp3-dev libz-dev qemu-system-arm

RUN wget http://ftpmirror.gnu.org/binutils/binutils-2.30.tar.gz \
    && wget http://ftpmirror.gnu.org/gcc/gcc-8.1.0/gcc-8.1.0.tar.gz \
    && wget http://ftpmirror.gnu.org/mpfr/mpfr-4.0.1.tar.gz \
    && wget http://ftpmirror.gnu.org/gmp/gmp-6.1.2.tar.bz2 \
    && wget http://ftpmirror.gnu.org/mpc/mpc-1.1.0.tar.gz \
    && wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2 \
    && wget ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.1.tar.gz \
    && for i in *.tar.gz; do tar -xzf $i && rm $i; done \
    && for i in *.tar.bz2; do tar -xjf $i && rm $i; done \
    && cd binutils-* && ln -s ../isl-* isl && cd .. \
    && cd gcc-* && ln -s ../isl-* isl && ln -s ../mpfr-* mpfr && ln -s ../gmp-* gmp &&  ln -s ../mpc-* mpc && ln -s ../cloog-* cloog && cd .. \
    && mkdir aarch64-binutils && cd aarch64-binutils && ../binutils-*/configure --prefix=/usr/local/cross-compiler --target=aarch64-elf \
    --enable-shared --enable-threads=posix --enable-libmpx --with-system-zlib --with-isl --enable-__cxa_atexit \
    --disable-libunwind-exceptions --enable-clocale=gnu --disable-libstdcxx-pch --disable-libssp --enable-plugin \
    --disable-linker-build-id --enable-lto --enable-install-libiberty --with-linker-hash-style=gnu --with-gnu-ld\
    --enable-gnu-indirect-function --disable-multilib --disable-werror --enable-checking=release --enable-default-pie \
    --enable-default-ssp --enable-gnu-unique-object && make -j8 && make install && make clean && cd .. \
    && mkdir aarch64-gcc && cd aarch64-gcc && ../gcc-*/configure --prefix=/usr/local/cross-compiler --target=aarch64-elf --enable-languages=c \
    --enable-shared --enable-threads=posix --enable-libmpx --with-system-zlib --with-isl --enable-__cxa_atexit \
    --disable-libunwind-exceptions --enable-clocale=gnu --disable-libstdcxx-pch --disable-libssp --enable-plugin \
    --disable-linker-build-id --enable-lto --enable-install-libiberty --with-linker-hash-style=gnu --with-gnu-ld\
    --enable-gnu-indirect-function --disable-multilib --disable-werror --enable-checking=release --enable-default-pie \
    --enable-default-ssp --enable-gnu-unique-object && make -j8 all-gcc && make install-gcc && make clean && cd .. \
    && rm -rf /binutils-* /gcc-* /isl-* /mpfr-* /gmp-* /mpc-* /cloog-*

RUN wget http://gnu.mirrors.hoobly.com/gdb/gdb-8.3.1.tar.gz \
    && tar -xzf gdb-8.3.1.tar.gz && cd gdb* && ./configure --target=aarch64-elf \
    && make -j8 && make install && make clean && cd .. && rm -rf /gdb-*

RUN mkdir -p /home/user/source
RUN echo "add-auto-load-safe-path /home/user/source/.gdbinit" > /home/user/.gdbinit
ENV PATH="/usr/local/cross-compiler/bin/:${PATH}"
ENV WORKDIR /home/user/source
ENV HOME /home/user/source
ENV CC aarch64-elf-gcc
ENV LD aarch64-elf-ld
