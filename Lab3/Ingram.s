@ Filename: Ingram.s
@ Author:   John Ingram
@ Email:    jsi0004@uah.edu
@ Class:    CS413-01 Spring 2023
@ Date:     02/23/2023
@ 
@ Description: This program will simulate the operation of a vending machine. The machine will dispense,
@ upon reception of the correct amount of money, a choice of Gum, Peanuts, Cheese Crackers, or
@ M&Ms. Your software will perform the following:
@ 1. Display a welcome message and instructions.
@ 2. Set the initial inventory to two (2) of each kind.
@ 3. Prompt the user for item selection. Gum (G), Peanuts (P), Cheese Crackers (C), or
@ M&Ms (M). Reject any invalid selections.
@ 4. Confirm the customer’s selection.
@ 5. Prompt the user for the amount to enter: Gum ($0.50), Peanuts ($0.55), Cheese Crackers
@ ($0.65), or M&Ms ($1.00).
@ 6. Accept money inputs of dimes (D), quarters (Q), and one-dollar bills (B).
@ 7. If the customer selects an out of inventory item, prompt them to make another selection.
@ 8. Vending machine will shut down if the entire inventory reaches zero.
@ 9. Assume there is no limit on the amount of change the vending machine contains.
@ 10. Make provisions for a secret code that when entered will display the current inventory of
@ items
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
    @ Welcome the user to the vending machine.
    ldr r0, =strWelcome @ Put the address of my string into the first parameter
    bl  printf          @ Call the C printf to display input prompt. 

    @ Stock the vending machine with 2 of each item.
    @ Gum r8
    mov r8, #2
    @ Peanuts r9
    mov r9, #2
    @ Cheese Crackers r10
    mov r10, #2
    @ M&Ms r11
    mov r11, #2


@*******************
promptSelection:
@*******************
    @ Prompt the user to select an item from the list.
    ldr r0, =strSelectionPrompt @ Put the address of my string into the first parameter
    bl  printf                  @ Call the C printf to display input prompt.


@*******************
getSelection:
@*******************
@ Get the user's selection.

    ldr r0, =strInputPattern
    ldr r1, =strInput        @ load r1 with the address of where the
                             @ input value will be stored. 
    bl  scanf                @ scan the keyboard.
    cmp r0, #READERROR       @ Check for a read error.
    beq readerror            @ If there was a read error go handle it. 

    ldr r1, =strInput        @ Put the user's selected treat into r6 for safe keeping.
    @ Grab the first character of the user's input using ldrb.
    ldrb r6, [r1]             

    bl checkSelection        @ Check the user's selection, if it is valid
                             @ then branch to the correct routine.

@*******************
checkSelection:
@*******************
@ Check the user's selection to make sure it is valid.
@ If the input is valid, put the item name into r1 and put the item price into r4.
@ also branch to the item selected routine. 
@ If the input is invalid, branch to the invalidSelection routine.
    
        cmp r6, #71 @ Check for G
        ldreq r1, =strGum
        moveq r4, #50
        beq itemSelected
    
        cmp r6, #103 @ Check for g
        ldreq r1, =strGum
        moveq r4, #50
        beq itemSelected

        cmp r6, #80 @ Check for P
        ldreq r1, =strPeanuts
        moveq r4, #55
        beq itemSelected
    
        cmp r6, #112 @ Check for p
        ldreq r1, =strPeanuts
        moveq r4, #55
        beq itemSelected
    
        cmp r6, #67 @ Check for C
        ldreq r1, =strCheeseCrackers
        moveq r4, #65
        beq itemSelected
    
        cmp r6, #99 @ Check for c
        ldreq r1, =strCheeseCrackers
        moveq r4, #65
        beq itemSelected
    
        cmp r6, #77 @ Check for M
        ldreq r1, =strMms
        moveq r4, #100
        beq itemSelected
    
        cmp r6, #109 @ Check for m
        ldreq r1, =strMms
        moveq r4, #100
        beq itemSelected

        @ Check for secret code.
        cmp r6, #83 @ Check for S
        beq secretCode

        cmp r6, #115 @ Check for s
        beq secretCode
    
        b invalidSelection

@*******************
secretCode:
@*******************
@ Display the stock of the vending machine.

    @ Print the Gum stock.
    ldr r0, =strGumStock
    mov r1, r8
    bl  printf

    @ Print the Peanuts stock.
    ldr r0, =strPeanutsStock
    mov r1, r9
    bl  printf

    @ Print the Cheese Crackers stock.
    ldr r0, =strCheeseCrackersStock
    mov r1, r10
    bl  printf

    @ Print the M&Ms stock.
    ldr r0, =strMmsStock
    mov r1, r11
    bl  printf

    b promptSelection


