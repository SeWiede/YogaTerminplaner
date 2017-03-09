#verwirrtes Makefile 1.0
CC = gcc
DEFS =
CFGLAGS = -std=c99
LDFLAGS =  
OBJECTFILES = asma.o
EXECS = main
CFILES = 
.PHONY: all clean S

all: asma.o

asma.o: asma.s
	$(CC) -c $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean: 
	rm -f $(OBJECTFILES) $(EXECS)

S:
	$(CC) -O -S $(CFILES) 
