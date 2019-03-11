# Tested only on ubuntu 18.04 contenair

CC= gcc

INCLUDE= -I/usr/include/lua5.3

LIBS= -L/usr/lib -llua5.3 -lm
OPENSSL_LIBS= -L/usr/local/openssl/lib -lcrypto -lssl

CFLAGS= -Wall -O2 -pedantic $(INCLUDE)
C_EXEC_PATH=.
SO_PATH=.
CERTIFICATS_PATH=./certificats

.PHONY: all, clean

all: splayd jobd so_module cert

clean:
	rm -f *.o *.so
	rm -f *.log
	rm -f *.pem *.srl
	rm -f splayd jobd
	rm -f luacrypto/*.o
	rm -f lbase64/*.o
	rm -f luacrypto/*.so

cert:
	openssl req -newkey rsa:1024 -sha1 -keyout rootkey.pem -out rootreq.pem \
		-nodes -config $(CERTIFICATS_PATH)/root.cnf -days 365 -batch
	openssl x509 -req -in rootreq.pem -sha1 -extfile $(CERTIFICATS_PATH)/root.cnf \
		-extensions v3_ca -signkey rootkey.pem -out root.pem -days 365
	openssl x509 -subject -issuer -noout -in root.pem
	openssl req -newkey rsa:1024 -sha1 -keyout key.pem -out req.pem \
		-nodes -config $(CERTIFICATS_PATH)/client.cnf -days 365 -batch
	openssl x509 -req -in req.pem -sha1 -extfile $(CERTIFICATS_PATH)/client.cnf \
		-extensions usr_cert -CA root.pem -CAkey rootkey.pem -CAcreateserial \
		-out cert.pem -days 365
	cat cert.pem root.pem > client.pem
	openssl x509 -subject -issuer -noout -in client.pem


compmod.o: compmod.c compmod.h
	$(CC) $(CFLAGS) -c -o compmod.o compmod.c

# For create executable jobd and splayd
splayd.o: $(C_EXEC_PATH)/splayd.c $(C_EXEC_PATH)/splayd.h
	$(CC) $(CFLAGS) -c -o splayd.o $(C_EXEC_PATH)/splayd.c

jobd.o: $(C_EXEC_PATH)/jobd.c $(C_EXEC_PATH)/jobd.h
	$(CC) $(CFLAGS) -c -o jobd.o $(C_EXEC_PATH)/jobd.c

splay_lib.o: $(C_EXEC_PATH)/splay_lib.c $(C_EXEC_PATH)/splay_lib.h
	$(CC) $(CFLAGS) -c -o splay_lib.o $(C_EXEC_PATH)/splay_lib.c

splayd: splayd.o splay_lib.o compmod.o
	$(CC) -o splayd splayd.o splay_lib.o compmod.o $(LIBS)
	strip splayd

jobd: jobd.o splay_lib.o compmod.o
	$(CC) -o jobd jobd.o splay_lib.o compmod.o $(LIBS)
	strip jobd


# Lua Extension modules
so_module: splay_core.so splay/misc_core.so splay/data_bits_core.so lbase64.so

### Splay module
splay_core.so: splay.o
	$(CC) -O -fpic -shared -o splay_core.so splay.o compmod.o -lm
	#strip splay_core.so

splay.o: $(SO_PATH)/splay.c $(SO_PATH)/splay.h
	$(CC) -fpic $(CFLAGS) -c -o splay.o $(SO_PATH)/splay.c

### Misc module
splay/misc_core.so: misc.o
	$(CC) -O -fpic -shared -o splay/misc_core.so misc.o compmod.o -lm

misc.o: $(SO_PATH)/misc.c $(SO_PATH)/misc.h
	$(CC) -fpic $(CFLAGS) -c -o misc.o $(SO_PATH)/misc.c

### Data_bits module
splay/data_bits_core.so: data_bits.o
	$(CC) -O -fpic -shared -o splay/data_bits_core.so data_bits.o compmod.o -lm

data_bits.o: $(SO_PATH)/data_bits.c $(SO_PATH)/data_bits.h
	$(CC) -fpic $(CFLAGS) -c -o data_bits.o $(SO_PATH)/data_bits.c

### base64
lbase64.so: lbase64/lbase64.o
	$(CC) -O -fpic -shared -o base64.so lbase64/*.o compmod.o $(OPENSSL_LIBS)

lbase64/lbase64.o:
	$(CC) -fpic $(CFLAGS) -c -o lbase64/lbase64.o $(SO_PATH)/lbase64/lbase64.c
