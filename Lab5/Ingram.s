@ Filename: Ingram.s
@ Author:   John Ingram
@ Email:    jsi0004@uah.edu
@ Class:    CS413-01 Spring 2023
@ Date:     03/10/2023
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
@    gcc -o Ingram Ingram.o -lwiringPi
@    ./Ingram ;echo $?
@    gdb --args ./Ingram 
@ Define the constants for this code. 

OUTPUT = 1 @ Used to set the selected GPIO pins to output only. 
ON     = 1 @ Turn the LED on.
OFF    = 0 @ Turn the LED off.

RED    = 5 @ Pin number from wiringPi for red led
YELLOW = 4 @ Pin number from wiringPi for yellow led
GREEN  = 3 @ Pin number from wiringPi for green led
BLUE   = 2 @ Pin number from wiringPi for blue led

@ Define the following from wiringPi.h header

INPUT  = 0  

PUD_UP   = 2  
PUD_DOWN = 1 

LOW  = 0 
HIGH = 1

.text
.balign 4

.equ READERROR, 0 @Used to check for scanf read error. 

.global main @ Have to use main because of C library uses. 

main:
@ push the link register onto the stack.
    push {lr}
    b init

@ Print welcome message and instructions to user.

@*******************
welcome:
@*******************
    @ Welcome the user to the vending machine.
    ldr r0, =strWelcome @ Put the address of my string into the first parameter
    bl  printf          @ Call the C printf to display input prompt. 

    @ Turn on the Red LED for 5 seconds.
    ldr r2, =red_LED
    ldr r1, =fiveS
    ldr r1, [r1]
    bl  turnOnLED
    @ Turn off the Red LED.
    ldr r2, =red_LED
    bl  turnOffLED


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

@     ldr r0, =strInputPattern
@     ldr r1, =strInput        @ load r1 with the address of where the
@                              @ input value will be stored. 
@     bl  scanf                @ scan the keyboard.
@     cmp r0, #READERROR       @ Check for a read error.
@     beq readerror            @ If there was a read error go handle it. 

@     ldr r1, =strInput        @ Put the user's selected treat into r6 for safe keeping.
@     @ Grab the first character of the user's input using ldrb.
@     ldrb r6, [r1]

@ Delay a few miliseconds to help debounce the switches. 
@
    ldr  r0, =delayMs
    ldr  r0, [r0]
    BL   delay

ReadBLUE:
@ Read the value of the blue button. If it is HIGH (i.e., not
@ pressed) read the next button and set the previous reading
@ value to HIGH. 
@ Otherwise the current value is LOW (pressed). If it was LOW
@ that last time the button is still pressed down. Do not record
@ this as a new pressing.
@ If it was HIGH the last time and LOW now then record the 
@ button has been pressed.
@
    ldr    r0,  =buttonBlue
    ldr    r0,  [r0]
    BL     digitalRead 
    cmp    r0, #HIGH   @ Button is HIGH read next button
    moveq  r9, r0      @ Set last time read value to HIGH 
    beq    ReadGREEN

    @ The button value is LOW.
    @ If it was LOW the last time it is still down. 
    cmp    r9, #LOW    @ was the last time it was called also
                       @ down?
    beq    ReadGREEN   @ button is still down read next button
                       @ value. 
     
    mov    r9, r0  @ This is a new button press. 
    b      PedBLUE @ Branch to print the blue button was pressed. 

ReadGREEN:
@ See comments on BLUE button on how this code works. 
@
    ldr    r0,  =buttonGreen
    ldr    r0,  [r0]
    BL     digitalRead  
    cmp    r0, #HIGH
    moveq  r10, r0
    beq    ReadYELLOW   

    cmp    r10, #LOW
    beq    ReadYELLOW  

    mov    r10, r0
    b      PedGREEN 

ReadYELLOW:
@ See comments on BLUE button on how this code works. 
@
    ldr    r0,  =buttonYellow
    ldr    r0,  [r0]
    BL     digitalRead 
    cmp    r0, #HIGH
    moveq  r11, r0
    beq    ReadRED 
 
    cmp    r11, #LOW
    beq    ReadRED

    mov    r11, r0
    b      PedYELLOW 

ReadRED:
@ See comments on BLUE button on how this code works. 
@
    ldr    r0,  =buttonRed
    ldr    r0,  [r0]
    BL     digitalRead 
    cmp    r0, #HIGH
    moveq  r8, r0
    beq    getSelection
 
    cmp    r8, #LOW
    beq    getSelection
 
    mov    r8, r0
    b      PedRED

PedBLUE:
    mov  r6, #77          @ Load ascii value for 'P' into r6
    B    checkSelection       @ Make sure the selection is correct

PedGREEN:
    mov  r6, #67          @ Load ascii value for 'P' into r6
    B    checkSelection        @ Make sure the selection is correct

