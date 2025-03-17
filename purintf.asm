

section .text
        global _start

_start:
        lea rsi, [strr]
        call purintf


purintf:
        push r9
        push r8
        push rcx
        push rdx
        push rsi
        push rdi

        call purintf_help

        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop r8
        pop r9
        ret

purintf_help:

        lea r13, [buf]
        lea r12, [h]                ;mov r12, rdi    ;|      Getting
        push rcx        ;|
        call linelen    ;|      Line Length
        pop rcx

        mov r10, rax    ;|      Saving It
        xor rax, rax    ;|

        xor r11, r11    ;|
        inc r11         ;|      Args Counter
        inc r11         ;|

        lea r12, [h]                ;mov r12, rdi

; -----------------------------------
        purintf_cycle:
                mov al, [r12]   ; Moving char from line to rax
                inc r12         ; Incrementing line address
                dec r10         ; Decrementing linelen
                cmp r10, 0
                je purintf_end

                cmp al, '%'    ; Going to % jmp table
                je percents

                _default:
                mov [r13], al  ; Copying a byte if it is not starting with percent
                inc r13
                jmp purintf_cycle
        purintf_end:
; -------------------------------------

        lea rsi, [buf]
        mov rdi, 1
        lea r12, [buf]
        call linelen
        push rax
        pop rdx
        mov rax, 1
        syscall

percents:

        mov al, [r12]
        inc r12
        dec r10

        push rax

        cmp al, '%'
        je _prcnt

        sub rax, 'b'
        shl rax, 3

        add rax, jmp_table

        jmp [rax]

section .rodata

jmp_table:
        dq _b
        dq _c
        dq _d
        dq 'o' - 'd'- 1  dup _default
        dq _o
        dq 's' - 'o' - 1 dup  _default
        dq _s
        dq 'x' - 's' - 1 dup _default
        dq _x

section .text

; ----------------------------------
; Entry:        Line address in r12
; Return:       Line length in ax
; Destr:        rcx, r12
; ----------------------------------

linelen:
        xor rax, rax
        chzr:
                mov cl, [r12]
                cmp cl, 0
                je chzr_end
                inc r12
                inc rax
                jmp chzr

        chzr_end:
        inc rax
        ret

; -------------------------------|

;               <1>

frsArg:                         ;|
        push rdi                ;|
        pop rax                 ;|
        jmp getArg_end          ;|
                                ;|
;               <2>

scnArg:                         ;|
        push rsi                ;|
        pop rax                 ;|
        jmp getArg_end          ;|
                                ;|

;               <3>

thrArg:                         ;|
        push rdx                ;|
        pop rax                 ;|
        jmp getArg_end          ;|
                                ;|

;               <4>

frtArg:                         ;|
        push rcx                ;|
        pop rax                 ;|
        jmp getArg_end          ;|
                                ;|

;               <5>

fthArg:                         ;|
        push r8                 ;|
        pop rax                 ;|
        jmp getArg_end          ;|
                                ;|

;               <6>

sxtArg:                         ;|
        push r9                 ;|
        pop rax                 ;|
        jmp getArg_end          ;|
                                ;|

;---------Getting Arg------------|

getArg:                         ;|
        cmp r11, 1              ;|
        je frsArg               ;|
                                ;|
        cmp r11, 2              ;|
        je scnArg               ;|
                                ;|
        cmp r11, 3              ;|
        je thrArg               ;|
                                ;|
        cmp r11, 4              ;|
        je frtArg               ;|
                                ;|
        cmp r11, 5              ;|
        je fthArg               ;|
                                ;|
        cmp r11, 6              ;|
        je sxtArg               ;|
                                ;|
                                ;|
        getArg_end:             ;|
        inc r11
        ret                     ;|
; -------------------------------|

_c:
        pop rax
        call getArg
        mov [r13], al
        inc r13
        jmp purintf_cycle

_s:
        pop rax
        call getArg
        push r12

        mov r12, rax
        push r12
        call linelen
        pop r12

        push r11
        mov r11, rax

        cmp r11, 128
        ja _s_syscall
        cmp r11, 64
        ja _s_write_buf

        xor rax, rax

        string_loop:
                mov al, [r12]
                inc r12
                cmp al, 0
                je string_loop_end
                mov [r13], al
                inc r13
                jmp string_loop

        string_loop_end:
        pop r11
        pop r12

        jmp purintf_cycle

_s_syscall:
        push rsi
        push rdx
        push rdi
        push rax

        mov rdx, r11
        mov rsi, r12
        mov rdi, 1
        mov rax, 1
        syscall

        pop rax
        pop rdi
        pop rdx
        pop rsi

        jmp string_loop_end

_s_write_buf:
        push rsi
        push r12
        push r11
        push rax
        push rdx
        push rdi
        push rcx

        lea r12, [buf]
        call linelen

        mov rdx, rax
        lea rsi, [buf]
        mov rdi, 1
        mov rax, 1
        syscall

        mov rcx, rdx
        mov al, 0
        lea rdi, [buf]
        rep stosb

        pop rcx
        pop rdi
        pop rdx
        pop rax
        pop r11
        pop r12
        pop rsi

        jmp string_loop





;--------------------------------
; Entry: degree in r14
; Exit:  number in buf
; Destr: rax, rb
;--------------------------------

num2str:
        call getArg
        push r11
        lea r11, [num_buf]
        inc r11

        push rdx
        push rbx

        xor rdx, rdx
        xor rbx, rbx


        mov rbx, r14

        num2str_loop:

        xor rdx, rdx

        div rbx         ; div

        cmp dl, 0x09
        ja alph

        add dl, 0x30    ; adding 30 to mod

        num2str_jmp:
        mov [r11], dl   ; copying to buf
        inc r11         ; moving buf pointer

        test rax, rax   ; checking if zero
        jz num2str_end  ;

        jmp num2str_loop

        num2str_end:
        dec r11

        cmp r14, 2
        je two

        cmp r14, 8
        je eight

        cmp r14, 16
        je sixteen

        jmp copy_num2str

        two:
        mov byte [r13], '0'
        inc r13
        mov byte [r13], 'b'
        inc r13
        jmp copy_num2str

        eight:
        mov byte [r13], '0'
        inc r13
        jmp copy_num2str

        sixteen:
        mov byte [r13], '0'
        inc r13
        mov byte [r13], 'x'
        inc r13

        copy_num2str:
                push r10
                mov r10, [r11]
                mov byte [r11], 0
                mov [r13], r10
                pop r10

                inc r13
                dec r11
                cmp r11, num_buf
                je copy_num2str_end
                jmp copy_num2str

        copy_num2str_end:

        pop rbx
        pop rdx
        pop r11
        ret

        alph:
        add dl, 0x37
        jmp num2str_jmp

_d:
        pop rax
        mov r14, 10
        call num2str
        jmp purintf_cycle

_x:
        pop rax
        mov r14, 16
        call num2str
        jmp purintf_cycle

_o:
        pop rax
        mov r14, 8
        call num2str
        jmp purintf_cycle

_b:
        pop rax
        mov r14, 2
        call num2str
        jmp purintf_cycle

_prcnt:
        pop rax
        mov byte [r13], '%'
        inc r13
        jmp purintf_cycle

        section .data


;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
;/ / / /<data section>  / / / / / / /
;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

section .data

buf times 128 db 0
num_buf times 64 db 0

h db "1 %s", 0
strr db "hellloo\n", 0
BUFLEN equ 128
