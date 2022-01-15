# ∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗
# ∗ Program : First program ∗
# ∗ D e s c ri p ti o n : First lab excercise power ∗
# ∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗

.text # read only, holds strings

    filip:              .asciz "\nFilip Ignijic, NetID:%ld , task: factorial\n"
    prompt:             .asciz "\nEnter non negative n, to calculate factorial: \n" 
    input:              .asciz "%ld"
    output:             .asciz "The result is: %ld. \n"

.global main


main:
    #epilogue
    pushq   %rbp
    movq    %rsp, %rbp          # initialize base pointer, rsp stack pointer, base pointer register rbp
    movq    $0, %rax            # no vector registers in use fo printf
    movq    $5483654, %rsi      # netid value
    movq    $filip, %rdi        # name string
    call    printf              # print

    #first prompt
    movq    $0, %rax            # no vector registers in use for printf
    movq    $prompt, %rdi       # parameter 1, prompt string
    call    printf

    #first input
    subq    $16, %rsp           # Reserve stack space for ariable
    movq    $0, %rax            # no registers needed for input
    movq    $input, %rdi        # param input

    leaq    -16(%rbp), %rsi     #Load address of stack var in rsi, lea calclates the address for us, param1 adress of reserved space 
    call    scanf            

    movq    $42, %rax
    popq    %rdi                # pop n
    call    factorial           # go to factorial

    movq    $output, %rdi       # move output string to rdi register
    movq    %rax, %rsi
    movq    $0, %rax            # no vector registers used for printf
    call    printf              # print

    
    #epilogue
    movq    %rbp, %rsp
    popq    %rbp 


end: # loads the program exit code and exits
    movq    $0, %rdi
    call    exit

# ∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗
# * Subroutine: recusrion
# * Description: it calculates n! using recursion
# * Arguments: non negative integer N
# Specification:
# 
#  int factorial(int n){
#   i.f(n == 1){
#       return 1;
#   }
#   e.lse{        
#       return (n * factorial(n-1);    
#   }   
#  }
# ∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗

factorial:
    #prologue
    pushq   %rbp        # push base pointer on stack  
    movq    %rsp, %rbp  # set rsp to rbp address 

    movq    %rdi, %rax  # move last n to rax
    decq    %rdi        # rdi -1
    pushq   %rax        # push to rax to save it

    cmpq    $1, %rax    # compare n to 1
    je      stop        # if equals to one, end recursion and return
    jle     inputZero   # if 0 factorial then 1 needs to be returned
    call    factorial   # go back

stop:
    #epilogue
    popq    %rdi       # pop rax 
    mulq    %rdi       # multyply with last rdi

stop_zero:
    movq    %rbp, %rsp  #stack pointer back to base pointer
    popq    %rbp        # pop base pointer
    ret
inputZero:
    movq    $1, %rax     # one if input zero
    jmp     stop_zero



    
  