PedYELLOW:
    mov  r6, #80          @ Load ascii value for 'P' into r6
    B    checkSelection         @ Make sure the selection is correct

PedRED:
    mov  r6, #71          @ Load ascii value for 'G' into r6
    B    checkSelection       @ Make sure the selection is correct




    bl checkSelection        @ Check the user's selection, if it is valid
                             @ then branch to the correct routine.

@*******************
checkSelection:
@*******************
@ Check the user's selection to make sure it is valid.
@ If the input is valid, put the item name into r1 and put the item price into r4.
@ also branch to the item selected routine. 
@ If the input is invalid, branch to the invalidSelection routine.
@ Also push a numerical code onto the stack for the item selected.
@ Gum = 71, Peanuts = 80, Cheese Crackers = 67, M&Ms = 77
    
        cmp r6, #71 @ Check for G
        ldreq r1, =strGum
        moveq r4, #50
        moveq r12, #71
        push {r12}
        beq checkGum
    
        cmp r6, #103 @ Check for g
        ldreq r1, =strGum
        moveq r4, #50
        moveq r12, #71
        push {r12}
        beq checkGum

        cmp r6, #80 @ Check for P
        ldreq r1, =strPeanuts
        moveq r4, #55
        moveq r12, #80
        push {r12}
        beq checkPeanuts
    
        cmp r6, #112 @ Check for p
        ldreq r1, =strPeanuts
        moveq r4, #55
        moveq r12, #80
        push {r12}
        beq checkPeanuts
    
        cmp r6, #67 @ Check for C
        ldreq r1, =strCheeseCrackers
        moveq r4, #65
        moveq r12, #67
        push {r12}
        beq checkCheeseCrackers
    
        cmp r6, #99 @ Check for c
        ldreq r1, =strCheeseCrackers
        moveq r4, #65
        moveq r12, #67
        push {r12}
        beq checkCheeseCrackers
    
        cmp r6, #77 @ Check for M
        ldreq r1, =strMms
        moveq r4, #100
        moveq r12, #77
        push {r12}
        beq checkMms
    
        cmp r6, #109 @ Check for m
        ldreq r1, =strMms
        moveq r4, #100
        moveq r12, #77
        push {r12}
        beq checkMms

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

    @ Welcome the user to the secret menu.
    ldr r0, =strSecretWelcome
    bl  printf

    @ Print the Gum stock.
    ldr r0, =strGumStock
    ldr r1, =stockGum
    ldr r1, [r1]
    bl  printf

    @ Print the Peanuts stock.
    ldr r0, =strPeanutsStock
    ldr r1, =stockPeanuts
    ldr r1, [r1]
    bl  printf

    @ Print the Cheese Crackers stock.
    ldr r0, =strCheeseCrackersStock
    ldr r1, =stockCheeseCrackers
    ldr r1, [r1]
    bl  printf

    @ Print the M&Ms stock.
    ldr r0, =strMmsStock
    ldr r1, =stockMms
    ldr r1, [r1]
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
@ Check stock routines
@*******************
@ Check if the item is in stock. If it is, continue with program execution. If it is not, display a
@ message informing the user to make another selection

checkGum:
    @ Check if there is any Gum in stock. If there is, 
    ldr r5, =stockGum
    ldr r5, [r5]
    cmp r5, #0
    bgt itemSelected
    b notInStock

checkPeanuts:
    @ Check if there is any Peanuts in stock. If there is, 
    ldr r5, =stockPeanuts
    ldr r5, [r5]
    cmp r5, #0
    bgt itemSelected
    b notInStock

checkCheeseCrackers:
    @ Check if there is any Cheese Crackers in stock. If there is, 
    ldr r5, =stockCheeseCrackers
    ldr r5, [r5]
    cmp r5, #0
    bgt itemSelected
    b notInStock

checkMms:
    @ Check if there is any M&Ms in stock. If there is, 
    ldr r5, =stockMms
    ldr r5, [r5]
    cmp r5, #0
    bgt itemSelected
    b notInStock

