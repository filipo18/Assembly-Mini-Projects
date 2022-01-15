.data
buffer: 	.skip 14336

jumptable:
.text
.global brainfuck
format_str: .asciz "We should be executing the following code:\n%s\n"
output: 	.asciz "%c"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.


#########
# R13 is the array of size buffer
# R12 is the first addres of the code beeing interpreted
# R15 is the position of [

brainfuck:
	pushq %rbp
	movq %rsp, %rbp
    movq $0, %r12

	movq %rdi, %rsi
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

		cmpb $0x3C, %r15b
		je	 less				# <

		cmpb $0x3E, %r15b
		je	 more				# >

		cmpb $0x2B, %r15b
		je	 plus				# +

		cmpb $0x2D, %r15b
		je	 minus				# -

		cmpb $0x2E, %r15b
		je	 dot				# .

		cmpb $0x5B, %r15b
		je	 open				# [

		cmpb $0x5D, %r15b
		je	 close				# ]

        cmpb $0x2C, %r15b      # ,
        je   comma

		cmpb $0, %r15b			# if content of r12 is 0 terminate the program
		je	 end

		incq %r12						# if its not equal to any of the charcaters, treat it as a comment, don't do anything
		jmp	 interpret_code_caracter	# just go to comapring next character

		plus:
			movq $1, %r11
			incq %r12					# move to next character
				cmpb $0x2B, (%r12)		# 2
				jne	 end_plus
				incb %r11b
				incq %r12
					cmpb $0x2B, (%r12)	# 3
					jne	 end_plus
					incb %r11b
					incq %r12
						cmpb $0x2B, (%r12)	# 4 
						jne	 end_plus
						incb %r11b
						incq %r12
							cmpb $0x2B, (%r12)	# 5 
							jne	 end_plus
							incb %r11b
							incq %r12
								cmpb $0x2B, (%r12)		# 6
								jne	 end_plus
								incb %r11b
								incq %r12
									cmpb $0x2B, (%r12) 	# 7
									jne	 end_plus
									incb %r11b
									incq %r12
										cmpb $0x2B, (%r12)	# 8 
										jne	 end_plus
										incb %r11b
										incq %r12
											cmpb $0x2B, (%r12)	# 9 
											jne	 end_plus
											incb %r11b
											incq %r12
												cmpb $0x2B, (%r12)		# 10
												jne	 end_plus
												incb %r11b
												incq %r12
													cmpb $0x2B, (%r12) 	# 11
													jne	 end_plus
													incb %r11b
													incq %r12
														cmpb $0x2B, (%r12)	# 12 
														jne	 end_plus
														incb %r11b
														incq %r12
															cmpb $0x2B, (%r12)	# 13 
															jne	 end_plus
															incb %r11b
															incq %r12
																cmpb $0x2B, (%r12)		# 14
																jne	 end_plus
																incb %r11b
																incq %r12
																	cmpb $0x2B, (%r12) 	# 15
																	jne	 end_plus
																	incb %r11b
																	incq %r12
																		cmpb $0x2B, (%r12)	# 16 
																		jne	 end_plus
																		incb %r11b
																		incq %r12
																			cmpb $0x2B, (%r12)	# 17 
																			jne	 end_plus
																			incb %r11b
																			incq %r12
			end_plus:
			addb %r11b, (%r13)
			jmp	 interpret_code_caracter 

		minus:
			incq %r12					# move to next character
			decb (%r13)
			jmp	 interpret_code_caracter

		less:
			incq %r12					# move to next character
			decq %r13
			jmp	 interpret_code_caracter

		more:
			incq %r12					# move to next character
			incq %r13
			jmp interpret_code_caracter
		
		dot:
			incq %r12					# move to next character
			movq $output, %rdi
			movq $0, %rsi
			movb (%r13), %sil
			movq $0, %rax
			call printf
			movq $0, %rax 
			jmp	 interpret_code_caracter

		open:
			movq $0, %r14				# r14 counts nested loops
			cmpb $0, (%r13)				# check if cell is 0
			je	loop_to_close			# if celll is 0, skip
			pushq %r12
			subq $8, %rsp
			incq %r12
			jmp	 interpret_code_caracter # if cell not 0 continue execution

				loop_to_close:
					incq %r12
					cmpb $0x5d, (%r12)
					je	 close_bracket
					cmpb $0x5b, (%r12)
					je	 bracket_plus
					jmp  loop_to_close


					close_bracket:
						cmpq $0, %r14
						jne  bracket_minus
						incq %r12
						jmp  interpret_code_caracter

					bracket_plus:
						incq %r14
						jmp	 loop_to_close

					bracket_minus:
						decq %r14
						jmp loop_to_close

		close:
			movq $0, %r14
			incq %r12					# move to next character
			cmpb $0, (%r13)
			je	continue
			movq 8(%rsp), %r12
			incq %r12
			jmp	 interpret_code_caracter
			
			continue:
			addq $16, %rsp
			jmp interpret_code_caracter


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
