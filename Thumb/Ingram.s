@ Filename: Ingram.s
@ Author:   John Ingram
@ Email:    jsi0004@uah.edu
@ Class:    CS413-01 Spring 2023
@ Date:     02/5/2023
@
@ Purpose:  
@           Enter Thumb mode, then:
@           Provide a welcome and instruction message to the user
@           Prompt the user to enter an integer between 1 and 10
@           Verify the proper input value. 
@           Reject any invalid inputs (negative, greater than 10) and re-prompt for a valid input value.
@           Print “Hello world.” The number of times the user entered. 
@           Each “Hello world.” will be printed on a separate line.
@           Code is to exit once the required messages are printed the requested number of times.


.equ READERROR, 0 @ Check for scanf and read error

.global main @ Use main because of C library use


main: @ Just a label to help check if we are in Thumb mode.
@------------------------------------------------------------
@ Enter Thumb mode
@------------------------------------------------------------
ldr r0, =prompt+1 @ Load the address of prompt+1 into r0, 
                @now branching to prompt+1 will put us in Thumb mode.
bx r0           @ Branch to prompt+1, which will put us in Thumb mode.
.code 16        @ Assemble in Thumb mode.


@------------------------------------------------------------
prompt:

@ Print the prompt message
   ldr r0, =promptmsg @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

@------------------------------------------------------------

@------------------------------------------------------------
get_input:

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored. 
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 so that
                            @ it can be looped the correct number of times.
   ldr r5, =intInput        @ Load the address of the counter into r5.
   ldr r5, [r5]             @ Read the contents of intInput and store in r5 so that
                             @ it can be looped the correct number of times.


validate:
@============Check for valid input===========================
   cmp r1, #0               @ Check for a negative number.
   ble invalid_input        @ If the number is negative go handle it.
   cmp r1, #11              @ Check for a number greater than 10.
   bge invalid_input        @ If the number is greater than 10 go handle it.
@============Input is valid, continue to loop================

@------------------------------------------------------------

@------------------------------------------------------------
loop:

   ldr r0, =strHelloWorld   @ Put address into r0 for print.
   bl printf                @ Print the message.
   sub r5, r5, #1          @ Decrement the counter.
   cmp r5, #0               @ Check if the counter is 0.
   bne loop                 @ If the counter is not 0 go back and print another message.
   b exit                   @ If the counter is 0 exit the program.

@------------------------------------------------------------

@------------------------------------------------------------
invalid_input:

@ Print the error message
   ldr r0, =errormsg   @ Put address into r0 for print.
   bl printf                @ Print the error message.
    b prompt                 @ Go back and prompt for a valid input.

@------------------------------------------------------------

@------------------------------------------------------------
readerror:
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

   ldr r0, =strInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   b prompt

@------------------------------------------------------------

@------------------------------------------------------------
exit:

@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @ SVC call to exit
   svc 0         @ Make the system call. 

@------------------------------------------------------------


.data

@ Define the prompt message
.balign 4
promptmsg: .asciz "Enter an integer between 1 and 10: "

@ Define the error message
.balign 4
errormsg: .asciz "Invalid input. Please enter a number between 1 and 10.\n"

@ Define the hello world message
.balign 4
strHelloWorld: .asciz "Hello world.\n"


@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input. 

@ Let the assembler know these are the C library functions. 

.global printf
@  To use printf:
@     r0 - Contains the starting address of the string to be printed. The string
@          must conform to the C coding standards.
@     r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@          r1 must contain the value to be printed. 
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed. 

.global scanf
@  To use scanf:
@      r0 - Contains the address of the input format string used to read the user
@           input value. In this example it is numInputPattern.  
@      r1 - Must contain the address where the input value is going to be stored.
@           In this example memory location intInput declared in the .data section
@           is being used.  
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ Important Notes about scanf:
@   If the user entered an input that does NOT conform to the input pattern, 
@   then register r0 will contain a 0. If it is a valid format
@   then r0 will contain a 1. The input buffer will NOT be cleared of the invalid
@   input so that needs to be cleared out before attempting anything else.
@
@ Additional notes about scanf and the input patterns:
@    1. If the pattern is %s or %c it is not possible for the user input to generate
@       and error code. Anything that can be typed by the user on the keyboard
@       will be accepted by these two input patterns. 
@    2. If the pattern is %d and the user input 12.123 scanf will accept the 12 as
@       valid input and leave the .123 in the input buffer. 
@    3. If the pattern is "%c" any white space characters are left in the input
@       buffer. In most cases user entered carrage return remains in the input buffer
@       and if you do another scanf with "%c" the carrage return will be returned. 
@       To ignore these "white" characters use " $c" as the input pattern. This will
@       ignore any of these non-printing characters the user may have entered.
@

@ End of code and end of file. Leave a blank line after this.
