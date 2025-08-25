#!/usr/bin/env bash

ARGS="-d:release"

nimble build $ARGS && mv server server_linux_x86
nimble build $ARGS --gcc.exe:musl-gcc --gcc.linkerexe:musl-gcc --passL:-static && mv server server_static_linux_x86
