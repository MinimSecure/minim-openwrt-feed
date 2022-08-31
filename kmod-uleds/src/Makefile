obj-m += uleds.o

all:
	make -C $(KSRC) M=$(shell pwd) modules

clean:
	make -C $(KSRC) M=$(shell pwd) clean
	@rm -rf Module.markers Module.symvers modules.order

