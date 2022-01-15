#Assignment 3

.text

.include 		"final.s"  			#include the message file

inputFormat:  	.asciz "\x1B[38;5;%ldm\x1B[48;5;%ldm%c" 	# format for printing
effectFormat:	.asciz "\x1B[%ldm%c"						# format for effect
endformat:		.asciz "\x1B[0m"							# clean the last line

.global main



main:

	#Prologue
	pushq 	%rbp 					#push the base pointer on stack
	movq 	%rsp, %rbp 				#copy the stack pointer to base pointer


	movq 	$MESSAGE, %rdi 			#copy the MESSAGE address into rdi
	call  	decode 					#call the subroutine decode

	#Epilogue
	movq 	%rbp, %rsp 				#copy the base pointer to the stack pointer
	popq 	%rbp 					#pop the base pointer
	movq 	$0, %rdi 				#copy the exit code into RDI
	call  	exit  					#exit the program

decode:
 	
	pushq 	%rbp 					#push the base pointer on stack
	movq 	%rsp, %rbp 				#copy the stack pointer value to the base pointer

	pushq 	%r12 					#push the callee saved registers on stack to keep 
	pushq 	%r13 					#the value same after using the the registers
	pushq 	%r14
	pushq 	%r15

	movq 	%rdi, %r12 				#copy input file address to R12
	movq 	$0,  %r13 				#clear R13 before use

decoding:
	movq  (%r12, %r13, 8), %rdi 	#(base + index * scale) -> jumping rows

	movb 	%dil, %cl  			#copy the to be printed charater to rcx where its printed from as forth argument(8bits)
	
	shr  	$8, %rdi 				#shift the row 8 bits to right
	movb 	%dil, %r14b 			#number of times the character needs to be printed

 	
	shr 	$8, %rdi  				#shift the row 8 bits to right
	movl 	%edi, %r13d 			#next row to be jumped

	shr    	$32, %rdi 				#shift the row 32 bits to right
	movb 	%dil, %r15b  			#colour of the character

	shr 	$8, %rdi 				#shift the row 8 bits to right
	movb 	%dil, %r9b  			#backgroud colour

	cmpb 	%r9b, %r15b
	je  	ifelseCase 
	jmp  	printingTimes

ifelseCase:
	movq 	$0, %rsi


	cmpb 	$0, %r9b
	movb 	$0, %sil
	je  	print_special

	cmpb 	$37, %r9b
	movb 	$25, %sil 
 	je  	print_special

	cmpb 	$42, %r9b
	movb 	$1, %sil
	je    	print_special

	cmpb 	$66, %r9b
	movb 	$2, %sil
	je  	print_special

	cmpb 	$105, %r9b
	movb  	$8, %sil
	je  	print_special

	cmpb 	$153, %r9b
	movb 	$28, %sil
	je  	print_special

	cmpb 	$182, %r9b
	movb 	$5, %sil
	je  	print_special

printingTimes:
	movq  	$inputFormat, %rdi  	#first parameter in RDI: copy inputFormat to RDI
	movq 	$0, %rax  				#no vector registers in use for printf function
	pushq	%rcx
	pushq 	%r9
	pushq	%rsi
	movq 	$0, %rsi  				#clear RSI
	movb 	%r15b, %sil 			#second parameter in RSI: foreground colour
	movq 	$0, %rdx  				#clear RDX
	movb 	%r9b, %dl 				#third parameter in RDX: background colour

	call  	printf  				#call printf function
	popq	%rsi
	popq 	%r9 					#pop R9 from stack
	popq 	%rcx					#pop RSI from stack
	decb  	%r14b 					#decrease the counter
	cmpb 	$0, %r14b 				#if the counter is not 0
	jg  	printingTimes  			#we go back looping
	jmp		stop_decode

print_special:
	movq  	$effectFormat, %rdi  	#first parameter in RDI: copy inputFormat to RDI
	movb	%cl, %dl				# move letter from 4th parameter into 3rd paramenter
	movq 	$0, %rax  				#no vector registers in use for printf function
	pushq 	%rcx 					#push RSI onto stack before it's overwritten
	pushq 	%r9
	call 	printf
	popq 	%r9 					#pop R9 from stack
	popq 	%rcx 					#pop RSI from stack
	decb  	%r14b 					#decrease the counter
	cmpb 	$0, %r14b 				#if the counter is not 0
	jg  	print_special  			#we go back looping
	jmp		stop_decode

stop_decode:
	cmpl  	$0, %r13d 				#if we've reached the end of the file
	je  	end	 					#jump to end
	jmp   	decoding 				#otherwise we fetch the next byte


end:
	
	#Epilogue
	popq 	%r15 					#pop the values from stack to the callee saved registers
	popq 	%r14 
	popq  	%r13 
	popq 	%r12

	movq	$endformat, %rdi
	movq 	$0, %rax
	call 	printf

	movq 	%rbp, %rsp 		 		#copy the base pointer to the stack pointer		
	popq 	%rbp 					#pop the base pointer from stack
	ret  							#return from subroutine
