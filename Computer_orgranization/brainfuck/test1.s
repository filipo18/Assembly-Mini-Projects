.data
buffer: 	.skip 14336

.text
.global main
format_str: .asciz "We should be executing the following code:\n%s\n"
output: 	.asciz "%s"
teststring: .asciz ",[.,]"
# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.


#########
# R13 is the array of size buffer
# R12 is the first addres of the code beeing interpreted
# R15 is the position of [

main:
	pushq %rbp
	movq %rsp, %rbp
    movq $0, %r12

	movq $teststring, %rsi
	movq $format_str, %rdi
    movq %rsi, %r12 		# r12 is the brainfuck code
	call printf
	movq $0, %rax

	####################################################################
	# interpreter
	movq $0, %r13
	movq $buffer, %r13		# r13 is my array
	interpret_code_caracter:	# do action if content r12, equals to any of the signs
		movq (%r12), %r15		# move to register to decrease memory access

		cmpb $0x3C, %r15
		je	 less				# <

		cmpb $0x3E, %r15
		je	 more				# >

		cmpb $0x2B, %r15
		je	 plus				# +

		cmpb $0x2D, %r15
		je	 minus				# -

		cmpb $0x2E, %r15
		je	 dot				# .

		cmpb $0x5B, %r15
		je	 open				# [

		cmpb $0x5D, %r15
		je	 close				# ]

        cmpb $0x2C, %r15      # ,
        je   comma

		cmpb $0, %r15			# if content of r12 is 0 terminate the program
		je	 end

		incq %r12						# if its not equal to any of the charcaters, treat it as a comment, don't do anything
		jmp	 interpret_code_caracter	# just go to comapring next character

		plus:
			incq %r12					# move to next character
			incq (%r13)
			jmp	 interpret_code_caracter 

		minus:
			incq %r12					# move to next character
			decq (%r13)
			jmp	 interpret_code_caracter

		less:
			incq %r12					# move to next character
			# check for error if code doesn't work, r13 cant be smaller than starting address
			decq %r13
			jmp	 interpret_code_caracter

		more:
			incq %r12					# move to next character
			incq %r13
			jmp interpret_code_caracter
		
		dot:
			incq %r12					# move to next character
			movq $output, %rdi
			movq %r13, %rsi
			movq $0, %rax
			call printf
			movq $0, %rax 
			jmp	 interpret_code_caracter

		open:
	
			pushq %r12				# save the index position of [ to jump back to it
			subq $8, %rsp
			incq %r12					# move to next character
			cmpq $0, (%r13)				# check if cell is 0
			je	loop_to_close			# if celll is 0, skip
			jmp	 interpret_code_caracter # if cell not 0 continue execution

			loop_to_close: # this loop increases the pointer till ]
                movq $0, %r14
                movb (%r12), %r14b
				cmpb $0x5D, (%r12)
				incq %r12
				je	 interpret_code_caracter
				jmp	 loop_to_close

		close:
			incq %r12					# move to next character
			cmpb $0, (%r13)
			je	 interpret_code_caracter
			addq $8, %rsp
			popq %r12
			jmp	 interpret_code_caracter		

        comma:
            incq %r12

            movq $0, %rax
            movq $output, %rdi
            movq %r13, %rsi
            call scanf
			jmp interpret_code_caracter


end:
	movq %rbp, %rsp
	popq %rbp
	ret
