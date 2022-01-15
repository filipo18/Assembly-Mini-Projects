.data 

decodingBuffer: .skip 3126 	#size of bitmap always 3126

.text
outputFormat:  	.asciz "%c"
filename:		.asciz "encoded_image.bmp"
newlineFormat:	.asciz "%s"  # new line not important
newline:		.asciz "\n"

.include "barcode.s"

.global main

main:

	pushq 	%rbp 					#push the base pointer on stack
	movq 	%rsp, %rbp 				#copy the stack pointer value to the base pointer

	call  	read_bitmap

	call  	xor_decode 

	call  	decoder 	

	movq 	%rbp, %rsp 
	popq  	%rbp 
	movq 	$0, %rdi 
	call  	exit

read_bitmap:
	pushq 	%rbp 					#push the base pointer on stack
	movq 	%rsp, %rbp 				#copy the stack pointer value to the base pointer

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15 


	# System call to open a file,
	movq 	$2, %rax					# sys call 2, opens a file
	movq 	$filename, %rdi 			# pointer to 0 terminated string of the file name
	movq 	$0, %rsi					# 0 read only
	movq 	$0x1A4, %rdx				# file permisions needed to be set
	syscall

	pushq 	%rax						# save the file descriptor at -8(rbp)


	# Read from a file
	movq 	$decodingBuffer, %rsi		# pointer to allocated location in memory for read bytes
	movq 	$0, %rax					# syscall 0 for reading a file
	movq 	(%rsp), %rdi				# file descriptor returned through rax and pushed on stack
	movq	$3126, %rdx					# number of bytes to read, size of bitmap fixed
	syscall

	# Close a file
	movq 	$3, %rax 					# close a file sys call
	popq	%rdi						# pop file descriptor into rdi 
	syscall

	popq 	%r15
	popq 	%r14 
	popq 	%r13 
	popq 	%r12 

	movq 	%rbp, %rsp 
	popq  	%rbp 
	ret

xor_decode:
	pushq 	%rbp 					#push the base pointer on stack
	movq 	%rsp, %rbp 				#copy the stack pointer value to the base pointer

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15 

	movq 	$0, %r15				# set barcode index 0
	movq 	$54, %r13 				# set data index 54, to skip header and match the key
	movq 	$0, %r14				#flush 14 because using 14b
	movq	$barcode_template, %rdi	# key
	movq 	$decodingBuffer, %rsi	# pointer to bmp move to rdi

	loop_xor_decode:
		movb 	(%rdi, %r15, 1), %r14b	# move barcode key byte to 14
		xorb 	%r14b, (%rsi, %r13, 1)	# xor barcode key with data to decode

		incq	%r15					# go to next long, increase counter
		incq	%r13					# next data index
		cmpq	$3072, %r15				# stop at the end of barcode
		jl		loop_xor_decode			# xor next char
	
	popq 	%r15
	popq 	%r14 
	popq 	%r13 
	popq 	%r12 


	movq 	%rbp, %rsp 
	popq  	%rbp 
	ret

decoder:

	pushq 	%rbp 					#push the base pointer on stack
	movq 	%rsp, %rbp 				#copy the stack pointer value to the base pointer

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15 

	# Count characters
	movq 	$decodingBuffer, %r12 	# copy input file address to R12
	movq 	$54, %r10				# 54 index to skip headers, position in the memory

	count_loop:
		movb 	(%r12, %r10,1), %r14b 	# compare is character 0 - null termination 
		cmpb  	$0, %r14b
		je 		continue_decoding
		incq 	%r10					# move to next char
		jmp 	count_loop				# count
	
	continue_decoding:
	movq 	$decodingBuffer, %r12 	# again copy input file address to R12

	subq 	$12, %r10				# calculate the stopping position of printing
	movq	%r10, %r13				# move stopping position to r13

	movq 	$66, %r10				# index to skip headers
	
	decoding: 

		movb 	(%r12, %r10,1), %r14b 	#number of times the character needs to be printed
		cmpq  	%r13, %r10				# stop after the message is printed without trail
		je   	end

		incq 	%r10
		movq 	$0, %rsi				
		movb 	(%r12, %r10, 1), %sil  	#second parameter: copy the to be printed charater to RSI(8bits)

		incq 	%r10

	printingTimes:
		movq  	$outputFormat, %rdi  	#first parameter: copy inputFormat to RDI
		movq 	$0, %rax  				#no vector registers in use for printf function
		pushq 	%rsi 					#push RSI onto stack before it's overwritten
		pushq 	%r10
		call  	printf  	 			#call printf function
		popq 	%r10			
		popq 	%rsi 					#pop the to be printed character to RSI
		decb  	%r14b 					#decrease the counter
		cmpb 	$0, %r14b 				#if counter != 0
		jg  	printingTimes  			#jump to printingTimes and print the character one more time
						
		jmp   	decoding 				#otherwise we fetch the next byte


	end:
		# new line at the end
		movq 	$0, %rax  				#no vector registers in use for printf function
		movq  	$newlineFormat, %rdi  	#first parameter: copy new line format
		movq  	$newline, %rsi
		call 	printf

		#Epilogue
		popq 	%r15
		popq 	%r14 
		popq 	%r13 
		popq 	%r12 

		movq 	%rbp, %rsp 	 			#copy the base pointer to the stack pointer		
		popq 	%rbp 					#pop the base pointer from stack
		ret 							#return from subroutine