notInStock:
    @ The item is not in stock.
    ldr r0, =strOutOfStock
    bl  printf
    b promptSelection



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

    @ Find what we dispensed using the code set into r12, and update the inventory.
    @ Gum = 71, Peanuts = 80, Cheese Crackers = 67, M&Ms = 77
    pop {r12}


    cmp r12, #71
    @ If the item is Gum, set r2 to the address of the LED for Gum, and subtract one from the inventory.
    ldreq r0, =stockGum
    ldreq r1, [r0]
    subeq r1, r1, #1
    streq r1, [r0]
    ldreq r2, =red_LED

    cmp r12, #80
    @ If the item is Peanuts, set r2 to the address of the LED for Peanuts, and subtract one from the inventory.
    ldreq r0, =stockPeanuts
    ldreq r1, [r0]
    subeq r1, r1, #1
    streq r1, [r0]
    ldreq r2, =yellow_LED
 

    cmp r12, #67
    @ If the item is Cheese Crackers, set r2 to the address of the LED for Cheese Crackers, and subtract one from the inventory.
    ldreq r0, =stockCheeseCrackers
    ldreq r1, [r0]
    subeq r1, r1, #1
    streq r1, [r0]
    ldreq r2, =green_LED

    cmp r12, #77
    @ If the item is M&Ms, set r2 to the address of the LED for M&Ms, and subtract one from the inventory.
    ldreq r0, =stockMms
    ldreq r1, [r0]
    subeq r1, r1, #1
    streq r1, [r0]
    ldreq r2, =blue_LED

    @ Do the vending sequence.
    b ledSequence

    @ If the inventory is empty, display a message and exit the program.
    itemVended:
    @ Add up the inventory in r12 to see if it is empty.
    mov r12, #0
    ldr r0, =stockGum
    ldr r1, [r0]
    add r12, r12, r1
    ldr r0, =stockPeanuts
    ldr r1, [r0]
    add r12, r12, r1
    ldr r0, =stockCheeseCrackers
    ldr r1, [r0]
    add r12, r12, r1
    ldr r0, =stockMms
    ldr r1, [r0]
    add r12, r12, r1
    cmp r12, #0
    beq myexit
    

    b promptSelection



@******************LED STUFF*********************
@ This section of code will have code to turn on the LEDS
@ To use the digialWrite function:
@    r0 - must contain the pin number for the GPIO per the header file info
@    r1 - set to 1 to turn the output on or to 0 to turn the output off.
@
@ To use the delay function:
@    r0 - must contains the number of miliseconds to delay. 
@
@ Delay must be called after the digitalWrite function otherwise the LED will 
@ blink on and off very quickly.
@
@ For this code, we will expect
@    r0 - to be changed after the function returns.
@    r1 - contains the number of miliseconds to delay.
@    r2 - contains which LED to turn on or off.
@ No other registers will be used.

@*******************
init:
@*******************
@ Check the setup of the GPIO to make sure it is working right. 

        bl      wiringPiSetup
        mov     r1,#-1
        cmp     r0, r1
        bne     initLeds        @Board is good so continue 
        ldr     r0, =ErrMsg @If it is not working print error
                            @ message then exit.
        bl      printf
        b       done

initLeds:
@ Initialize the GPIO pins for the LEDs
@ set the blue LED mode to output
        ldr     r0, =blue_LED
        ldr     r0, [r0]
        mov     r1, #OUTPUT
        bl      pinMode

@ set the green LED mode to output

        ldr     r0, =green_LED
        ldr     r0, [r0]
        mov     r1, #OUTPUT
        bl      pinMode

@ set the yellow LED mode to output

        ldr     r0, =yellow_LED
        ldr     r0, [r0]
        mov     r1, #OUTPUT
        bl      pinMode

@ set the red LED mode to output

        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #OUTPUT
        bl      pinMode

initButtons:
@ set the mode to input-BLUE

        ldr     r0, =buttonBlue
        ldr     r0, [r0]
        mov     r1, #INPUT
        bl      pinMode

@ set the mode to input - GREEN

        ldr     r0, =buttonGreen
        ldr     r0, [r0]
        mov     r1, #INPUT
        bl      pinMode

@ set the mode to input- YELLOW

        ldr     r0, =buttonYellow
        ldr     r0, [r0]
        mov     r1, #INPUT
        bl      pinMode

@ set the mode to input - RED

        ldr     r0, =buttonRed
        ldr     r0, [r0]
        mov     r1, #INPUT
        bl      pinMode

 
@ Setup and read all the buttons. 
@ Set the buttons for pull-up and it is 0 when pressed. 
@    pullUpDnControl(buttonPin, PUD_UP)
@    digitalRead(buttonPin) == LOW button pressed
@
    ldr  r0, =buttonBlue
    ldr  r0, [r0]
    mov  r1, #PUD_UP
    BL   pullUpDnControl 

    ldr  r0, =buttonGreen
    ldr  r0, [r0]
    mov  r1, #PUD_UP
    BL   pullUpDnControl 

    ldr  r0, =buttonYellow
    ldr  r0, [r0]
    mov  r1, #PUD_UP
    BL   pullUpDnControl 

    ldr  r0, =buttonRed
    ldr  r0, [r0]
    mov  r1, #PUD_UP
    BL   pullUpDnControl 

@
@  Set the registers to debounce switches and handle buttons 
@  held down,.
@
    mov r8,  #0xff 
    mov r9,  #0xff
    mov r10, #0xff    
    mov r11, #0xff 


