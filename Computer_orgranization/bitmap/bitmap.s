.data 

encodingBuffer: .skip 1024


.text 

message: 	.ascii "CCCCCCCCSSSSEE1111444400000000" 
			.ascii "The answer for exam question 42 is not F."
			.asciz "CCCCCCCCSSSSEE1111444400000000" 


outputFormat: .asciz "%c"

.global main  


main: 

	pushq 	%rbp 
	movq 	%rsp, %rbp 

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15    

	movq  	$encodingBuffer, %rdi 
	call  	encoding

	popq 	%r15
	popq 	%r14 
	popq 	%r13 
	popq 	%r12 

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15    

	movq  	$encodingBuffer, %rdi 
	call  	decoder

	popq 	%r15
	popq 	%r14 
	popq 	%r13 
	popq 	%r12 



	movq 	%rbp, %rsp 
	popq  	%rbp 
	movq 	$0, %rdi 
	call  	exit 


encoding:
	pushq 	%rbp 
	movq 	%rsp, %rbp 

	#R14 = counter how many times letter 
	#R13 = letter 
	#R12 = letter 
	# r10 index counter

	encodingString:
	movq 	$message, %r12			#address of the String
	movq 	$1, %r15  				#counting letters

	getNextByte:
	cmpb 	$0, (%r12)  			#if end of string, go to next string
	je  	endEncoding
	 
	movb 	(%r12), %r13b 		  	#copy the next byte

	sameLetter:
	incq 	%r12
 	movb 	(%r12), %r14b
 	cmpb 	%r14b, %r13b 			#check if the next letter is the same
 	jne  	writeToMemory

 	incq  	%r15 

 	jmp  	sameLetter



	writeToMemory:
	
		movb 	%r15b, (%rdi, %r10, 1) 	# indirect addressing to write to memory
		incq 	%r10					# increase index
		movb 	%r13b, (%rdi, %r10, 1) 	# indirect addressing to write to memory
		incq 	%r10
		movq 	$1, %r15
		jmp 	getNextByte


	endEncoding:
		movq  	%rbp, %rsp 
		popq 	%rbp 
		ret

decoder:

	pushq 	%rbp 					#push the base pointer on stack
	movq 	%rsp, %rbp 				#copy the stack pointer value to the base pointer

	movq 	$encodingBuffer, %r12 	#copy input file address to R12
	movq 	$0, %r10				# index to skip headers

	decoding: 

		movb 	(%r12, %r10,1), %r14b 	#number of times the character needs to be printed
		cmpb  	$0, %r14b
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
		
		#Epilogue

		movq 	%rbp, %rsp 	 			#copy the base pointer to the stack pointer		
		popq 	%rbp 					#pop the base pointer from stack
		ret 							#return from subroutine