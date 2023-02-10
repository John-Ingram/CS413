@ Filename: Ingram.s
@ Author:   John Ingram
@ Email:    jsi0004@uah.edu
@ Class:    CS413-01 Spring 2023
@ Date:     02/09/2023
@
@ Purpose:  Write an ARM Assembly program that will calculate 
@ the area of the following four plane shapes:
@ a)	Triangle
@ b)	Rectangle
@ c)	Trapezoid
@ d)	Square
@
@ All number inputs are integers and all calculation results are 
@ provided in integer format. Any fractional calculations are to be truncated. 



.equ READERROR, 0 @ Check for scanf and read error

.global main @ Use main because of C library use

main:

prompt:

@ Print the prompt message
   ldr r0, =promptmsg @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

@------------------------------------------------------------

@------------------------------------------------------------
get_input:
   @ Clear the input buffer
   @bl clear_input_buffer

   ldr r0, =charInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored. 
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 

validate:
@============Check that the input is 1, 2, 3, 4, or q===========================
   @ Check if the input is q
   cmp r1, #113             @ Compare the input to the ASCII value of q
   beq exit                 @ If the input is q, exit the program.
   @ convert the input to an integer
   sub r1, r1, #48          @ Subtract 48 from the input to convert to an integer

   @ Check if the input is 1, 2, 3, or 4
   cmp r1, #1              
   beq triangle_prompt     @ If the number is 1, triangle was selected.
   cmp r1, #2              
   beq rectangle_prompt    @ If the number is 2, rectangle was selected.
   cmp r1, #3
   beq trapezoid_prompt    @ If the number is 3, trapezoid was selected.
   cmp r1, #4
   beq square_prompt       @ If the number is 4, square was selected.

   b invalid_input         @ If the number is not 1, 2, 3, or 4, go to invalid_input.
@==============================================================================

invalid_input:
@============Input is invalid, print an error and then go to prompt================
   ldr r0, =errormsg   @ Put address into r0 for print.
   bl printf                @ Print the error message.
   b prompt                 @ Go back and prompt for a valid input.

@==================================================================================

@------------------------------------------------------------
triangle_prompt:
@ Prompt the user for the base and height of the triangle
   ldr r0, =triangleBasePrompt @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored.
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 

   @ Push the base onto the stack, for use in the calculation subroutine
   push {r1}

   ldr r0, =triangleHeightPrompt @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored.
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 

   @ Push the height onto the stack, for use in the calculation subroutine
   push {r1}

   @ Call the triangle calculation subroutine
   bl triangle_calc

   @ Print the result
   ldr r0, =triangleMsg @ Load the address of the prompt message into r0
   
   pop {r1}  @ Pop the result off the stack into the r1 register for use in printf
   
   bl printf @ Call printf to print the  result

   bl wait_for_enter

   @ Go back to the prompt
   b prompt

@------------------------------------------------------------

@------------------------------------------------------------
triangle_calc:
@ Calculate the area of the triangle
   @ Pop the height and base off the stack
   pop {r2}
   pop {r3}

   @ Multiply the base and height using umull, to check for overflow
   @ r0 and r1 are the result registers
   @ r2 and r3 are the input registers
   @ r0 and r1 are clobbered by this instruction
   umull r0, r1, r2, r3

   @ Check if the result overflowed
   cmp r1, #0
   bne overflow

   @ The result did not overflow, so we can safely shift right 1 bit
   @ to divide by 2
   mov r0, r0, lsr #1

   @ Push the result back onto the stack
   push {r0}

   @ Return to the triangle_prompt subroutine
   bx lr
@------------------------------------------------------------

@------------------------------------------------------------
rectangle_prompt:
@ Prompt the user for the width and height of the rectangle
   ldr r0, =rectangleWidthPrompt @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored.
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 

   @ Push the width onto the stack, for use in the calculation subroutine
   push {r1}

   ldr r0, =rectangleHeightPrompt @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored.
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 

   @ Push the height onto the stack, for use in the calculation subroutine
   push {r1}

   @ Call the rectangle calculation subroutine
   bl rectangle_calc

   @ Print the result
   ldr r0, =rectangleMsg @ Load the address of the prompt message into r0
   
   pop {r1}  @ Pop the result off the stack into the r1 register for use in printf
   
   bl printf @ Call printf to print the  result

   bl wait_for_enter

   @ Go back to the prompt 
   b prompt

@------------------------------------------------------------

@------------------------------------------------------------
rectangle_calc:
@ Calculate the area of the rectangle
   @ Pop the height and width off the stack
   pop {r2}
   pop {r3}

   @ Multiply the width and height using umull, to check for overflow
   @ r0 and r1 are the result registers
   @ r2 and r3 are the input registers
   @ r0 and r1 are clobbered by this instruction
   umull r0, r1, r2, r3

   @ Check if the result overflowed
   cmp r1, #0
   bne overflow

   @ The result did not overflow, so we can safely push the result
   @ onto the stack
   push {r0}

   @ Return to the rectangle_prompt subroutine
   bx lr
@------------------------------------------------------------

@------------------------------------------------------------
trapezoid_prompt:
@ Prompt the user for the width and height of the trapezoid
   ldr r0, =trapezoidBaseAPrompt @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored.
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 

   @ Push the width onto the stack, for use in the calculation subroutine
   push {r1}

   ldr r0, =trapezoidBaseBPrompt @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored.
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 

   @ Push the width onto the stack, for use in the calculation subroutine
   push {r1}

   ldr r0, =trapezoidHeightPrompt @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored.
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 

   @ Push the height onto the stack, for use in the calculation subroutine
   push {r1}

   @ Call the trapezoid calculation subroutine
   bl trapezoid_calc

   @ Print the result
   ldr r0, =trapezoidMsg @ Load the address of the prompt message into r0
   
   pop {r1}  @ Pop the result off the stack into the r1 register for use in printf
   
   bl printf @ Call printf to print the  result

   bl wait_for_enter

   @ Go back to the prompt
   b prompt
