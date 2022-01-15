/*
This file is part of gamelib-x64.

Copyright (C) 2014 Tim Hegeman

gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/

.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data

#Two dimensional array
#Tile[rsi][rdi]

matrix:   .skip 32                  #0x404030 == 4210736 in decimal

                                    #0x404030(0)   0x404032(1)   0x404034(2)   0x404036(3)

                                    #0x404038(4)   0x40403A(5)   0x40403C(6)   0x40403E(7)

                                    #0x404040(8)   0x404042(9)   0x404044(10)  0x404046(11)

                                    #0x404048(12)  0x40404A(13)  0x40404C(14)  0x40404E(15)



.section .game.text
          
titleString:    .asciz "2048"          
startString:    .asciz "Press Enter to start the game"
ruleString:     .asciz "Press r to view the rules of the game" 
rule1:          .asciz "Use arrow keys to move and merge tiles."
rule2:          .asciz "Two tiles can be merged if they have the same value."
rule3:          .asciz "When there is no possible move, the game is over."
rule4:          .asciz "Challenge yourself to get 2048!"   
currentScore:   .asciz "Current Score"
bestScore:      .asciz "Best Score"
winString:      .asciz "Congratulations! You've won the game."
gameOverString: .asciz "Game Over."
scoreString:    .asciz "Your score was: "
newGameString:  .asciz "Press K to start a new game"

value2:         .asciz "2"
value4:         .asciz "4"    
value8:         .asciz "8"
value16:        .asciz "16"
value32:        .asciz "32"
value64:        .asciz "64"
value128:       .asciz "128"
value256:       .asciz "256"
value512:       .asciz "512"
value1024:      .asciz "1024"
value2048:      .asciz "2048"




gameInit:

pushq   %rbp
movq    %rsp, %rbp


#Clear the screen before print the menu page
 

movq    $0, %rdi                   #First parameter: x-coordinate of the pixel
movq    $0, %rsi                   #Second parameter: y-coordinate of the pixel
call    clearScreen    

#Print the menu page
call    printMenu

#Initialize the grid with two tiles at two random positions in the grid
movq    $matrix, %rdi
call    generateRandomTile

movq    $matrix, %rdi
call    generateRandomTile


movq    $0, %r9                    #New top score
movq    $0, %r10                   #Old top score

movq    %rbp, %rsp
popq    %rbp
 
ret


gameLoop:


#Game state: 
    #-1 = Game Over
    #0 = Game running
    #1 = Game win

#Game score:
    #R9             #New Top Score
    #R10            #Old Top Score


pushq   %rbp
movq    %rsp, %rbp


movq    $65536, %rdi               #Set the CPU clock to the lowest speed,18Hz
call    setTimer  


call    readKeyCode
cmpq    $0x1C, %rax               #Compare 12 with the PS2 scan code from the keyboard
je      startGame                 #If there is a "enter" keystroke, the game starts  

cmpq    $0x13, %rax               #Compare 12 with the PS2 scan code from the keyboard
je      gameRulePage              #If r has been pressed, then go to the rule page

cmpq    $0x48, %rax                #Compare 12 with the PS2 scan code from the keyboard
je      moveUp                     #If there is a "↑" keystroke, the game starts 

cmpq    $0x50, %rax                #Compare 12 with the PS2 scan code from the keyboard
je      moveDown                   #If there is a "↓" keystroke, the game starts 

cmpq    $0x4B, %rax                #Compare 12 with the PS2 scan code from the keyboard
je      moveLeft                   #If there is a "<-" keystroke, the game starts 

cmpq    $0x4D, %rax                #Compare 12 with the PS2 scan code from the keyboard
je      moveRight                  #If there is a "->" keystroke, the game starts 

cmpq    $0x25, %rax
je      newGame


jmp     end

#=================================== MOVE UP ============================================
moveUp:

movq     $matrix, %rdi            #Data matrix
movq     $0, %rsi                 #Starting point for searching
call     moveUP

movq     $matrix, %rdi            #Data matrix
call     gridRepaint

call     printScore               #Prints the total game score

movq    $matrix, %rdi
movq    $-1, %rax
call    checkState

cmpq    $0, %rax
je      end

cmpq    $-1, %rax
je      losePage


cmpq    $1, %rax
je      winPage

jmp     end



#=================================== MOVE DOWN ============================================

moveDown:

movq     $matrix, %rdi            #Data matrix
movq     $15, %rsi                #Starting point for searching
call     moveDOWN

movq     $matrix, %rdi            #Data matrix
call     gridRepaint

call     printScore

movq    $matrix, %rdi
movq    $-1, %rax
call    checkState

cmpq    $0, %rax
je      end

cmpq    $-1, %rax
je      losePage


cmpq    $1, %rax
je      winPage

jmp     end



#=================================== MOVE LEFT ============================================

moveLeft:

movq     $matrix, %rdi            #Data matrix
movq     $0, %rsi                 #Starting point for searching
call     moveLEFT

movq     $matrix, %rdi
call     gridRepaint

call     printScore

movq    $matrix, %rdi
movq    $-1, %rax
call    checkState

cmpq    $0, %rax
je      end

cmpq    $-1, %rax
je      losePage


cmpq    $1, %rax
je      winPage

jmp     end



#=================================== MOVE RIGHT ============================================

moveRight:

movq     $matrix, %rdi            #Data matrix
movq     $15, %rsi                #Starting point for searching
call     moveRIGHT

movq     $matrix, %rdi            #Data matrix
call     gridRepaint

call     printScore   

movq    $matrix, %rdi
movq    $-1, %rax
call    checkState

cmpq    $0, %rax
je      end

cmpq    $-1, %rax
je      losePage


cmpq    $1, %rax
je      winPage

jmp     end

#================================== START GAME ========================================

startGame:
movq    $0, %rdi                   #First parameter: x-coordinate of the pixel
movq    $0, %rsi                   #Second parameter: y-coordinate of the pixel
call    clearScreen  


movq    $18, %rdi                  #First parameter: x-coordinate of the pixel         
movq    $0, %rsi                   #Second parameter: y-coordinate of the pixel
call    drawGrid


movq     $matrix, %rdi
call     gridRepaint

jmp      end

#================================ LOSE PAGE ========================================

losePage:

cmpq    %r10, %r9
jg      updateBestScore
jl      noUpdate

updateBestScore:
movq    %r9, %r10


noUpdate:

call    printGameOver

jmp     end



#=============================== WIN PAGE ========================================

winPage:

cmpq    %r10, %r9
jg      updateBestScore2
jl      noUpdate2

updateBestScore2:
movq    %r9, %r10


noUpdate2:

call   printWinPage

jmp     end


#================================ NEW GAME ========================================

newGame:

movq    $0, %r9
pushq   %r10

movq    $0, %rdi                   #First parameter: x-coordinate of the pixel
movq    $0, %rsi                   #Second parameter: y-coordinate of the pixel
call    clearScreen  

movq    $18, %rdi                  #First parameter: x-coordinate of the pixel         
movq    $0, %rsi                   #Second parameter: y-coordinate of the pixel
call    drawGrid

movq    $matrix, %rdi
call    clearValues


#Initialize the grid with two tiles at two random positions in the grid
movq    $matrix, %rdi
call    generateRandomTile

movq    $matrix, %rdi
call    generateRandomTile

movq     $matrix, %rdi            #Data matrix
call     gridRepaint

popq    %r10
call     printBestScore

jmp     end




#================================= RULE PAGE ========================================
gameRulePage:

call    printRulePage             #Prints the rule of the game

jmp     end

end:

movq    %rbp, %rsp 
popq    %rbp
ret



#=============================================SUBROUTINES==============================================



#==========================================
#This subroutine clears the terminal with #
#while background color                   #   
#                                         #  
#==========================================

clearScreen:

pushq   %rbp
movq    %rsp, %rbp

pushq   %r15 
pushq   %rbx

movq    %rdi, %r15                 #Copy the x-coordinate to R15              
movq    %rsi, %rbx                 #Copy the y-coordinate to RBX

clear:

movq    %r15, %rdi                 #First parameter: x coordinate(which column in the terminal)
movq    %rbx, %rsi                 #Second parameter: y coordinate(which row in the terminal)
movb    $0, %dl                   #No letter needs to be printed
movb    $0xFF, %cl                #Fourth parameter: background color
call    putChar

incq    %r15                       #Go to the next horizontal pixel
cmpq    $80, %r15                  #If we haven't reached the end of the terminal, continue loop   
jne     clear                     #Clear each columns

movq    $0, %r15                   #Reset R15
incq    %rbx                       #Go the the next row and start clean
cmpq    $25, %rbx                  #If we haven't reached the end of the terminal, continue loop 
jne     clear                     #Clear each rows

popq    %rbx
popq    %r15


movq    %rbp, %rsp 
popq    %rbp
ret


#=========================================
#This subroutine prints the menu page    #
#                                        #
#=========================================

printMenu:

pushq   %rbp
movq    %rsp, %rbp

#print the menu page

movq    $38, %rdi                 #First patameter: x-coordinate of the pixel
movq    $6, %rsi                  #Second parameter: y-coordinate of the pixel
movq    $titleString, %rdx        #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string
call    printString

movq    $25, %rdi                 #First patameter: x-coordinate of the pixel  
movq    $16, %rsi                 #Second parameter: y-coordinate of the pixel
movq    $startString, %rdx        #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string
call    printString

movq    $20, %rdi                 #First patameter: x-coordinate of the pixel       
movq    $18, %rsi                 #Second parameter: y-coordinate of the pixel
movq    $ruleString, %rdx         #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string   
call    printString

movq    %rbp, %rsp 
popq    %rbp
ret


#=========================================
#This subroutine prints the rule page    #
#                                        #
#=========================================

printRulePage:

pushq   %rbp
movq    %rsp, %rbp

movq    $0, %rdi                  #First parameter: x-coordinate of the pixel
movq    $0, %rsi                  #Second parameter: y-coordinate of the pixel
call    clearScreen  

movq    $18, %rdi                 #First patameter: x-coordinate of the pixel  (column)
movq    $6, %rsi                  #Second parameter: y-coordinate of the pixel (row)
movq    $rule1, %rdx              #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: color of the character
call    printString


movq    $18, %rdi                 #First patameter: x-coordinate of the pixel
movq    $8, %rsi                  #Second parameter: y-coordinate of the pixel
movq    $rule2, %rdx              #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: color of the character
call    printString

movq    $18, %rdi                 #First patameter: x-coordinate of the pixel
movq    $10, %rsi                 #Second parameter: y-coordinate of the pixel
movq    $rule3, %rdx              #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: color of the character  
call    printString

movq    $18, %rdi                 #First patameter: x-coordinate of the pixel
movq    $12, %rsi                 #Second parameter: y-coordinate of the pixel
movq    $rule4, %rdx              #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: color of the character 
call    printString

movq    $25, %rdi                 #First patameter: x-coordinate of the pixel
movq    $18, %rsi                 #Second parameter: y-coordinate of the pixel
movq    $startString, %rdx        #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: color of the character 
call    printString


movq    %rbp, %rsp 
popq    %rbp
ret



#=========================================
#This subroutine prints the win page     #
#                                        #
#=========================================

printWinPage:

pushq   %rbp
movq    %rsp, %rbp

#prints the win page

movq    $0, %rdi                   #First parameter: x-coordinate of the pixel
movq    $0, %rsi                   #Second parameter: y-coordinate of the pixel
call    clearScreen  

movq    $20, %rdi                 #First patameter: x-coordinate of the pixel
movq    $5, %rsi                  #Second parameter: y-coordinate of the pixel
movq    $winString, %rdx        #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string
call    printString

movq    $29, %rdi                 #First patameter: x-coordinate of the pixel  
movq    $12, %rsi                 #Second parameter: y-coordinate of the pixel
movq    $scoreString, %rdx        #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string
call    printString

movq    $25, %rdi                 #First patameter: x-coordinate of the pixel       
movq    $18, %rsi                 #Second parameter: y-coordinate of the pixel
movq    $newGameString, %rdx         #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string   
call    printString

call    printFinalScore

movq    %rbp, %rsp 
popq    %rbp
ret



#===========================================
#This subroutine prints the game over page #
#                                          #
#===========================================

printGameOver:

pushq   %rbp
movq    %rsp, %rbp

#prints the game over page

movq    $0, %rdi                   #First parameter: x-coordinate of the pixel
movq    $0, %rsi                   #Second parameter: y-coordinate of the pixel
call    clearScreen  

movq    $34, %rdi                 #First patameter: x-coordinate of the pixel
movq    $6, %rsi                  #Second parameter: y-coordinate of the pixel
movq    $gameOverString, %rdx        #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string
call    printString

movq    $29, %rdi                 #First patameter: x-coordinate of the pixel  
movq    $12, %rsi                 #Second parameter: y-coordinate of the pixel
movq    $scoreString, %rdx        #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string
call    printString

movq    $25, %rdi                 #First patameter: x-coordinate of the pixel       
movq    $18, %rsi                 #Second parameter: y-coordinate of the pixel
movq    $newGameString, %rdx         #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string   
call    printString

call    printFinalScore

movq    %rbp, %rsp 
popq    %rbp
ret


#=========================================
#This subroutine prints the input String #
#                                        #
#=========================================

printString: 

pushq   %rbp
movq    %rsp, %rbp

pushq   %r15 
pushq   %rbx


movq    %rdi, %rbx                 #Copy the x-coordinate to RBX
movq    %rsi, %r8                #Copy the y-coordiante to R8
movq    %rdx, %r15                 #Copy the input string to R15
 
printingLoop:

movq    %rbx, %rdi                 #First parameter: x-coordinate
movq    %r8, %rsi                #Second parameter: y-coordinate
movb    (%r15), %dl                #Thid parameter: to be printed character   
                                  #Fourth parameter: the color of the character
call    putChar

incq    %rbx                       #Go to the next horizontal pixel
incq    %r15                       #Get the next character
cmpb    $0, (%r15)                 #If it is not 0x00, then we print it
jne     printingLoop

popq    %rbx
popq    %r15
 
movq    %rbp, %rsp               
popq    %rbp
ret


#============================================
#This subtoutine draws the grid of the game #
#                                           #
#============================================

drawGrid:

pushq   %rbp
movq    %rsp, %rbp

pushq   %r15 
pushq   %rbx

movq    %rdi, %r15                 #Copy the x-coordinate to R15
movq    %rsi, %rbx                 #Copy the y-coordinate to RBX

drawLoop1:
movq    %r15, %rdi                 #First parameter: x-coordinate
movq    %rbx, %rsi                 #Second parameter: y-coordinate
movb    $0, %dl                   #Thid parameter: no character needs to be printed
movb    $0x66, %cl                #Fourth parameter: the color of the grid
call    putChar

incq    %r15                       #Go to the next horizontal pixel       
cmpq    $61, %r15                  #If we haven't done yet, continue looping
jne     drawLoop1                 #Draw the columns

movq    $18, %r15                  #Reset R15     
incq    %rbx                       #Go to the next row
cmpq    $25, %rbx                  #If we haven't done yet, continue looping
jne     drawLoop1                 #Draw the rows

popq    %rbx
popq    %r15


movq    %rbp, %rsp 
popq    %rbp
ret 


#============================================
#This subtoutine draws 16 empty tiles when  #
#the game starts                            #
#============================================

gridRepaint:  #Prints the whole game grid in one time

pushq   %rbp
movq    %rsp, %rbp

pushq   %r15

movq    $0, %r15                    #Clear R15
movq    $0, %rsi                   #Clear RSI (the index of the matrix)

gridTraversal:

movw    (%rdi, %rsi, 2), %r15w      #Get the next number in the matrix
cmpw    $0, %r15w                   #Check if it's 0
je      draw1   #empty tile        #If it is 0, then that tile should be empty

 
movq    $4, %r11                   #This part calculates the x and y coordinate 
movq    %rsi, %rax                 #of the tile, x in RAX and y in RDX
movq    $0, %rdx                   #(number between 0 and 15) / 4
divq    %r11                       #we will always get a number between 0 and 3

pushq   %rdi                       #Push the address fo the matrix onto stack
pushq   %rsi                       #Push RSI(the index of the matrix) 
pushq   %rax

movq    $0, %rdi                   #Clear RDI
movw    %r15w, %di                  #Copy the value of this index in the array into RDI
call    decideColor                #Call the subroutine decideColor
movq    %rax, %rcx                 #Copy the return value into RCX (4th parameter)

popq    %rax
movq    %rdx, %rdi                 #Copy the y coordinate(which column) into RDI      
movq    %rax, %rsi                 #Copy the x coordinate(which row) into RSI
movq    $0, %rdx                   #No letter needs to be printed
                                   #5th parameter is alreay in R15, for deciding which value string to print
                                  
call    drawTile
popq    %rsi       
popq    %rdi

incq    %rsi                       #Increase the index 
cmpq    $16, %rsi                  #Compare the index with 16 
jne     gridTraversal              #If not equal then we need to draw more
je      endRepaint 

draw1:
movq    $4, %r11                   #This part calculates the x and y coordinate    
movq    %rsi, %rax                 #of the tile, x in RAX and y in RDX
movq    $0, %rdx                   #(number between 0 and 15) / 4
divq    %r11                       #We will always get a number between 0 and 3

pushq   %rdi                       #Save the address of the matrix before draw the tile
pushq   %rsi                       #Save the index before draw the tile

movq    %rdx, %rdi                 #First parameter: the x-coordinate of the tile
movq    %rax, %rsi                 #Second parameter: the y-coordinate of the tile
movq    $0, %rdx                   #Third parameter: no letter needs to be printed
movq    $0xFF, %rcx                #Fourth parameter: foreground and background color of the tile 
call    drawTile

popq    %rsi 
popq    %rdi 

incq    %rsi                       #Increase the index            
cmpq    $16, %rsi                  #Compare the index with 16 
jne     gridTraversal              #If not equal then we need to draw more 
je      endRepaint

endRepaint:

popq    %r15

movq    %rbp, %rsp 
popq    %rbp
ret 


#==================================================
#This subroutine initializes the tile in the grid #
#when the games starts                            #  
#                                                 #
#==================================================

drawTile: #draws one tile each time

pushq   %rbp 
movq    %rsp, %rbp

pushq   %r12
pushq   %r13                      
pushq   %r14
pushq   %r15
pushq   %rbx

movq    $0, %r12
movw    %r15w, %r12w               #Copy the tile value into R12

#==============================================================
#Calculates automatically the x and y coordinate of the given Tile[x][y]
#Formula x-coordinate: 20 + 10 * column number

movq    $10, %rax                 
mulq    %rdi                      #The column number
addq    $20, %rax 
movq    %rax, %rdi                #The x-coordinate (the column) in RDI


#Formula y-coordinate: 1 + 6 * row number

movq    $6, %rax
mulq    %rsi                      #The row number  
addq    $1, %rax 
movq    %rax, %rsi                #The y-coordinate (the row) in RSI

pushq   %rdi
pushq   %rsi
#=============================================================

movq    %rdi, %r15                 #Copy the x-coordinate to R15
movq    %rdi, %r14                #Copy the x-coordinate to R15 for resetting R15
movq    %rsi, %rbx                 #Copy the y-coordinate to RBX

#set square dim
movq    %r15, %r8                 #Copy the x-coordinate to R8
addq    $9, %r8                  #Width of a tile(always 9) in R8
movq    %rbx, %r11                 #Copy the y-coordinate to R11
addq    $5, %r11                  #Length of a tile(always 5) in R11

drawLoop2:
movq    %r15, %rdi                 #First parameter: x-coordinate(column)
movq    %rbx, %rsi                 #Sedond parameter: y-coordinate(row)
                                  #Third parameter: to be printed value (comes from function call)
                                  #Fourth parameter: color of the background and value (comes from function call)
call    putChar


incq    %r15                       #Go to the next horizontal pixel
cmpq    %r8, %r15                 #If we haven't done yet, continue looping
jne     drawLoop2                 #Draw the columns

movq    %r14, %r15                 #Reset R15
incq    %rbx                       #Go to the next row
cmpq    %r11, %rbx                 #If we haven't done yet, continue looping
jne     drawLoop2                 #Draw the rows


drawValueString: #Prints the value of the corresponding tile

movq    %r12, %rdi                #Copy the tile value into RDI
call    decidesString             #Call the subroutine decidesString
movq    %rax, %rdx                #Copy the return value into RDX(input String)

popq    %rsi
popq    %rdi

cmpq    $10, %r12                 #Compare the tile value with 10
jl      oneDigit                  #If less then go to oneDigit  


addq    $3, %rdi                  #Determine the horizontal position of 2 or 3 or 4 digits
jmp     printTileValue               

oneDigit: 
addq    $4, %rdi                  #Determine the horizontal position of 1 digit
jmp     printTileValue


printTileValue:
                                  #First patameter: x-coordinate of the pixel (already in RDI)
addq    $2, %rsi                  #Second parameter: y-coordinate of the pixel
                                  #Third parameter is already in RDX
                                  #Fourth parameter is already in RCX, the digit has the same background color and the character color is always white(F)   
call    printString             


#Draws the scoreboards
movq    $5, %rdi                  #First patameter: x-coordinate of the pixel
movq    $2, %rsi                  #Second parameter: y-coordinate of the pixel
movq    $bestScore, %rdx          #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string
call    printString

movq    $63, %rdi                 #First patameter: x-coordinate of the pixel
movq    $2, %rsi                  #Second parameter: y-coordinate of the pixel
movq    $currentScore, %rdx       #Third parameter: input string
movq    $0xF6, %rcx               #Fourth parameter: foreground and background color of the string
call    printString

popq    %rbx
popq    %r15
popq    %r14
popq    %r13
popq    %r12

movq    %rbp, %rsp 
popq    %rbp 
ret


#=====================================================
#This subroutine generates a random tile in the      #
#matrix(background)                                  #
#                                                    #  
#=====================================================

generateRandomTile:

pushq   %rbp
movq    %rsp, %rbp

pushq   %r12
pushq   %r15
pushq   %rbx    
#========================================decides 2 or 4 for the new tile value

randomNumber1:

movq    $10, %r15                #Copy 10 into R15
movq    $0, %rbx                 #Clear RBX
movq    $0, %rsi                #clear RSI

rdtsc                           #Get current timestamp (saved in RAX)
shr     $8, %rax                #Make the number more random

movb    %al, %bl               #Copy the generated byte into RBX
movq    %rbx, %rax               #Copy the dividend into RAX
movq    $0, %rdx
divq    %r15                     #Generates a random numeber between 0 - 9

cmpq    $0, %rdx                #Compare the random number with 0
jne     setValueTile            #If not equal, we set the value as 2
movq    $4, %r12                #Makes the game not too easy, if equal, then set the value to 4
jmp     randomNumber2

setValueTile:

movq    $2, %r12                #Copy the generated value into R12


#========================================decides location for the new tile

randomNumber2: 

movq    $16, %r15                #Copy 16 into R15
movq    $0, %rbx                 #Clear RBX

rdtsc                           #Get current timestamp (saved in RAX)
shr     $8, %rax                #Make the number more random

movb    %al, %bl               #Copy the generated byte into RBX
movq    %rbx, %rax               #Copy the dividend into RAX
movq    $0, %rdx
divq    %r15                     #Generates a random numeber between 0 - 15, as the index of the matrix

#===============make sure that if there is already a tile at this location, we don't add a new one in this location

movq    $0, %r8        #clear R8
movw    (%rdi, %rdx, 2), %r8w    
cmpw    $0, %r8w
jne     randomNumber2

findIndex:

cmpq    %rdx, %rsi              #Compare RSI with the random number
je      setValueMatrix          #If equal then go to that index in the matrix       

incq    %rsi                    #If not equal then we continue to find that index
jmp     findIndex   

setValueMatrix: #Set the generated value into the matrix

movw    %r12w, (%rdi, %rsi, 2)

popq    %rbx
popq    %r15    
popq    %r12

movq    %rbp, %rsp 
popq    %rbp
ret


#=====================================================
#This subroutine moves or merges the tiles (Move up) #          
#                                                    # 
#=====================================================

moveUP:

pushq   %rbp
movq    %rsp, %rbp 


pushq   %r12
pushq   %r13 
pushq   %r14
pushq   %r15
pushq   %rbx

#RSI = index counter of the matrix, always start at INDEX[0]
#RAX = flag register to check the game state

#R15 = potential "previous tile value" in the matrix
#RBx = location in the matrix, special for processing
#R8 = potential "next tile value"
#R11 = location in the matrix, special for processing
#R12 = flag register to check the game state
#R13 = flag register to check if we have moved or merged a tile
#R14 = flag register to set if merging happend at a specific location



movq    $0, %r8                #Clear R8
movq    $0, %r11                #Clear R11      
movq    $0, %r13                #Clear R13
movq    $0, %r14                #Clear R14
movq    $0, %r15                #Clear R15


looping:

movw    (%rdi, %rsi, 2), %r15w   #Copy the value in the matrix to R15
cmpw    $0, %r15w                #Check if the value is 0
je      getNextValue            #If 0 we continue looping until we get the first non-zero value
jne     processing              #Otherwise we process it


getNextValue:

incq    %rsi                    #Go to the next location in the matrix
cmpq    $16, %rsi               #If 16, we are done 
je      endMoveUp1              #Jump to end
jne     looping


processing:

movq   %rsi, %rbx                #Copy the current(previous) location, so we can use RSI again after processing
movq   %rsi, %r11               #Copy the location to R11 as well

processingLoop:

subq   $4, %rbx                  #Go the previous row, because we are moving up
cmpq   $0, %rbx                  #Check if we are still in the matrix
jl     getNextValue             #If not, then we are at the top of the matrix and we don't move up and go back

movw   (%rdi, %rbx, 2), %r8w    #Copy the next tile value into R8

cmpw   $1, %r8w                #Check if that value is one
je     ifOneCase                #If one, we treat it in the same way as zero, but then stop merging

cmpw   $0, %r8w                #Check if that value is zero
je     ifZeroCase               #If zero, we move the previous tile one level up
jne    elseIfCase               #If not zero, we check if we can merge the tiles


ifZeroCase:

movw    %r15w, (%rdi, %rbx, 2)    #Move the "previous tile value" one level up
movw    %r8w, (%rdi, %r11, 2)  #Reset the "previous tile" to empty
movq    %rbx, %r11               #Update the location
movq     $1, %r13
jmp     processingLoop          #We need to check if we have more tiles above us


ifOneCase:

movq    $1, %r13                #Change flag register, means we have successfully moved 
movw    %r15w, (%rdi, %rbx, 2)    #Move the "previous tile value" one level up
movq    $0, %r8
movw    %r8w, (%rdi, %r11, 2)  #Set the flag bit to the previous tile
movq    %rbx, %r11

subq    $4, %rbx                 #Go the previous row, because we are moving up
cmpq    $0, %rbx                 #Check if we are still in the matrix
jl     getNextValue             #If not, then we are at the top of the matrix and we don't move up and go back

moreZeros:

movw    (%rdi, %rbx, 2), %r8w   #Check if there are more zeros above the current 1 value location
cmpw    $0, %r8w               #If there are more zeros, we need to treat them as 1
je      ifOneCase


jmp     getNextValue            #We dont't merge again at this location in the same move, so we go back


elseIfCase: #Check if we can merge tiles

cmpw    %r8w, %r15w             #Compare the values of two tiles 
je      merging                 #If they are equal, they can be merged
jne     elseCase                #Otherwise go back


#===========If merged, set the merged value to the lower tile and set a flag bit to the higer tile
merging:

addw    %r8w, %r15w             #Value *= 2
addq    %r15, %r9                #Record the score
movw    %r15w, (%rdi, %r11, 2)   #Merging and save to the current level(because moving up)
movw    $1, %r14w               #Set flag bit
movw    %r14w, (%rdi, %rbx, 2)   #Copy flag bit to the location

#===============Set an extra flag bit to the tile below the lower tile if it's 0
addq    $8, %rbx                 #Go to 2 tiles below

movw    (%rdi, %rbx, 2), %r8w   #We check if there is a zero
cmpw    $0, %r8w                   
jne     endMerging              #If it's not zero then we don't need to set this extra bit

movw    $1, %r14w               #Set flag bit
movw    %r14w, (%rdi, %rbx, 2)   #Copy flag bit to the location

#movq   #Current score to 


endMerging:
subq    $4, %rbx                 #Reset RBX to the lower tile

movq    $1, %r13                #Set flag register
jmp     processingLoop


elseCase:

jmp     getNextValue


endMoveUp1:

cmpq    $1, %r13                #Check if we had a valid move or merge
jne     endMoveUp2

movq    $matrix, %rdi           #Clear all flag bits after one move
call    clearFlagBit

movq    $matrix, %rdi           #If we had a valid move, there will be another random tile added into the grid
call    generateRandomTile 




endMoveUp2:

popq    %rbx
popq    %r15
popq    %r14
popq    %r13
popq    %r12

movq    %rbp, %rsp 
popq    %rbp
ret




#======================================================
#This subroutine moves or merges the tiles (Move down)#          
#                                                     # 
#======================================================


moveDOWN:

pushq   %rbp
movq    %rsp, %rbp 


pushq   %r12
pushq   %r13 
pushq   %r14
pushq   %r15
pushq   %rbx

#RSI = index counter of the matrix, always start at INDEX[15]
#RAX = flag register to check the game state

#R15 = potential "previous tile value" in the matrix
#RBX = location in the matrix, special for processing
#R8 = potential "next tile value"
#R11 = location in the matrix, special for processing
#R12 = flag register to check the game state
#R13 = flag register to check if we have moved or merged a tile
#R14 = flag register to set if merging happend at a specific location



movq    $0, %r8                #Clear R8
movq    $0, %r11                #Clear R11       
movq    $0, %r13                #Clear R13
movq    $0, %r14                #Clear R14
movq    $0, %r15                #Clear R15


loopingDown:

movw    (%rdi, %rsi, 2), %r15w   #Copy the value in the matrix to R15
cmpw    $0, %r15w                #Check if the value is 0
je      getNextValueDown        #If 0 we continue looping until we get the first non-zero value
jne     processingDown          #Otherwise we process it


getNextValueDown:

decq    %rsi                    #Go to the next location in the matrix
cmpq    $-1, %rsi               #If < 0(we started at 15), we are done 
je      endMoveDOWN1            #Jump to end
jne     loopingDown


processingDown:

movq   %rsi, %rbx                #Copy the current(previous) location, so we can use RSI again after processing
movq   %rsi, %r11               #Copy the location to R11 as well

processingLoopDown:

addq   $4, %rbx                  #Go the next row, because we are moving down
cmpq   $15, %rbx                 #Check if we are still in the matrix
jg     getNextValueDown         #If not, then we are at the bottom of the matrix and we don't move down and go back

movw   (%rdi, %rbx, 2), %r8w    #Copy the next tile value into R8

cmpw   $1, %r8w                #Check if that value is one
je     ifOneCaseDown            #If one, we treat it in the same way as zero, but then stop merging

cmpw   $0, %r8w                #Check if that value is zero
je     ifZeroCaseDown           #If zero, we move the previous tile one level down
jne    elseIfCaseDown           #If not zero, we check if we can merge the tiles


ifZeroCaseDown:

movw    %r15w, (%rdi, %rbx, 2)    #Move the "previous tile value" one level down
movw    %r8w, (%rdi, %r11, 2)  #Reset the "previous tile" to empty
movq    %rbx, %r11               #Update the location
movq    $1, %r13                #Valid move, set up flag register
jmp     processingLoopDown      #We need to check if we have more tiles below us


ifOneCaseDown:

movq    $1, %r13                #Change flag register, means we have successfully moved 
movw    %r15w, (%rdi, %rbx, 2)    #Move the "previous tile value" one level down
movq    $0, %r8
movw    %r8w, (%rdi, %r11, 2)  #Clear the previous tile
movq    %rbx, %r11

addq    $4, %rbx                 #Go the next row, because we are moving down
cmpq    $15, %rbx                #Check if we are still in the matrix
jg     getNextValueDown         #If not, then we are at the bottom of the matrix and we don't move down and go back

moreZerosDown:

movw    (%rdi, %rbx, 2), %r8w   #Check if there are more zeros below the current 1 value location
cmpw    $0, %r8w               #If there are more zeros, we need to treat them as 1
je      ifOneCaseDown


jmp     getNextValueDown        #We dont't merge again at this location in the same move, so we go back


elseIfCaseDown: #Check if we can merge tiles

cmpw    %r8w, %r15w             #Compare the values of two tiles 
je      mergingDown             #If they are equal, they can be merged
jne     elseCaseDown            #Otherwise go back


#===========If merged, set the merged value to the lower tile and set a flag bit to the higer tile
mergingDown:


addw    %r8w, %r15w             #Value *= 2
addq    %r15, %r9                #Record the score
movw    %r15w, (%rdi, %r11, 2)   #Merging and save to the current level(because moving down)
movw    $1, %r14w               #Set flag bit
movw    %r14w, (%rdi, %rbx, 2)   #Copy flag bit to the location

#===============Set an extra flag bit to the tile below the lower tile if it's 0
subq    $8, %rbx                 #Go to 2 tiles above

movw    (%rdi, %rbx, 2), %r8w   #We check if there is a zero
cmpw    $0, %r8w                   
jne     endMergingDown          #If it's not zero then we don't need to set this extra bit

movw    $1, %r14w               #Set flag bit
movw    %r14w, (%rdi, %rbx, 2)   #Copy flag bit to the location


endMergingDown:
addq    $4, %rbx                 #Reset RBX to the higher tile

movq    $1, %r13                #Set flag register
jmp     processingLoopDown


elseCaseDown:

jmp     getNextValueDown

endMoveDOWN1:

cmpq    $1, %r13                #Check if we had a valid move or merge
jne     endMoveDOWN2

movq    $matrix, %rdi           #Clear all flag bits after one move
call    clearFlagBit

movq    $matrix, %rdi           #If we had a valid move, there will be another random tile added into the grid
call    generateRandomTile 


endMoveDOWN2:

popq    %rbx
popq    %r15
popq    %r14
popq    %r13
popq    %r12

movq    %rbp, %rsp 
popq    %rbp
ret



#======================================================
#This subroutine moves or merges the tiles (Move left)#          
#                                                     # 
#======================================================

moveLEFT:

pushq   %rbp
movq    %rsp, %rbp 


pushq   %r12
pushq   %r13 
pushq   %r14
pushq   %r15
pushq   %rbx

#RSI = index counter of the matrix, always start at INDEX[12]
#RAX = flag register to check the game state

#R15 = potential "previous tile value" in the matrix
#RBX = location in the matrix, special for processing
#R8 = potential "next tile value"
#R11 = location in the matrix, special for processing
#R12 = flag register to check the game state
#R13 = flag register to check if we have moved or merged a tile
#R14 = flag register to set if merging happend at a specific location


movq    $0, %r8               #Clear R8
movq    $0, %r11               #Clear R11      
movq    $0, %r13               #Clear R13
movq    $0, %r14               #Clear R14
movq    $0, %r15               #Clear R15


loopingLeft:

movw    (%rdi, %rsi, 2), %r15w  #Copy the value in the matrix to R15
cmpw    $0, %r15w               #Check if the value is 0
je      getNextValueLeft           #If 0 we continue looping until we get the first non-zero value
jne     processingLeft             #Otherwise we process it


getNextValueLeft:

addq    $4, %rsi               #Go to the next location in the matrix

cmpq    $16, %rsi              #We traverse vertically instead of horizontally
je      case12Left                 #So we have to make sure to jump the next column for traversing

cmpq    $17, %rsi              #Check if we are done with the second column
je      case13Left

cmpq    $18, %rsi              #Check if we are done with the third column
je      case14Left

cmpq    $19, %rsi              #Check if we are done with the last column
je      endCase2Left

jmp     endCase1Left

case12Left:
movq    $1, %rsi               #Go to the second column
jmp     endCase1Left


case13Left:
movq    $2, %rsi               #Go to the third column
jmp     endCase1Left


case14Left:
movq    $3, %rsi               #Go to the fourth column
jmp     endCase1Left


endCase1Left:

jmp     loopingLeft            #We continue looping

endCase2Left:
jmp      endMoveLeft1          #Jump to end

processingLeft:
movq   %rsi, %rbx               #Copy the current(previous) location, so we can use RSI again after processing
movq   %rsi, %r11              #Copy the location to R11 as well

processingLoopLeft:

cmpq   $3, %rsi  
jle    lessOrEqual3Left        #Check corner case 1            


cmpq   $11, %rsi
jg     greaterThan11Left       #Check corner case 2


cmpq   $7, %rsi
jg     greaterThan7Left        #Check corner case 3


cmpq   $3, %rsi                #Check corner case 4
jg     greaterThan3Left


lessOrEqual3Left:
subq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $0, %rbx                 #Check if we are still in the matrix
jl     getNextValueLeft        #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    realProcessLeft


greaterThan3Left:
subq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $4, %rbx                 #Check if we are still in the matrix
jl     getNextValueLeft        #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    realProcessLeft

greaterThan7Left:
subq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $8, %rbx                 #Check if we are still in the matrix
jl     getNextValueLeft        #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    realProcessLeft

greaterThan11Left:
subq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $12, %rbx                #Check if we are still in the matrix
jl     getNextValueLeft        #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    realProcessLeft

realProcessLeft:

movw   (%rdi, %rbx, 2), %r8w   #Copy the next tile value into R8

cmpw   $1, %r8w               #Check if that value is zero
je     ifOneCaseLeft           #If zero, we treat it in the same way as zero, but then stop merging

cmpw   $0, %r8w               #Check if that value is zero
je     ifZeroCaseLeft          #If zero, we move the previous tile one level left
jne    elseIfCaseLeft          #If not zero, we check if we can merge the tiles


ifZeroCaseLeft:

movw    %r15w, (%rdi, %rbx, 2)   #Move the "previous tile value" one step left
movw    %r8w, (%rdi, %r11, 2) #Reset the "previous tile" to empty
movq    %rbx, %r11              #Update the location
movq    $1, %r13               #Valid move, set up register
jmp     processingLoopLeft     #We need to check if we have more tiles are to the left of us


ifOneCaseLeft:

movq    $1, %r13               #Change flag register, means we have successfully moved 
movw    %r15w, (%rdi, %rbx, 2)   #Move the "previous tile value" one level left
movq    $0, %r8
movw    %r8w, (%rdi, %r11, 2) #Set the flag bit to the previous tile
movq    %rbx, %r11

cmpq   $3, %rsi  
jle    lessOrEqual3Left1       #Check corner case 1            


cmpq   $11, %rsi
jg     greaterThan11Left1      #Check corner case 2


cmpq   $7, %rsi
jg     greaterThan7Left1       #Check corner case 3


cmpq   $3, %rsi                #Check corner case 4
jg     greaterThan3Left1


lessOrEqual3Left1:
subq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $0, %rbx                 #Check if we are still in the matrix
jl     getNextValueLeft        #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    moreZerosLeft

greaterThan3Left1:
subq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $4, %rbx                 #Check if we are still in the matrix
jl     getNextValueLeft        #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    moreZerosLeft

greaterThan7Left1:
subq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $8, %rbx                 #Check if we are still in the matrix
jl     getNextValueLeft        #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    moreZerosLeft

greaterThan11Left1:
subq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $12, %rbx                #Check if we are still in the matrix
jl     getNextValueLeft        #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    moreZerosLeft


moreZerosLeft:

movw    (%rdi, %rbx, 2), %r8w  #Check if there are more zeros to the left of the current 1 value location
cmpw    $0, %r8w              #If there are more zeros, we need to treat them as 1
je      ifOneCaseLeft


jmp     getNextValueLeft       #We dont't merge again at this location in the same move, so we go back


elseIfCaseLeft: #Check if we can merge tiles

cmpw    %r8w, %r15w            #Compare the values of two tiles 
je      mergingLeft            #If they are equal, they can be merged
jne     elseCaseLeft           #Otherwise go back


#===========If merged, set the merged value to the lower tile and set a flag bit to the higer tile
mergingLeft:

addw    %r8w, %r15w             #Value *= 2
addq    %r15, %r9                #Record the score
movw    %r15w, (%rdi, %r11, 2)   #Merging and save to the current level(because moving up)
movw    $1, %r14w               #Set flag bit
movw    %r14w, (%rdi, %rbx, 2)   #Copy flag bit to the location

#===============Set an extra flag bit to the tile below the lower tile if it's 0
addq    $2, %rbx                 #Go to 2 tiles to the right

movw    (%rdi, %rbx, 2), %r8w   #We check if there is a zero
cmpw    $0, %r8w                   
jne     endMergingLeft          #If it's not zero then we don't need to set this extra bit

movw    $1, %r14w               #Set flag bit
movw    %r14w, (%rdi, %rbx, 2)   #Copy flag bit to the location


endMergingLeft:
subq    $1, %rbx                 #Reset RBX to the lower tile

movq    $1, %r13                #Set flag register
jmp     processingLoopLeft


elseCaseLeft:

jmp     getNextValueLeft



endMoveLeft1:

cmpq    $1, %r13                #Check if we had a valid move or merge
jne     endMoveLeft2

movq    $matrix, %rdi           #Clear all flag bits after one move
call    clearFlagBit

movq    $matrix, %rdi           #If we had a valid move, there will be another random tile added into the grid
call    generateRandomTile 


endMoveLeft2:

popq    %rbx
popq    %r15
popq    %r14
popq    %r13
popq    %r12

movq    %rbp, %rsp 
popq    %rbp
ret

#=======================================================
#This subroutine moves or merges the tiles (Move right)#          
#                                                      # 
#=======================================================


moveRIGHT:

pushq   %rbp
movq    %rsp, %rbp 


pushq   %r12
pushq   %r13 
pushq   %r14
pushq   %r15
pushq   %rbx

#RSI = index counter of the matrix, always start at INDEX[12]
#RAX = flag register to check the game state

#R15 = potential "previous tile value" in the matrix
#RBX = location in the matrix, special for processing
#R8 = potential "next tile value"
#R11 = location in the matrix, special for processing
#R12 = flag register to check the game state
#R13 = flag register to check if we have moved or merged a tile
#R14 = flag register to set if merging happend at a specific location



movq    $0, %r8               #Clear R8
movq    $0, %r11               #Clear R11      
movq    $0, %r13               #Clear R13
movq    $0, %r14               #Clear R14
movq    $0, %r15               #Clear R15


loopingRight:

movw    (%rdi, %rsi, 2), %r15w  #Copy the value in the matrix to R15
cmpw    $0, %r15w               #Check if the value is 0
je      getNextValueRight      #If 0 we continue looping until we get the first non-zero value
jne     processingRight        #Otherwise we process it


getNextValueRight:

subq    $4, %rsi               #Go to the next location in the matrix

cmpq    $-1, %rsi              #We traverse vertically instead of horizontally
je      case_1Right            #So we have to make sure to jump the next column for traversing

cmpq    $-2, %rsi              #Check if we are done with the second column
je      case_2Right

cmpq    $-3, %rsi              #Check if we are done with the third column
je      case_3Right

cmpq    $-4, %rsi              #Check if we are done with the last column
je      endCase2Right

jmp     endCase1Right

case_1Right:
movq    $14, %rsi               #Go to the second column
jmp     endCase1Right


case_2Right:
movq    $13, %rsi               #Go to the third column
jmp     endCase1Right


case_3Right:
movq    $12, %rsi               #Go to the fourth column
jmp     endCase1Right


endCase1Right:

jmp     loopingRight            #We continue looping

endCase2Right:
jmp      endMoveRight1          #Jump to end

processingRight:
movq   %rsi, %rbx                #Copy the current(previous) location, so we can use RSI again after processing
movq   %rsi, %r11               #Copy the location to R11 as well

processingLoopRight:

cmpq   $3, %rsi  
jle    lessOrEqual3Right        #Check corner case 1            


cmpq   $12, %rsi                #Check corner case 4
jge     greaterThan12Right

cmpq   $8, %rsi
jge     greaterThan8Right       #Check corner case 3

cmpq   $4, %rsi
jge     greaterThan4Right       #Check corner case 2



lessOrEqual3Right:
addq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $3, %rbx                 #Check if we are still in the matrix
jg     getNextValueRight       #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    realProcessRight


greaterThan4Right:
addq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $7, %rbx                 #Check if we are still in the matrix
jg     getNextValueRight       #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    realProcessRight

greaterThan8Right:
addq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $11, %rbx                #Check if we are still in the matrix
jg     getNextValueRight       #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    realProcessRight

greaterThan12Right:
addq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $15, %rbx                #Check if we are still in the matrix
jg     getNextValueRight       #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    realProcessRight

realProcessRight:

movw   (%rdi, %rbx, 2), %r8w   #Copy the next tile value into R8

cmpw   $1, %r8w               #Check if that value is zero
je     ifOneCaseRight          #If zero, we treat it in the same way as zero, but then stop merging

cmpw   $0, %r8w               #Check if that value is zero
je     ifZeroCaseRight         #If zero, we move the previous tile one level left
jne    elseIfCaseRight         #If not zero, we check if we can merge the tiles


ifZeroCaseRight:

movw    %r15w, (%rdi, %rbx, 2)   #Move the "previous tile value" one step left
movw    %r8w, (%rdi, %r11, 2) #Reset the "previous tile" to empty
movq    %rbx, %r11              #Update the location
movq    $1, %r13               #Valid move, set up register
jmp     processingLoopRight    #We need to check if we have more tiles are to the left of us


ifOneCaseRight:

movq    $1, %r13               #Change flag register, means we have successfully moved 
movw    %r15w, (%rdi, %rbx, 2)   #Move the "previous tile value" one level left
movq    $0, %r8
movw    %r8w, (%rdi, %r11, 2) #Set the flag bit to the previous tile
movq    %rbx, %r11

cmpq   $3, %rsi  
jle    lessOrEqual3Right1      #Check corner case 1            


cmpq   $12, %rsi               #Check corner case 4
jge     greaterThan12Right1

cmpq   $8, %rsi
jge     greaterThan8Right1     #Check corner case 3

cmpq   $4, %rsi
jge     greaterThan4Right1     #Check corner case 2



lessOrEqual3Right1:
addq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $3, %rbx                 #Check if we are still in the matrix
jg     getNextValueRight       #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    moreZerosRight


greaterThan4Right1:
addq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $3, %rbx                 #Check if we are still in the matrix
jg     getNextValueRight       #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    moreZerosRight

greaterThan8Right1:
addq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $11, %rbx                #Check if we are still in the matrix
jg     getNextValueRight       #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    moreZerosRight

greaterThan12Right1:
addq   $1, %rbx                 #Go the previous column, because we are moving left
cmpq   $15, %rbx                #Check if we are still in the matrix
jg     getNextValueRight       #If not, then we are at the left edge of the grid and we don't move left and go back
jmp    moreZerosRight


moreZerosRight:

movw    (%rdi, %rbx, 2), %r8w  #Check if there are more zeros to the left of the current 1 value location
cmpw    $0, %r8w              #If there are more zeros, we need to treat them as 1
je      ifOneCaseRight


jmp     getNextValueRight      #We dont't merge again at this location in the same move, so we go back


elseIfCaseRight: #Check if we can merge tiles

cmpw    %r8w, %r15w            #Compare the values of two tiles 
je      mergingRight           #If they are equal, they can be merged
jne     elseCaseRight          #Otherwise go back


#===========If merged, set the merged value to the lower tile and set a flag bit to the higer tile
mergingRight:

addw    %r8w, %r15w             #Value *= 2
addq    %r15, %r9                #Record the score
movw    %r15w, (%rdi, %r11, 2)   #Merging and save to the current level(because moving up)
movw    $1, %r14w               #Set flag bit
movw    %r14w, (%rdi, %rbx, 2)   #Copy flag bit to the location

#===============Set an extra flag bit to the tile below the lower tile if it's 0
subq    $2, %rbx                 #Go to 2 tiles to the right

movw    (%rdi, %rbx, 2), %r8w   #We check if there is a zero
cmpw    $0, %r8w                   
jne     endMergingRight         #If it's not zero then we don't need to set this extra bit

movw    $1, %r14w               #Set flag bit
movw    %r14w, (%rdi, %rbx, 2)   #Copy flag bit to the location


endMergingRight:
addq    $1, %rbx                 #Reset RBX to the lower tile

movq    $1, %r13                #Set flag register
jmp     processingLoopRight


elseCaseRight:

jmp     getNextValueRight



endMoveRight1:

cmpq    $1, %r13                #Check if we had a valid move or merge
jne     endMoveRight2

movq    $matrix, %rdi           #Clear all flag bits after one move
call    clearFlagBit

movq    $matrix, %rdi           #If we had a valid move, there will be another random tile added into the grid
call    generateRandomTile 

endMoveRight2:

popq    %rbx
popq    %r15
popq    %r14
popq    %r13
popq    %r12


movq    %rbp, %rsp 
popq    %rbp
ret




#====================================================
#This subroutine checks the game state              #       
#                                                   #
#                                                   # 
#====================================================

checkState:

pushq   %rbp 
movq    %rsp, %rbp 

pushq   %r12 

movq    $0, %rsi
movq    $0, %r8
movq    $0, %r12  #number of times
movq    $0, %r11


check2048:

movw    (%rdi, %rsi, 2), %r8w
cmpw    $2048, %r8w

je      endCheck2
 
incq    %rsi
cmpq    $16, %rsi
jne     check2048

movq    $0, %rsi

checkZero:

movw    (%rdi, %rsi, 2), %r8w
cmpw    $0, %r8w

je      endCheck1
 
incq    %rsi
cmpq    $16, %rsi
jne     checkZero

movq    $0, %rsi

checkHorizontal:

movw    (%rdi, %rsi, 2), %r8w

incq    %rsi

movw    (%rdi, %rsi, 2), %r11w

cmpw    %r8w, %r11w
je      endCheck1 

incq    %r12
cmpq    $3, %r12

jne     checkHorizontal

incq    %rsi
movq    $0, %r12
cmpq    $15, %rsi
jle     checkHorizontal


movq    $0, %rsi
movq    $0, %r12

checkVertical:

movw    (%rdi, %rsi, 2), %r8w

addq    $4, %rsi

movw    (%rdi, %rsi, 2), %r11w

cmpw    %r8w, %r11w
je      endCheck1 

incq    %r12
cmpq    $3, %r12
jne     checkVertical


subq    $12, %rsi
movq    $0, %r12
incq    %rsi
cmpq    $4, %rsi

jle    checkVertical

jmp     endCheck3


endCheck1:

movq    $0, %rax
jmp     endCheck3

endCheck2:
movq    $1, %rax

endCheck3:
popq    %r12

movq    %rbp, %rsp 
popq    %rbp 
ret  



#====================================================
#This subroutine prints the total score             #       
#                                                   #
#                                                   # 
#====================================================

printScore:

pushq   %rbp
movq    %rsp, %rbp

pushq   %r12
pushq   %r13

movq    %r9, %rax
movq    $68, %r8
movq    $0, %r12
movq    $0, %r13

loop_unsigned:

    movq    $0, %rdx            # 0 to rdx for division
    movq    $10, %r12           # divide with 10 to get digits
    divq    %r12                # divide rax with rbx
    addq    $0x30, %rdx         # add 30 to number from 0 to 9 to get ASCII
                    
    push    %rdx                # push rdx to print it
    incq    %r13                # add 1 to number of digits on stack

    cmpq    $0, %rax
    jne     loop_unsigned
    je      print_unsigned

    print_unsigned:
    cmpq    $0, %r13            # compare 0 to number of digits still on stack
    je      endPrintScore
    
   
    movq    %r8, %rdi                 #First patameter: x-coordinate of the pixel
    movq    $3, %rsi                  #Second parameter: y-coordinate of the pixel
    movq    (%rsp), %rdx              #Third parameter: input digit
    movq    $0xF6, %rcx               #Fourth parameter: color of the character
    call    putChar

    incq    %r8

    popq    %rdx            # remove last digit printed from the stack
    decq    %r13            # substract 1 from number of digits still on stack
    jmp     print_unsigned

endPrintScore:
popq    %r13
popq    %r12

movq    %rbp, %rsp
popq    %rbp 
ret    





#====================================================
#This subroutine prints the best score              #       
#                                                   #
#                                                   # 
#====================================================

printBestScore:

pushq   %rbp
movq    %rsp, %rbp

pushq   %r12
pushq   %r13

movq    %r10, %rax
movq    $7, %r11
movq    $0, %r12
movq    $0, %r13

loop_unsigned2:

    movq    $0, %rdx            # 0 to rdx for division
    movq    $10, %r12           # divide with 10 to get digits
    divq    %r12                # divide rax with rbx
    addq    $0x30, %rdx         # add 30 to number from 0 to 9 to get ASCII
                    
    push    %rdx                # push rdx to print it
    incq    %r13                # add 1 to number of digits on stack

    cmpq    $0, %rax
    jne     loop_unsigned2
    je      print_unsigned2

    print_unsigned2:
    cmpq    $0, %r13            # compare 0 to number of digits still on stack
    je      endPrintScore2


    movq    %r11, %rdi                 #First patameter: x-coordinate of the pixel
    movq    $3, %rsi                  #Second parameter: y-coordinate of the pixel
    movq    (%rsp), %rdx              #Third parameter: input digit
    movq    $0xF6, %rcx               #Fourth parameter: color of the character
    call    putChar

    incq    %r11

    popq    %rdx            # remove last digit printed from the stack
    decq    %r13            # substract 1 from number of digits still on stack
    jmp     print_unsigned2

endPrintScore2:
popq    %r13
popq    %r12

movq    %rbp, %rsp
popq    %rbp 
ret    





#=====================================================
#This subroutine prints the total score after win or #                
#lose                                                #   
#                                                    # 
#=====================================================

printFinalScore:

pushq   %rbp
movq    %rsp, %rbp

pushq   %r12
pushq   %r13

movq    %r9, %rax
movq    $45, %r8
movq    $68, %r11
movq    $0, %r12
movq    $0, %r13

loop_unsigned1:

    movq    $0, %rdx            # 0 to rdx for division
    movq    $10, %r12           # divide with 10 to get digits
    divq    %r12                # divide rax with rbx
    addq    $0x30, %rdx         # add 30 to number from 0 to 9 to get ASCII
                    
    push    %rdx                # push rdx to print it
    incq    %r13                # add 1 to number of digits on stack

    cmpq    $0, %rax
    jne     loop_unsigned1
    je      print_unsigned1

    print_unsigned1:
    cmpq    $0, %r13            # compare 0 to number of digits still on stack
    je      endPrintScore1
    
    movq    %r8, %rdi                 #First patameter: x-coordinate of the pixel
    movq    $12, %rsi                  #Second parameter: y-coordinate of the pixel
    movq    (%rsp), %rdx              #Third parameter: input digit
    movq    $0xF6, %rcx               #Fourth parameter: color of the character
    call    putChar

    incq    %r8
    

    popq    %rdx            # remove last digit printed from the stack
    decq    %r13            # substract 1 from number of digits still on stack
    jmp     print_unsigned1

endPrintScore1:
popq    %r13
popq    %r12

movq    %rbp, %rsp
popq    %rbp 
ret    




#====================================================
#This subroutine clears all flag bits in the matrix #
#after one move                                     #
#                                                   # 
#====================================================
clearFlagBit:

pushq   %rbp
movq    %rsp, %rbp

pushq   %r15 
pushq   %rbx

movq    $0, %rsi                #RSI = index counter
movq    $0, %r15                 #Clear R15
movq    $0, %rbx                 #Clear RBX

gridTraversal2:

movw    (%rdi, %rsi, 2), %r15w   #Copy the value in the matrix to R15
cmpw    $1, %r15w                #Check if it's 1
jne     getNext                 #If not we get the next byte

movw    %bx, (%rdi, %rsi, 2)   #Overwrite the value with 0

getNext:

incq    %rsi                    #Increase the index counter
cmpq    $16, %rsi               #Check if we reach the end of the matrix
jne     gridTraversal2 
je      endClear


endClear:

popq    %rbx
popq    %r15

movq    %rbp, %rsp 
popq    %rbp
ret


#====================================================
#This subroutine clears all values in the matrix    #
#after one game                                     #
#                                                   # 
#====================================================

clearValues:

pushq   %rbp
movq    %rsp, %rbp

pushq   %r15 

movq    $0, %r15                 #Clear R15

movq    $0, %rsi                    #RSI = index counter

clearValueLoop:

movw    %r15w, (%rdi, %rsi, 2)

incq    %rsi                    #Increase the index counter
cmpq    $16, %rsi               #Check if we reach the end of the matrix
jne     clearValueLoop
je      endClear1


endClear1:

popq    %r15

movq    %rbp, %rsp 
popq    %rbp
ret



#=====================================================
#This subroutine compares the value of the tile and  #
#decides which string to print on the tile           #
#                                                    # 
#=====================================================

decidesString:

pushq   %rbp
movq    %rsp, %rbp

cmpq    $2, %rdi                #Compare 2 with RDI
je      case_2

cmpq    $4, %rdi                #Compare 4 with RDI
je      case_4

cmpq    $8, %rdi                #Compare 8 with RDI
je      case_8

cmpq    $16, %rdi               #Compare 16 with RDI
je      case_16

cmpq    $32, %rdi               #Compare 32 with RDI
je      case_32

cmpq    $64, %rdi               #Compare 64 with RDI
je      case_64
 
cmpq    $128, %rdi              #Compare 128 with RDI
je      case_128

cmpq    $256, %rdi              #Compare 256 with RDI
je      case_256

cmpq    $512, %rdi              #Compare 512 with RDI
je      case_512

cmpq    $1024, %rdi             #Compare 1024 with RDI
je      case_1024

cmpq    $2048, %rdi             #Compare 2048 with RDI
je      case_2048


case_2:
movq    $value2, %rax           #Copy input string to RAX
jmp     endDecision 

case_4:
movq    $value4, %rax           #Copy input string to RAX
jmp     endDecision 

case_8:
movq    $value8, %rax           #Copy input string to RAX
jmp     endDecision 

case_16:
movq    $value16, %rax          #Copy input string to RAX
jmp     endDecision 

case_32:
movq    $value32, %rax          #Copy input string to RAX
jmp     endDecision 

case_64:
movq    $value64, %rax          #Copy input string to RAX
jmp     endDecision 

case_128:
movq    $value128, %rax         #Copy input string to RAX
jmp     endDecision 

case_256:
movq    $value256, %rax         #Copy input string to RAX
jmp     endDecision 

case_512:
movq    $value512, %rax         #Copy input string to RAX
jmp     endDecision 

case_1024:
movq    $value1024, %rax        #Copy input string to RAX
jmp     endDecision 

case_2048:
movq    $value2048, %rax        #Copy input string to RAX

endDecision:
movq    %rbp, %rsp 
popq    %rbp
ret


#=====================================================
#This subroutine compares the value of the tile and  #
#decides which color to print on the tile            #
#                                                    # 
#=====================================================

decideColor:

pushq   %rbp
movq    %rsp, %rbp

cmpq    $2, %rdi                #Compare 2 with RDI
je      case_2c

cmpq    $4, %rdi                #Compare 4 with RDI
je      case_4c

cmpq    $8, %rdi                #Compare 8 with RDI
je      case_8c

cmpq    $16, %rdi               #Compare 16 with RDI
je      case_16c

cmpq    $32, %rdi               #Compare 32 with RDI
je      case_32c

cmpq    $64, %rdi               #Compare 64 with RDI
je      case_64c

cmpq    $128, %rdi              #Compare 128 with RDI
je      case_128c

cmpq    $256, %rdi              #Compare 256 with RDI
je      case_256c

cmpq    $512, %rdi              #Compare 512 with RDI
je      case_512c

cmpq    $1024, %rdi             #Compare 1024 with RDI
je      case_1024c

cmpq    $2048, %rdi             #Compare 2048 with RDI
je      case_2048c


case_2c:
movq    $0x9F, %rax             #Copy input color to RAX  
jmp     endDecisionc 

case_4c:
movq    $0x2F, %rax             #Copy input color to RAX  
jmp     endDecisionc 

case_8c:
movq    $0x3F, %rax             #Copy input color to RAX  
jmp     endDecisionc 

case_16c:
movq    $0x5F, %rax             #Copy input color to RAX  
jmp     endDecisionc 

case_32c:
movq    $0x8F, %rax             #Copy input color to RAX  
jmp     endDecisionc

case_64c:
movq    $0xDF, %rax             #Copy input color to RAX  
jmp     endDecisionc 

case_128c:
movq    $0x1F, %rax             #Copy input color to RAX  
jmp     endDecisionc 

case_256c:
movq    $0xBF, %rax             #Copy input color to RAX  
jmp     endDecisionc 

case_512c:
movq    $0xCF, %rax             #Copy input color to RAX  
jmp     endDecisionc 

case_1024c:
movq    $0xAF, %rax             #Copy input color to RAX  
jmp     endDecisionc

case_2048c:
movq    $0x4F, %rax             #Copy input color to RAX  

endDecisionc:
movq    %rbp, %rsp 
popq    %rbp
ret




