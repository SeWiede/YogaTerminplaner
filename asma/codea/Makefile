#verwirrtes Makefile 1.0
CC = gcc
DEFS =
CFGLAGS = -std=c99
LDFLAGS =  
OBJECTFILES = scanner.o
EXECS = scanner
CFILES = 
.PHONY: all clean

all: parser
 


matcher.brg: codea.bfe
	bfe codea.bfe > matcher.brg
matcher.c: matcher.brg
	iburg matcher.brg > matcher.c
matcher.o: matcher.c tree.h
	gcc -c matcher.c


parser: scan.lex matcher.o
	yacc -d parser.codea.y && flex scan.lex && cc -c y.tab.c && cc -c lex.yy.c && cc -o codea y.tab.o matcher.o -lfl

clean: 
	rm -f scanner lex.yy.c y.output parser y.tab.c y.tab.h matcher.brg matcher.c matcher.o