@------------------------------------------------------------

@------------------------------------------------------------
trapezoid_calc:
@ Calculate the area of the trapezoid
   @ Pop the height and width off the stack
   pop {r2} @ Pop the height off the stack
   pop {r3} @ Pop base a off the stack
   pop {r4} @ Pop base b off the stack

   @ Add the bases together
   add r3, r3, r4

   @ divide the sum by 2 using a shift
   mov r3, r3, lsr #1

   @ Multiply by the height using umull, to check for overflow
   @ r0 and r1 are the result registers
   @ r2 and r3 are the input registers
   @ r0 and r1 are clobbered by this instruction
   umull r0, r1, r2, r3

   @ Check if the result overflowed
   cmp r1, #0
   bne overflow

   @ The result did not overflow, so we can safely push the result
   @ onto the stack
   push {r0}

   @ Return to the trapezoid_prompt subroutine
   bx lr
@------------------------------------------------------------

@------------------------------------------------------------
square_prompt:
@ Prompt the user for the side of the square
   ldr r0, =squareSidePrompt @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the prompt message

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored.
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput and store in r1 

   @ Push the side onto the stack, for use in the calculation subroutine
   push {r1}

   @ Call the square calculation subroutine
   bl square_calc

   @ Print the result
   ldr r0, =squareMsg @ Load the address of the prompt message into r0
   
   pop {r1}  @ Pop the result off the stack into the r1 register for use in printf
   
   bl printf @ Call printf to print the  result

   bl wait_for_enter

   @ Go back to the prompt
   b prompt
@------------------------------------------------------------

@------------------------------------------------------------
square_calc:
@ Calculate the area of the square
   @ Pop the side off the stack
   pop {r2} @ Pop the side off the stack

   @ Multiply the side by itself using umull, to check for overflow
   @ r0 and r1 are the result registers
   @ r2 is the input register
   @ r0 and r1 are clobbered by this instruction
   umull r0, r1, r2, r2

   @ Check if the result overflowed
   cmp r1, #0
   bne overflow

   @ The result did not overflow, so we can safely push the result
   @ onto the stack
   push {r0}

   @ Return to the square_prompt subroutine
   bx lr
@------------------------------------------------------------

@------------------------------------------------------------
overflow:
@ The result overflowed, print an error message and return to the triangle_prompt subroutine
   ldr r0, =overflowMsg @ Load the address of the prompt message into r0
   bl printf @ Call printf to print the  result

   bl wait_for_enter

   @ Return to the prompt so the user can try again
   b prompt
@------------------------------------------------------------


@------------------------------------------------------------
wait_for_enter:
   @ Wait for the user to hit the enter key so that the user can see the result
   @ save the link register so we can return to the caller
   push {lr}

   @ clear the input buffer
   ldr r0, =charInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.

   @ print the prompt
   ldr r0, =enterMsg
   bl printf

   @ read the input
   ldr r0, =strInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.

   @ return to the caller
   pop {pc}
@------------------------------------------------------------

@------------------------------------------------------------
clear_input_buffer:
   push {lr}

   @ clear the input buffer
   ldr r0, =charInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
   
   pop {pc}
@------------------------------------------------------------

@------------------------------------------------------------
validate_math_numbers:
@ Validate that the number on the stack can be used for math
pop {r1}


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
promptmsg: .asciz "Welcome to Area Calculation Program\nEnter the shape number:\n1. Triangle\n2. Rectangle\n3. Trapezoid\n4. Square\n\nOr enter q to quit\n"

@ Define the error message
.balign 4
errormsg: .asciz "Invalid input. Please try again\n"

@ Define the overflow message
.balign 4
overflowMsg: .asciz "The result overflowed. Please try again\n"

@ Define the enter message
.balign 4
enterMsg: .asciz "Press enter to continue\n"

@----------------Shape Prompts-------------------------------
@ Define the triangle prompts
.balign 4
triangleMsg: .asciz "The area of the triangle is: %d\n\n"

.balign 4
triangleBasePrompt: .asciz "Enter the base of the triangle:\n"

.balign 4
triangleHeightPrompt: .asciz "Enter the height of the triangle:\n"


@ Define the rectangle prompts
.balign 4
rectangleMsg: .asciz "The area of the rectangle is: %d\n\n"

.balign 4
rectangleWidthPrompt: .asciz "Enter the width of the rectangle:\n"

.balign 4
rectangleHeightPrompt: .asciz "Enter the height of the rectangle:\n"


@ Define the trapezoid prompts
.balign 4
trapezoidMsg: .asciz "The area of the trapezoid is: %d\n\n"

.balign 4
trapezoidBaseAPrompt: .asciz "Enter the base a of the trapezoid:\n"

.balign 4
trapezoidBaseBPrompt: .asciz "Enter the base b of the trapezoid:\n"

.balign 4
trapezoidHeightPrompt: .asciz "Enter the height of the trapezoid:\n"

@ Define the square prompts
.balign 4
squareMsg: .asciz "The area of the square is: %d\n\n"

.balign 4
squareSidePrompt: .asciz "Enter the side of the square:\n"

@------------------------------------------------------------




@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
charInputPattern: .asciz "%c"  @ character format for read.

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
