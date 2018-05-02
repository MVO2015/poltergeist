receive433: receive433.c
	gcc -DHOME=\"$${POLTERGEIST_HOME}\" -Wall -o receive433 receive433.c -lpigpio -lrt