# Make Lab1 (Called test)

# Debug mode where the LEDs are actually just printed to the screen
Debug: test.o
	gcc -o test test.o -lwiringPiDebug

# Compile the program
Release: test.o
	gcc -o test test.o -lwiringPi

# Assemble the program
test.o: test.s
	as -o test.o test.s
