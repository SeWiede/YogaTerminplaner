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
util.o: util.c util.h
	gcc -c util.c


parser: scan.lex matcher.o util.o
	ox parser.y scan.lex && yacc -d oxout.y && lex oxout.l && cc -g -c y.tab.c && cc -g -c lex.yy.c && cc -g -o codeb lex.yy.o y.tab.o matcher.o util.o -lfl

clean: 
	rm -f codeb oxout.y oxout.l lex.yy.c y.output parser y.tab.c y.tab.h matcher.brg matcher.c matcher.o y.tab.o lex.yy.o util.o

