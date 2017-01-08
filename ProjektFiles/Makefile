# gepasp makefile
CC=gcc
# todo: Optimisierung und Name anpassen
TARGET=defaukt
OPTIMIZATION=0
COPTS=-g -mcpu=cortex-a8 -mfpu=neon -mfloat-abi=hard -marm -o $(TARGET) -O$(OPTIMIZATION)

all: bin

bin: default.c nop.S
	$(CC) $(COPTS) $+ 

clean:
	rm $(TARGET)
