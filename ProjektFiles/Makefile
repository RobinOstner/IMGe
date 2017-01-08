# gepasp makefile
CC=gcc
# todo: Optimisierung und Name anpassen
TARGET=main
OPTIMIZATION=0
COPTS=-g -mcpu=cortex-a8 -mfpu=neon -mfloat-abi=hard -marm -o $(TARGET) -O$(OPTIMIZATION)

all: bin

bin: main.c mandelbrot.S
	$(CC) $(COPTS) $+ 

clean:
	rm $(TARGET)
