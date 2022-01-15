.text
    letter:  ".asciz \033[33;42m%c"

.include "helloWorld.s"

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
decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    # your code goes here
    movq    %rdi, %rcx      # base address goes to rcx
    movq    $0, %rdx        # index counter in RDX
    movq    $0, %r9

loop:
    movq    $0, %rsi
    movq    (%rcx, %rdx, 8), %r8   # indirect addressing

    
    movb    %r8b, %sil              # rdx 8 bits to rsi 8bits

    shr     $8, %r8                 # shifted to amount of times character should be printed
    movb    %r8b, %r9b              # n times character should be printed to r9

# prints character correcnt amount of times
print:
    movq    $letter, %rdi           # print format
    movq    $0, %rax
    pushq   %rsi
    pushq   %rcx
    pushq   %r8
    pushq   %r9 
    call    printf
    popq    %r9
    popq    %r8
    popq    %rcx
    popq    %rsi

    cmpb    $1, %r9b
    je      address
    decb    %r9b
    jmp     print
address:
    shr     $8, %r8                # shifted to address index
    movl    %r8d, %edx             # move index to rdx, where idex is in indirect adressing
    cmpl    $0, %edx
    je      stop
    jmp     loop


stop:
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

