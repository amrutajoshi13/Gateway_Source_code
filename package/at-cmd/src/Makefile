.PHONY:all install clean

BINDIR=./bin

CC:=$(CROSS_COMPILE)gcc

SRCLIST=$(wildcard ./*.c)
OBJLIST=$(SRCLIST:%.c=%.o)

TARGET=at-cmd

all:$(OBJLIST) $(TARGET) install

$(OBJLIST):%.o:%.c 
	$(CC) -c $< -o $@

$(TARGET):$(OBJLIST) 
	$(CC) -o $(TARGET) $(OBJLIST)



clean:
	rm ./* $(BINDIR)/*


.DELETE_ON_ERROR: 
