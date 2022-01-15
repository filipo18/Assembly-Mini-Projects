.data
percentage_sign:       .ascii "%"

.text
inputFormat:           .asciz "%%Filip1 0 spent %s of %s an%kd %d, %d, %d, %d, %u \n"
variable:              .asciz "A LOT"
variable2:             .asciz "TIME"

.global main 
main:
    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $inputFormat, %rdi
    movq    $variable, %rsi
    movq    $variable2, %rdx
    movq    $0, %rcx
    movq    $2, %r8
    movq    $3, %r9
    pushq   $4
    pushq   $-1

    call    my_printf  # subroutine print

    # epilogue
    movq    %rbp, %rsp
    popq    %rbp

    movq    $60, %rax
    movq    $0, %rdi
    syscall

my_printf: # my printf function

    # prologue
    pushq   %rbp
    movq    %rsp, %rbp

    push %r15
    push %r14
    push %r13
    push %r12


    # push all registers to the stack
    pushq   %r9
    pushq   %r8
    pushq   %rcx
    pushq   %rdx
    pushq   %rsi
    pushq   %rdi

    popq    %r14                        # pop first argument, format, into r14

    movq    $0, %r15                # move 0 to counter, r15 used as specifier counter
    movq    $2, %r12                # r12 will be stack counter, so it will count how many times i already used register from stack, it starts at 2 because 16(RBP)

    search_percantage:                  # first check for percantage signs
        cmpb    $0, (%r14)              # if character is 0, that is the end of string
        je      return                  # stop checking stop printing
        cmpb    $0x25, (%r14)           # if it is equal to percantage sign      
        je      specifier               # if equals %, you need to jump to next char, then repeat the loop

        movq    %r14, %rdi              # my printf subroutine prints from rdi
        call    print                   # call print

        incq    %r14                    # move to next character in a string
        jmp     search_percantage       # and loop

    specifier:                          # checks after first % for format
        incq    %r14                    # move to next char

        # %%
        cmpb    $0x25, (%r14)
        je      percentage              # print percantege sign if percantage sign

        # %s
        cmpb    $0x73, (%r14) #73
        je      string

        # %u
        cmpb    $0x75, (%r14)
        je      unsigned

        # %d
        cmpb    $0x64, (%r14)
        je      signed

        # specifier not equal to any from the list, then print without motification
        movq    $percentage_sign, %rdi
        call    print                # print percantege
        movq    %r14, %rdi
        call    print                   # print undefined specifier
        incq    %r14                     # move to next character
        jne     search_percantage        # if not equal to anything, loop back    

        
            percentage: # handle percentage format
                movq    $percentage_sign, %rdi
                call    print
                incq    %r14                    # move to next character
                jmp     search_percantage       # loop back
            
            string: # handle string format
                incq    %r15                    # increase format specifier counter
                incq    %r14                    # increase r14 to skip the %s specifier character

                cmpq    $6, %r15                # check with counter in r15 if registers are full
                jl      pop_string              # if not full then pop string
                movq    (%rbp, %r12, 8), %r13   # move address string to r13, which will be processed for printing
                incq    %r12
                jmp     loop_string
                pop_string:
                    popq    %r13                    # pop address string to r13, which will be processed for printing

                loop_string:    
                    cmpb    $0, (%r13)              # if character is 0, that is the end of string
                    je      search_percantage       # string is printed

                    movq    %r13, %rdi              # my printf subroutine prints from rdi
                    call    print                   # call print

                    incq    %r13                    # go to next character
                    jmp     loop_string              # repeat, untill string is printed
            
            unsigned:   # handle unsigned format
                incq    %r15                    # increase format specifier counter
                incq    %r14                    # increase r14 to skip the %s specifier character
                movq    $0, %r13                # move 0 to r13 to use 13 as a counter for pushing digits on stack

                cmpq    $6, %r15                # check with counter in r15 if registers are full
                jl      pop_unsigned              # if not full then pop string
                movq    (%rbp, %r12, 8), %rax   # move address string to r13, which will be processed for printing
                incq    %r12
                jmp     loop_unsigned
                pop_unsigned:
                    popq    %rax

                loop_unsigned:
                    movq    $0, %rdx            # 0 to rdx for division
                    movq    $10, %rbx           # divide with 10 to get digits
                    divq    %rbx                # divide rax with rbx
                    addq    $0x30, %rdx         # add 30 to number from 0 to 9 to get ASCII
                    
                    push    %rdx                # push rdx to print it
                    incq    %r13                # add 1 to number of digits on stack

                    cmpq    $0, %rax
                    jne     loop_unsigned
                    je      print_unsigned

                print_unsigned:
                    cmpq    $0, %r13            # compare 0 to number of digits still on stack
                    je      search_percantage
                    movq    %rsp, %rdi
                    call    print
                    popq    %rdx            # remove last digit printed from the stack
                    decq    %r13            # substract 1 from number of digits still on stack
                    jmp     print_unsigned
            
            signed:   # handle unsigned format
                incq    %r15                    # increase format specifier counter
                incq    %r14                    # increase r14 to skip the %s specifier character

                cmpq    $6, %r15                # check with counter in r15 if registers are full
                jl      pop_signed              # if not full then pop string
                movq    (%rbp, %r12, 8), %rax   # move address string to r13, which will be processed for printing
                incq    %r12
                jmp     skip_pop
                pop_signed:
                    popq    %rax
                skip_pop:
                cmpq    $0, %rax 
                jl     negative_signed         # if number is negative brench
                movq    $0, %r13                # r13 has to be 0 for loop unsigned to work
                jmp     loop_unsigned           # and treat is as unsigned

                negative_signed:
                movq    $0x2D, %rdx             # Negative sign + maybe this line can go out and have direct push of hex, and then empty pop
                pushq   %rdx                    # push and pop rdx for printing 
                movq    %rsp, %rdi              # move address of the negative sign to rdi to print

                pushq   %rax                    # push and pop rax for printing
                call    print
                popq    %rax

                popq    %rdx                    # push and pop rdx for printing

                movq    $(-1), %r13             # multiply with negative to get positive
                imulq   %r13                    # push positive number on the stack
                movq    $0, %r13                # r13 has to be 0 for loop unsigned to work
                jmp     loop_unsigned           # jump to unsigned

    return:
    # epilogue
    popq %r12
    popq %r13
    popq %r14
    popq %r15
    movq    %rbp, %rsp
    popq    %rbp
    ret


print:  # print single character
    #prologue
    pushq   %rbp
    movq    %rsp, %rbp

    # Perform sys write sys call
    movq    $1, %rdx        # number of bits printed
    movq    %rdi, %rsi  
    movq    $1, %rax        # system call 1 is sys_write
    movq    $1, %rdi        # fist argument is where to write, stdout is 1
    syscall

    # epilogue
    movq    %rbp, %rsp
    popq    %rbp
    ret