@*******************
itemSelected:
@*******************
@ The user has selected an item. Display the item name and ask the user if that is the item they want.
@ If the user wants the item, branch to the itemConfirmed routine. If the user does not want the item,
@ branch back to the promptSelection routine.
    @ Copy the name of the treat into r5 for when we need to display it later.
    mov r5, r1

    @ Display what item the user selected, and ask if that is the item they want.
    @ Print part 1 of the string.
    ldr r0, =strSelectionA    @ Put the address of my string into the first parameter
    bl  printf               @ Call the C printf to display input prompt. 

    @ Print the item name.
    mov r0, r5
    bl  printf

    @ Print part 2 of the string.
    ldr r0, =strSelectionB    @ Put the address of my string into the first parameter
    bl  printf               @ Call the C printf to display input prompt.

    @ Check if the user wants the item they selected.

    ldr r0, =strInputPattern
    ldr r1, =strInput        @ load r1 with the address of where the
                             @ input value will be stored. 
    bl  scanf                @ scan the keyboard.
    cmp r0, #READERROR       @ Check for a read error.
    beq readerror            @ If there was a read error go handle it. 

    ldr r0, =strInput       @ Put the user's selection into r1 since we only need it for a moment.
    ldrb r1, [r0]

    cmp r1, #89 @ Check for Y
    beq itemConfirmed
    
    cmp r1, #121 @ Check for y
    beq itemConfirmed

    b promptSelection

@*******************
itemConfirmed:
@*******************
@ The user has confirmed the item they want. Display the item price and ask the user to enter the
@ Amount of money they want to enter. 

    @ Copy the price of the treat into r1 so we can display it now.
    mov r1, r4

    @ Display the item price and ask the user to enter the amount of money they want to enter.
    @ Check if the price is more than $1.00. If it is, then we need to display $1.00 instead of 100 cents.
    cmp r1, #100
    blt lessThanOne

    @ Item price is more than $1.00
    ldr r0, =strPaymentDollar        @ Put the address of my string into the first parameter
    bl  printf                 @ Call the C printf to display input prompt.
    b   moneySelection

    lessThanOne:
    @ Item price is less than $1.00
    ldr r0, =strPayment        @ Put the address of my string into the first parameter
    bl  printf                 @ Call the C printf to display input prompt. 

    moneySelection:
    @ Get the user's selection.

    ldr r0, =strInputPattern 
    ldr r1, =strInput        @ load r1 with the address of where the
                             @ input value will be stored. 
    bl  scanf                @ scan the keyboard.
    cmp r0, #READERROR       @ Check for a read error.
    beq readerror            @ If there was a read error go handle it. 

    ldr r0, =strInput       @ Put the user's selection into r1 since we only need it for a moment.
    ldrb r1, [r0]

    b checkMoney

@*******************
getMoreMoney:
@*******************
@ The user did not enter enough money to buy the item. Display the remaining balance (r4) and ask the user
@ for more money
        @ Copy the remaining balance into r1 so we can display it now.
        mov r1, r4
    
        @ Display the remaining balance and ask the user for more money.
        ldr r0, =strMoreMoney        @ Put the address of my string into the first parameter
        bl  printf                   @ Call the C printf to display input prompt. 
    
        @ Get the user's selection.
    
        ldr r0, =strInputPattern 
        ldr r1, =strInput        @ load r1 with the address of where the
                                @ input value will be stored. 
        bl  scanf                @ scan the keyboard.
        cmp r0, #READERROR       @ Check for a read error.
        beq readerror            @ If there was a read error go handle it. 
    
        ldr r0, =strInput       @ Put the user's selection into r1 since we only need it for a moment.
        ldrb r1, [r0]
    
        b checkMoney


