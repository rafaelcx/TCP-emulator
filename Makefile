all:
	gcc prog2.c -Wall -Wextra
	./a.out 10 0.0 0.0 1000 2 | less
