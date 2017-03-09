CC = gcc
DEFS =
CFGLAGS = -std=c99
LDFLAGS = -g 
OBJECTFILES = file.o main.o
EXECS = file
CFILES = 
.PHONY: all clean S

all: file

main: $(OBJECTFILES)
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean: 
	rm -f $(OBJECTFILES) $(EXECS)

S:
	$(CC) -O -S $(CFILES) 
