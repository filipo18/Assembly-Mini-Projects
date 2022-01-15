.data 

encodingBuffer: .skip 1024


.text 
test: .asciz "TEST"
try:	.asciz "TRY!"

message: 	.ascii "CCCCCCCCSSSSEE1111444400000000" 
			.ascii "The answer for exam question 42 is not F."
			.asciz "CCCCCCCCSSSSEE1111444400000000" 


output: .asciz "%c"

.global main  


main: 

	pushq 	%rbp 
	movq 	%rsp, %rbp 

	movq %ah, $00h
	int 1ah

	
	movq 	%rbp, %rsp 
	popq  	%rbp 
	movq 	$0, %rdi 
	call  	exit 