@*******************
checkMoney:
@*******************
    @ Check what amount of money the user entered. Set r7 to the amount of money entered.
    cmp r1, #68 @ Check for Dime
    moveq r7, #10

    cmp r1, #100 @ Check for Dime
    moveq r7, #10

    cmp r1, #81 @ Check for Quarter
    moveq r7, #25

    cmp r1, #113 @ Check for Quarter
    moveq r7, #25

    cmp r1, #66 @ Check for Dollar Bill
    moveq r7, #100

    cmp r1, #98 @ Check for Dollar Bill
    moveq r7, #100


    @ Subtract the amount of money entered from the balance due (r4).
    sub r4, r7

    @ Check if the amount of money entered is enough to buy the item.
    cmp r4, #0
    bgt getMoreMoney


    @ If the amount of money was enough, display the item name and the amount of change.

    @ Put the item name into r1 so we can display it now.
    mov r1, r5

    ldr r0, =strItemDispensed
    bl printf


    @ Calculate the amount of change by taking the absolute value, and put it into r1 so we can display it now.
    cmp r4, #0     @ Compare r4 to zero
    blt negative   @ Branch to negative if r4 is negative
    mov r1, r4     @ Move r4 to r1 if r4 is positive
    b done         @ Branch to done
    negative:
    rsb r1, r4, #0 @ Negate r4 and store the result in r1
    done:
    @ Display the amount of change.
    ldr r0, =strChange
    bl printf

    @ Find what we dispensed, and update the inventory.
    cmp r5, =strGum
    subeq r8, #1

    cmp r5, =strPeanuts
    subeq r9, #1

    cmp r5, =strCheeseCrackers
    subeq r10, #1

    cmp r5, =strMms
    subeq r11, #1


    b promptSelection

@*******************
invalidSelection:
@*******************
@ Invalid selection was made. Print error message and prompt user to try again.

    ldr r0, =strInvalidSelection @ Put the address of my string into the first parameter
    bl  printf                   @ Call the C printf to display input prompt. 

    b getSelection

@***********
readerror:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

   ldr r0, =strInputPatternError
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   b invalidSelection


@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @ SVC call to exit
   mov r0, #0    @ Exit code 0
   svc 0         @ Make the system call. 



.data

@ Welcome message.
.balign 4
strWelcome: .asciz "\nWelcome to the Vending Machine!\n" 
        
@ String to prompt user for selection.
.balign 4
strSelectionPrompt: .asciz "\nPlease select an item from the following list:\n\nGum-$0.50 (G), Peanuts-$0.55 (P), Cheese Crackers-$0.65 (C), or M&Ms-$1.00 (M).\n\nPlease enter your selection:"

@ Invalid selection message.
.balign 4
strInvalidSelection: .asciz "\nInvalid selection. Please try again.\n"

@ Selection made by user text.
.balign 4
strSelectionA: .asciz "\nYou have selected "

.balign 4
strSelectionB: .asciz " Is this correct? (Y/N): "

@ Options for user to select from.
.balign 4
strGum: .asciz "Gum"

.balign 4
strPeanuts: .asciz "Peanuts"

.balign 4
strCheeseCrackers: .asciz "Cheese Crackers"

.balign 4
strMms: .asciz "M&Ms"

@ Output format for money under $1.
.balign 4
strCents: .asciz "$0.%d"

@ Output format for $1.
.balign 4
strDollars: .asciz "$1.00"

@ Secret Menu.
.balign 4
strSecretWelcome: .asciz "\nWelcome to the Secret Menu! Stock is as follows: \n"

@ Stock of Gum.
.balign 4
strGumStock: .asciz "Gum: %d\n"

@ Stock of Peanuts.
.balign 4
strPeanutsStock: .asciz "Peanuts: %d\n"

@ Stock of Cheese Crackers.
.balign 4
strCheeseCrackersStock: .asciz "Cheese Crackers: %d\n"

@ Stock of M&Ms.
.balign 4
strMmsStock: .asciz "M&Ms: %d\n"

@ String to prompt user for payment.
.balign 4
strPayment: .asciz "\nEnter at least $0.%d for selection.\nDime (D), Quarter (Q), or One Dollar Bill (B): "

@ String to prompt user for payment if the price is $1.
.balign 4
strPaymentDollar: .asciz "\nEnter at least $1.00 for selection.\nDime (D), Quarter (Q), or One Dollar Bill (B): "

@ Ask for more money.
.balign 4
strMoreMoney: .asciz "\nPlease deposit more money. Ballance remaining: $0.%d\nDime (D), Quarter (Q), or One Dollar Bill (B): "

@ Enough money has been entered.
.balign 4
strItemDispensed: .asciz "\nThank you for your payment.\n %s dispensed.\n"

@ Change returned to user.
.balign 4
strChange: .asciz "\nChange of $0.%d has been returned\n"

@ Format pattern for scanf call.
.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

@ Character format for scanf call.
.balign 4
charInputPattern: .asciz "%c"  @ character format for read.

@ String format for scanf call.
.balign 4
strInputPattern: .asciz "%s"  @ string format for read.

@ Format pattern for printf call.
.balign 4
numOutputPattern: .asciz "%d\t"  @ integer format for write.

.balign 4
strInputPatternError: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input. 

@ Location to store the user string input.
.balign 4
strInput: .skip 100*4

@ Let the assembler know these are the C library functions. 

@ Location to store the user input.
.balign 4
input: .word 0




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
