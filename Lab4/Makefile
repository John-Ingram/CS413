# Make Lab1 (Called Ingram)

# Debug mode where the LEDs are actually just printed to the screen
Debug: Ingram.o
	gcc -o Ingram Ingram.o -lwiringPiDebug

# Compile the program
Release: Ingram.o
	gcc -o Ingram Ingram.o -lwiringPi

# Assemble the program
Ingram.o: Ingram.s
	as -o Ingram.o Ingram.s