@ done initializing, so branch to the main program
    b       welcome


@*******************
turnOnLED:
@*******************
@ This function will turn on the LED that is passed in r2.
@ The number of miliseconds to delay is passed in r1.
@ r0 will be changed after the function returns.
@ Push the link register onto the stack so we can return to the main program
        push    {lr}
@ Push the number of miliseconds to delay onto the stack so we can use it later
        push    {r1}
@ Write a logic one to turn the LED to on.
        ldr     r0, [r2]
        mov     r1, #ON
        bl      digitalWrite

@ Run the delay otherwise it blinks so fast you never see it!
        pop     {r0}
        bl      delay

@ Pop the link register off the stack and return to the main program
        pop     {pc}

@*******************
turnOffLED:
@*******************
@ This function will blink the LED that is passed in r2.
@ r0 will be changed after the function returns.
@ Push the link register onto the stack so we can return to the main program
        push    {lr}
@ Write a logic zero to turn the LED to off.
        ldr     r0, [r2]
        mov     r1, #OFF
        bl      digitalWrite

@ Run the delay otherwise it blinks so fast you never see it!
        ldr     r0, =oneS
        ldr     r0, [r0]
        bl      delay

@ Pop the link register off the stack and return to the main program
        pop     {pc}

@*******************
ledSequence:
@*******************
@ This function will do the 'dispense' sequence for the LED passed in r2.
@ push r2 onto the stack so we can use for each time we turn the LED on and off
        push    {r2}
    
    pop     {r2}
    push    {r2}
    ldr r1, =oneS
    ldr r1, [r1]
    bl  turnOnLED
    @ Turn off the Red LED.
    pop     {r2}
    push    {r2}
    bl  turnOffLED@ Turn on the Red LED for 1 seconds.
    pop     {r2}
    push    {r2}
    ldr r1, =oneS
    ldr r1, [r1]
    bl  turnOnLED
    @ Turn off the Red LED.
    pop     {r2}
    push    {r2}
    bl  turnOffLED
    @ Turn on the Red LED for 1 seconds.
    pop     {r2}
    push    {r2}
    ldr r1, =oneS
    ldr r1, [r1]
    bl  turnOnLED
    @ Turn off the Red LED.
    pop     {r2}
    push    {r2}
    bl  turnOffLED
    @ Turn on the Red LED for 5 seconds.
    pop     {r2}
    push    {r2}
    ldr r1, =fiveS
    ldr r1, [r1]
    bl  turnOnLED
    @ Turn off the Red LED.
    pop     {r2}
    bl  turnOffLED

@ The item has been vended so branch back to the main program
    b       itemVended

@**************END LED STUFF*********************


@*******************
invalidSelection:
@*******************
@ Invalid selection was made. Print error message and prompt user to try again.

    ldr r0, =strInvalidSelection @ Put the address of my string into the first parameter
    bl  printf                   @ Call the C printf to display input prompt. 

    b promptSelection

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

    @ Display the out of inventory message.
    ldr r0, =strOutOfInventory
    bl  printf

    @ Turn on the Red LED for 5 seconds.
    ldr r2, =red_LED
    ldr r1, =fiveS
    ldr r1, [r1]
    bl  turnOnLED
    @ Turn off the Red LED.
    ldr r2, =red_LED
    bl  turnOffLED

   mov r7, #0x01 @ SVC call to exit
   mov r0, #0    @ Exit code 0
   svc 0         @ Make the system call. 



.data

@ Define the values for the pins

blue_LED   : .word BLUE
green_LED  : .word GREEN
yellow_LED : .word YELLOW
red_LED    : .word RED

oneS: .word 1000  @ Set delay for one second. 
fiveS: .word 5000    @ Set delay for five seconds.

@ Define the values for the buttons

buttonBlue:   .word 7 @Blue button
buttonGreen:  .word 0 @Green button
buttonYellow: .word 6 @Yellow button
buttonRed:    .word 1 @Red button

delayMs: .word 250  @ Delay time in Miliseconds.

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

@ Out of stock message.
.balign 4
strOutOfStock: .asciz "\nSorry, that item is out of stock. Please try a different item.\n"

@ Out of inventory message.
.balign 4
strOutOfInventory: .asciz "\nSorry, the vending machine is out of inventory. \nPlease contact the company to let them know to refill the machine.\n"

@ Stock Section.
.balign 4
stockGum: .word 2
stockPeanuts: .word 2
stockCheeseCrackers: .word 2
stockMms: .word 2

@ Board Error message.
.balign 4 
ErrMsg: .asciz "Setup didn't work... Aborting...\n"

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

@
@  The following are defined in wiringPi.h
@
.extern wiringPiSetup 
.extern delay
.extern digitalWrite
.extern pinMode

@end of code and end of file. Leave a blank line after this
