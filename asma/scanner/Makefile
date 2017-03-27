#verwirrtes Makefile 1.0
CC = gcc
DEFS =
CFGLAGS = -std=c99
LDFLAGS =  
OBJECTFILES = scanner.o
EXECS = scanner
CFILES = 
.PHONY: all clean

all: scanner

scanner: scan.lex
	flex scan.lex && gcc lex.yy.c -lfl -o scanner

clean: 
	rm -f scanner lex.yy.c

