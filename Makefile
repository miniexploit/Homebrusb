CC = gcc
SOURCES = homebrusb.m
FRAMEWORKS:= -framework Foundation
LIBRARIES:= -lobjc
CFLAGS=-Wall -Werror -arch x86_64 -g -v $(SOURCES)
LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
OUT=-o homebrusb
RM=rm
all: $(SOURCES) $(OUT) clean

$(OUT): $(OBJECTS)
	$(CC) -o $(OBJECTS) $@ $(CFLAGS) $(LDFLAGS) $(OUT)

.m.o:
	$(CC) -c Wall $< -o $@

clean:
	$(RM) -r homebrusb.dSYM
