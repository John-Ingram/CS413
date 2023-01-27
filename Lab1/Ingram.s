@ Filename: Ingram.s
@ Author:   John Ingram
@ Email:    jsi0004@uah.edu
@ Class:    CS413-01 Spring 2023
@ Date:     01/26/2023
@ 
@ Description: Declare three arrays that will contain integers. 
@ Arrays one and two will be initialized in the code. The values of arrays will 
@ contain integers such that when array elements are added the results are positive, 
@ zero and negative. Array three will be calculated to be equal to the 
@ Array one[i] + Array two[i] and must be performed using a for loop construct and auto-indexing. 
@ The program is to print a welcome message with instructions to the user.
@ The program is to print the elements of all three arrays with text on which array is being printed. 
@ The array print must be performed by a subroutine and accessed by using 
@ the ARM Assembly instruction BL. The starting address of the array to be printed will be 
@ passed into the subroutine. The address may be passed via a register or the stack via the 
@ PUSH and POP commands. Since this print subroutine is not a leaf routine code must be in place to 
@ properly save and restore the link register (r14).
@ The user will be prompted to enter a positive, negative or zero. The software will then 
@ print only the numbers of that type (positive, negative, zero) from array three. 
@ The software must use a for loop and auto-indexing to access the array elements. 
@ Assume all inputs are valid and no overflow conditions will occur. 
@
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o Ingram.o Ingram.s
@    gcc -o Ingram Ingram.o
@    ./Ingram ;echo $?
@    gdb --args ./Ingram 

.equ READERROR, 0 @Used to check for scanf read error. 

.global main @ Have to use main because of C library uses. 

main:
@ push the link register onto the stack.
    push {lr}

@ Print welcome message and instructions to user.

@*******************
welcome:
@*******************

    @ Ask the user to enter a number.
    
    ldr r0, =strWelcome @ Put the address of my string into the first parameter
    bl  printf          @ Call the C printf to display input prompt. 

