# ∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗
# ∗ Program : First program ∗
# ∗ D e s c ri p ti o n : First lab excercise power ∗
# ∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗

.text # read only, holds strings

    filip:              .asciz "\nFilip Ignijic, task: powers\n"
    prompt_base:        .asciz "\nEnter non negative base\n" 
    prompt_exp:         .asciz "\nEnter non negative exponent\n"
    input:              .asciz "%ld"
    output:             .asciz "The result is: %ld. \n"

.global main
main:
    #prologue
    pushq   %rbp                # base pointer
    movq    %rsp, %rbp          # initialize base pointer, rsp stack pointer, base pointer register rbp

    movq    $filip, %rdi        # name string
    movq    $0, %rax            # no vector registers in use fo printf
    call    printf              # print

    #first prompt
    movq    $0, %rax            # no vector registers in use for printf
    movq    $prompt_base, %rdi  # parameter 1, prompt string
    call    printf

    #first input
    subq    $16, %rsp           # Reserve stack space for ariable

    movq    $0, %rax            # no registers needed for input
    movq    $input, %rdi        #param input
    leaq    -8(%rbp), %rsi      #Load address of stack var in rsi, lea calclates the address for us, param1 adress of reserved space 
    call    scanf

    #second prompt
    movq    $0, %rax            # no vector registers in use for printf
    movq    $prompt_exp, %rdi   # parameter 1, prompt string
    call    printf

    #second input
    movq    $0, %rax            # no registers needed for input
    movq    $input, %rdi        # move input variable to rdi
    leaq    -16(%rbp), %rsi     # load address to of stack to rsi
    call    scanf               

    popq    %rdi                # pop exponent
    popq    %rsi                # pop base
    
    call    pow                 # go to pow

    movq    $output, %rdi       # copy string to rdi to print it
    movq    %rax, %rsi  
    movq    $0, %rax            # no vector register needed for printf
    call    printf              # print

    
    #epilogue
    movq    %rbp, %rsp          # move pointer
    popq    %rbp                # pop to base pointer


end: # loads the program exit code and exits
    movq    $0, %rdi
    call    exit

# ∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗
# * Subroutine: pow
# * Description: it calculates powers of non negative bases and exponents
# * Arguments: base - exponential base, exp - the exponent
# Specification:
#   int pow(int base, int exp){
#       int total = 1;
#       while ( 0 == exp){
#           total = total * base;
#           count--;
#       }
#   return total;    
#   }
# ∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗∗

pow:
    pushq   %rbp        
    movq    %rsp, %rbp  # base stack push
    movq    $1, %rax    # set mulitplier to 1
loop:    
    cmpq    $0, %rdi    # compare exponent number to 0
    je     stop         # if equals then break while loop
    mulq    %rsi        # multiply rax with rsi
    decq    %rdi        # decrease exponent by 1
    jmp loop            # reoeat
stop:
       # move result of multilication to rsi
    
    #eplilogue
    movq %rbp, %rsp     # move rsp back up
    popq %rbp           # pop base pointer 
    ret                 # return

    




    
  



