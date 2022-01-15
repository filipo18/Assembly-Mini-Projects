.data 

encodingBuffer: 	.skip 3072
fileHeaderBuffer:	.skip 14
bitmapHeaderBuffer: .skip 40


.text
filename:	.asciz "encoded_image.bmp"
message: 	.ascii "CCCCCCCCSSSSEE1111444400000000" 
			.ascii "The quick brown fox TESTtest aaaaaaaaaaaaaaaaaa jumps over the lazy hog"
			.asciz "CCCCCCCCSSSSEE1111444400000000" 

inputFormat: .asciz "%c"

.include "barcode.s" 

.global main  


main: 

	pushq 	%rbp 
	movq 	%rsp, %rbp 



	movq  	$encodingBuffer, %rdi 
	call  	encoding




	movq  	$barcode_template, %rdi 
	movq 	$encodingBuffer, %rsi
	call  	barcode_encode



	call  	file_header
   

	call  	bitmap_header
 

	call  	bmp_generate


	movq 	%rbp, %rsp 
	popq  	%rbp 
	movq 	$0, %rdi 
	call  	exit 

encoding:
	pushq 	%rbp 
	movq 	%rsp, %rbp 

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15

	#R14 = counter how many times letter 
	#R13 = letter 
	#R12 = letter 
	#r10 index counter

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

 	incq  	%r15 					# counter of the same letters

 	jmp  	sameLetter



	writeToMemory:
	
		movb 	%r15b, (%rdi, %r10, 1) 	# indirect addressing to write to memory
		incq 	%r10					# increase index
		movb 	%r13b, (%rdi, %r10, 1) 	# indirect addressing to write to memory
		incq 	%r10
		movq 	$1, %r15
		jmp 	getNextByte


	endEncoding:
		popq 	%r15
		popq 	%r14 
		popq 	%r13 
		popq 	%r12 
		movq  	%rbp, %rsp 
		popq 	%rbp 
		ret


barcode_encode:
	# rdi is the base memory location of the barcode
	# rsi is the base memroy location of the encoded message
	# r15 is index counter, 
	# r14 encoded message

    pushq 	%rbp 
	movq 	%rsp, %rbp

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15

	movq 	$0, %r15 				# flush 0 %r15, index counter 
	movq 	$0, %r14				#flush 14 because using 14b
	loop_xor:
		movb 	(%rdi, %r15, 1), %r14b	# move BARCODE key byte to r14
		xorb 	%r14b, (%rsi, %r15, 1)	# ENCODED MEESAGE xor it with barcode, xor into encoding buffer
		incq	%r15					# go to next long, increase counter
		cmpq	$3072, %r15
		jl		loop_xor				# xor next char
	
	popq 	%r15
	popq 	%r14 
	popq 	%r13 
	popq 	%r12 

    movq  	%rbp, %rsp 
	popq 	%rbp 
	ret

bmp_generate: 
	pushq 	%rbp 
	movq 	%rsp, %rbp 

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15


	# System call to open a file,
	movq 	$2, %rax					# sys call 2, opens a file
	movq 	$filename, %rdi 			# pointer to 0 terminated string of the file name
	movq 	$65, %rsi					# 64 create file flag, 1 write only file flag, to combine them just add them
	movq 	$0x1A4, %rdx				# file permisions needed to be set
	syscall

	push %rax						# save the file descriptor at -8(%rbp) position

	# write file header to file
	movq 	(%rsp), %rdi				# file descriptor retrurned in rax from opening a file
	movq 	$1, %rax					# sys call 1 write
	movq 	$fileHeaderBuffer, %rsi				# text that we want to write
	movq 	$14, %rdx				# lenght of the text
	syscall

	# write bitmapheader to file
	movq 	(%rsp), %rdi				# file descriptor retrurned in rax from opening a file
	movq 	$1, %rax					# sys call 1 write
	movq 	$bitmapHeaderBuffer, %rsi				# text that we want to write
	movq 	$40, %rdx				# lenght of the text
	syscall

	# write barcode to file
	movq 	(%rsp), %rdi				# file descriptor retrurned in rax from opening a file
	movq 	$1, %rax					# sys call 1 write
	movq 	$encodingBuffer, %rsi		# text that we want to write
	movq 	$3072, %rdx					# lenght of the text
	syscall

	# close the file
	movq 	$3, %rax				# sys call for closing
	popq 	%rdi
	syscall

	popq 	%r15
	popq 	%r14 
	popq 	%r13 
	popq 	%r12 

	movq 	%rbp, %rsp 
	popq  	%rbp 
	ret


