# Purintf - A Custom Implementation of printf

## Overview

Purintf is a custom implementation of the standard C library function `printf`. This project is designed to provide a deep view on C functions and how they actually work in assembler

## Features

- **Basic Format Specifiers**: Supports common format specifiers like `%c`, `%s`, `%d`, `%b`, `%x`, `%o` and `%%`.

## Supported Format Specifiers

| Specifier | Description                          |
|-----------|--------------------------------------|
| `%c`      | Character                            |
| `%s`      | String                               |
| `%d`      | Signed decimal integer               |
| `%x`      | Unsigned hexadecimal integer (lowercase) |
| `%%`      | Percent sign                         |

## Usage

To use Purintf in your project, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Barkir/purintf.git
   cd purintf
2. **Run these commands in your command line**
   ``nasm -f elf64 purintf.asm -o purintf.o`` - creating an object file out of assmbler file
   ``gcc -c main.c -o main.o`` - creating an object file out of C file
   ``gcc main.o purintf.o -o run`` - creating a binary file

P.S. For debugging I used radare2 and this [guide](https://github.com/UjeNeTORT/r2GuideProdva) really helped me