@*******************
addArrays:
@*******************
    mov r0, #10       @ Set the loop counter to 10.
    ldr r1, =array1-4  @ Load the address of array1 into r1.
    ldr r2, =array2-4  @ Load the address of array2 into r2.
    ldr r3, =array3-4  @ Load the address of array3 into r3.

    adderLoop:
        @ Add the values of array1 and array2 and store them in array3 using pre indexing.
        ldr r5, [r1, #4]! @ Load the value of array1 into r5.
        ldr r6, [r2, #4]! @ Load the value of array2 into r6.
        add r7, r5, r6   @ Add the values of array1 and array2 and store them in r7.
        str r7, [r3, #4]! @ Store the value of r7 in array3.
        subs r0, r0, #1  @ Decrement the loop counter by 1.
        bne adderLoop    @ Branch back to the top of the loop if the loop counter is not 0.

@*******************
printArrays:
@*******************
@ Print Arrays 1-3 using the printArray subroutine.

    ldr r0, =strArray1 @ Put the address of my string into the first parameter
    bl  printf         @ Call the C printf to display the prompt. 

    ldr r4, =array1-4    @ Load the address of array1 into r4.
    ldr r6, =10        @ Load the size of array1 into r6.
    bl  printArray     @ Call the printArray subroutine to print array1.

    ldr r0, =strArray2 @ Put the address of my string into the first parameter
    bl  printf         @ Call the C printf to display input prompt. 

    ldr r4, =array2-4    @ Load the address of array2 into r4.
    ldr r6, =10        @ Load the size of array2 into r6.
    bl  printArray     @ Call the printArray subroutine to print array2.

    ldr r0, =strArray3 @ Put the address of my string into the first parameter
    bl  printf         @ Call the C printf to display input prompt. 

    ldr r4, =array3-4    @ Load the address of array3 into r4.
    ldr r6, =10        @ Load the size of array3 into r6.
    bl  printArray     @ Call the printArray subroutine to print array3.

    b getInput        @ go to getInput

@*******************
getInput:
@*******************
@ Get either a positive, negative, or zero from the user.

    ldr r0, =strInput @ Put the address of my string into the first parameter
    bl  printf        @ Call the C printf to display input prompt. 

    ldr r0, =numInputPattern    @ Setup to read in one number.
    ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored. 
    bl  scanf                @ scan the keyboard.
    cmp r0, #READERROR       @ Check for a read error.
    beq readerror            @ If there was a read error go handle it. 

    b printSummary          @ go to printSummary, since we have a valid input.


@***********
readerror:
@***********
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

   b getInput


@*******************
printSummary:
@*******************
@ Print array 3 and then exit the program.

    @ Grab the user input and store it in r5.
    ldr r5, =intInput
    ldr r5, [r5]

    @ Set up for Looping through array 3.
    ldr r4, =array3-4    @ Load the address of array3 into r4.
    ldr r7, =10        @ Load the size of array3 into r7.


    @ Choose which loop to use
    cmp r5, #0
    bgt positiveLoop
    blt negativeLoop
    beq zeroLoop


    positiveLoop:
    @ Print the array elements using a for loop. and the pattern:
    @ Put the pattern into r0.
    ldr r0, =numOutputPattern
    @ Put the array element into r1.
    ldr r1, [r4, #4]!
    @ Check if the array element is positive.
    cmp r1, #0
    @ If it is positive, print it.
    blgt printf
    subs r7, r7, #1  @ Decrement the loop counter by 1.
    @ increment the address of the array by 4.
    bne positiveLoop    @ Branch back to the top of the loop if the loop counter is not 0.
    b exit

    negativeLoop:
    @ Print the array elements using a for loop. and the pattern:
    @ Put the pattern into r0.
    ldr r0, =numOutputPattern
    @ Put the array element into r1.
    ldr r1, [r4, #4]!
    @ Check if the array element is negative.
    cmp r1, #0
    @ If it is negative, print it.
    bllt printf
    subs r7, r7, #1  @ Decrement the loop counter by 1.
    @ increment the address of the array by 4.
    bne negativeLoop    @ Branch back to the top of the loop if the loop counter is not 0.
    b exit

    zeroLoop:
    @ Print the array elements using a for loop. and the pattern:
    @ Put the pattern into r0.
    ldr r0, =numOutputPattern
    @ Put the array element into r1.
    ldr r1, [r4, #4]!
    @ Check if the array element is zero.
    cmp r1, #0
    @ If it is zero, print it.
    bleq printf
    subs r7, r7, #1  @ Decrement the loop counter by 1.
    @ increment the address of the array by 4.
    bne zeroLoop    @ Branch back to the top of the loop if the loop counter is not 0.
    b exit

    exit:
    pop {lr}
    bx lr

@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @ SVC call to exit
   mov r0, #0    @ Exit code 0
   svc 0         @ Make the system call. 


@*******************
printArray:
@*******************
@ This subroutine will print the contents of an array. It will be called by printArrays.
@ The address of the array will be passed in via r4. The size of the array will be passed in via r6.
@ The subroutine will print the contents of the array using a for loop and auto-indexing.
@ The subroutine will use the C printf function to print the array elements.
@ The subroutine will yield control back to the caller when the array has been printed.
@ The Program Counter (PC) will be stored in the link register (r14) when the subroutine is called.

    push {LR} @ Save the link register.
    push {r7} @ Save the registers that will be used.
    mov r7, r6 @ Set the loop counter to the size of the array.


    printLoop:
        @ Print the array elements using a for loop. and the pattern:
        @ Put the pattern into r0.
        ldr r0, =numOutputPattern
        @ Put the array element into r1.
        ldr r1, [r4, #4]!
        bl printf        @ Call the C printf to display the array element. 
        subs r7, r7, #1  @ Decrement the loop counter by 1.
        @ increment the address of the array by 4.
        bne printLoop    @ Branch back to the top of the loop if the loop counter is not 0.

    pop {r7}             @ Restore the registers that were used.
    pop {PC}             @ Return to the caller.


.data

@ String to prompt user for input.

.balign 4
strWelcome: .asciz "Welcome! I will first print all 3 arrays, then you will enter either a positive, negative or zero number. \nI will then print only the numbers of that type from array 3."

@ Strings to label the arrays.
.balign 4
strArray1: .asciz "\nArray 1: "

.balign 4
strArray2: .asciz "\nArray 2: "

.balign 4
strArray3: .asciz "\nArray 3: "

@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

@ Format pattern for printf call.
.balign 4
numOutputPattern: .asciz "%d\t"  @ integer format for write.

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input. 

@ Let the assembler know these are the C library functions. 

@ String to prompt user for input.
.balign 4
strInput: .asciz "\nEnter a positive, negative or zero number: "

@ Location to store the user input.
.balign 4
input: .word 0

@ Declare the arrays.
.balign 4
array1: .word 1, 2, 3, 0, 5, 6, -7, 8, -9, 10

.balign 4
array2: .word 1, -2, -3, -4, 5, 6, 1, 8, 9, 10

.balign 4
array3: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


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
