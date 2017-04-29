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
	ox parser.y scan.lex && yacc -d oxout.y && lex oxout.l && cc -c y.tab.c && cc -c lex.yy.c && cc -o ag y.tab.o lex.yy.o -ll -ly

clean: 
	rm -f ag lex.yy.c y.tab.o lex.yy.o y.output parser y.tab.c y.tab.h oxout.y oxout.l