file_header:
	pushq 	%rbp 
	movq 	%rsp, %rbp 

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15

	movq 	$fileHeaderBuffer, %rdi #memory address where buffer is going to be writen
	movq 	$0, %r15				#r15 index counter

	# BM 
	movb	$0x42, (%rdi, %r15, 1)	# write B to memory
	incq	%r15					# increase index
	movb	$0x4D, (%rdi, %r15, 1)
	incq 	%r15					# incresae index

	# File size
	# File size will be fixed we know all the sizes 14 + 40 + 3072 = 3126
	movl	$3126, (%rdi, %r15, 1) # move 4 bytes of size to mememory, 3126 in decimal
	addq	$4, %r15				# increase index by 4

	# Reserved field
	movl	$0, (%rdi, %r15, 1)  	# move 4 bytes of reserved to mememory
	addq	$4, %r15				# increase index by 4

	# Pixel offset
	movl	$54, (%rdi, %r15, 1)  # move 4 bytes of offset of 54 to mememory
	addq	$4, %r15				# increase index by 4

	popq 	%r15
	popq 	%r14 
	popq 	%r13 
	popq 	%r12 

	movq 	%rbp, %rsp 
	popq  	%rbp 
	ret

bitmap_header:
	pushq 	%rbp 
	movq 	%rsp, %rbp 

	pushq  	%r12  
	pushq  	%r13  
	pushq  	%r14 
	pushq 	%r15

	movq 	$bitmapHeaderBuffer, %rdi 	# memory address where buffer is going to be writen
	movq 	$0, %r15					# r15 index counter

	# header size
	movl	$40, (%rdi, %r15, 1)		# 0x28 is 40 in decimal
	addq	$4, %r15					# increase index by 4

	# width in pixels
	movl	$32, (%rdi, %r15, 1)		# 0x20 is 32 in decimal
	addq	$4, %r15					# increase index by 4

	# height in pixels
	movl	$32, (%rdi, %r15, 1)		# 0x20 is 32 in decimal
	addq	$4, %r15					# increase index by 4

	# reserved field 2 bytes
	movw 	$1, (%rdi, %r15, 1)			# reserved space is 1 
	addq	$2, %r15					# increase index by 2

	# number of bits per pixel 2bytes
	movw 	$24, (%rdi, %r15, 1)		# number of bits is 24, 18 in hex
	addq	$2, %r15					# increase index by 2

	#compression method, we DONT want to compression
	movl	$0, (%rdi, %r15, 1)			# move 0
	addq	$4, %r15					# increase index by 4

	# size of pixel data
	movl 	$3072, (%rdi, %r15, 1)		# each pixel has 3 bytes
	addq 	$4, %r15

	# horizontal resolution
	movl 	$2835, (%rdi, %r15, 1)		# by manual
	addq 	$4, %r15

	# vertical resolution
	movl 	$2835, (%rdi, %r15, 1)		# by manual
	addq 	$4, %r15

	# colour palette information
	movl 	$0, (%rdi, %r15, 1)			# 0, by manual
	addq 	$4, %r15

	# number of important colors
	movl 	$0, (%rdi, %r15, 1)			# 0, by manual
	addq 	$4, %r15

	popq 	%r15
	popq 	%r14 
	popq 	%r13 
	popq 	%r12 

	movq 	%rbp, %rsp 
	popq  	%rbp 
	ret

