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
	flex scan.lex && yacc -d parser.y && cc lex.yy.c y.tab.c -o parser

clean: 
	rm -f scanner lex.yy.c y.output parser y.tab.c y.tab.h

