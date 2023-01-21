@ Filename: Ingram.s
@ Author:   John Ingram
@ Email:    jsi0004@uah.edu
@ Class:    CS413-01 Spring 2023
@ Date:     01/21/2023
@
@ Purpose:  Provide a welcome and instruction message to the user
@           Prompt the user to enter an integer between 1 and 10
@           Verify the proper input value. 
@           Reject any invalid inputs (negative, greater than 10) and re-prompt for a valid input value.
@           Print “Hello world.” The number of times the user entered. 
@           Each “Hello world.” will be printed on a separate line.
@           Code is to exit once the required messages are printed the requested number of times.


.equ READERROR, 0 @ Check for scanf and read error

.global main @ Use main because of C library use

main:

prompt:

@ Print the prompt message

   ldr r0, =promptmsg @ Load the address of the prompt message into r0







.data

@ Define the prompt message
.balign 4
promptmsg: .asciz "Enter an integer between 1 and 10: "