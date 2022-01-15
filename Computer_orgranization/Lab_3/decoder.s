.text
    letter:  .asciz "%c"

.include "final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer


	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    # your code goes here
    movq    %rdi, %rcx      # base address goes to rcx
    movq    $0, %rdx        # index counter in RDX
    movq    $0, %r9         # make sure zeroes are in 9

loop:
    movq    $0, %rsi
    movq    (%rcx, %rdx, 8), %r8   # indirect addressing, base in rcx, index in rdx, step is 8

    
    movb    %r8b, %sil              # rdx 8 bits to rsi 8bits

    shr     $8, %r8                 # shifted to amount of times character should be printed
    movb    %r8b, %r9b              # n times character should be printed to r9  
# prints character correcnt amount of times
print:
    movq    $letter, %rdi           # print format
    movq    $0, %rax
    pushq   %rsi                    # save rsi
    pushq   %rcx                    # save rcx
    pushq   %r8                     #save r8
    pushq   %r9                     # save r9
    call    printf                  # call print
    popq    %r9                     # get r9 back
    popq    %r8                     # r8 back
    popq    %rcx                    # rcx back
    popq    %rsi                    # rsi back

    cmpb    $1, %r9b                # if the amount of print times 1, shift to address
    je     address  
    decb    %r9b                    # if amount of times not 1, decrease and loop to print again
    jmp     print
address:
    shr     $8, %r8                # shifted to address index
    movl    %r8d, %edx              # move index to rdx, where idex is in indirect adressing
    cmpl    $0, %edx                # move addres to rdx, and repeat all the steps on the new address
    je      stop
    jmp     loop


stop:
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret



