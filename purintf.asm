

section .text
        global _start

_start:
        mov rsi, 5
        lea rdx, [strr]
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
        lea r12, [h]        ;mov r12, rdi    ;|      Getting
        push rcx        ;|
        call linelen    ;|      Line Length
        pop rcx

        mov r10, rax    ;|      Saving It
        xor rax, rax    ;|

        xor r11, r11    ;|
        inc r11         ;|      Args Counter
        inc r11         ;|

        lea r12, [h]        ;mov r12, rdi

; -----------------------------------
        purintf_cycle:
                mov al, [r12]   ; Moving char from line to rax
                inc r12         ; Incrementing line address
                dec r10         ; Decrementing linelen
                cmp r10, 0
                je purintf_end

                cmp al, '%'    ; Going to % jmp table
                je percents

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

        mov rax, 60
        syscall

percents:

        mov al, [r12]
        inc r12
        dec r10

        cmp al, 'c'
        je _c

        cmp al, 's'
        je _s

        cmp al, 'd'
        je _d

        cmp al, 'x'
        je _x

        cmp al, 'o'
        je _o

        cmp al, 'b'
        je _b

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
        call getArg
        mov [r13], al
        inc r13
        jmp purintf_cycle

_s:
        call getArg
        push r12

        mov r12, rax
        push r12
        call linelen
        pop r12

        push r11
        mov r11, rax

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

_d:
        call getArg
        push r11
        lea r11, [num_buf]
        inc r11
        push rbx         ; Saving rbx

        xor rbx, rbx

        mov bl, 10      ; Copying 10 to div

        digit_loop:

        push rdx        ; Saving rdx

        xor rdx, rdx
        div rbx         ; div
        add dl, 0x30    ; adding 30 to mod


        mov [r11], dl   ; copying to buf
        inc r11         ; moving buf pointer

        pop rdx

        test rax, rax   ; checking if zero
        jz digit_end    ;

        jmp digit_loop

        digit_end:

        dec r11
        copy_digit:
                push r10
                mov r10, [r11]
                mov byte [r11], 0
                mov [r13], r10
                pop r10

                inc r13
                dec r11
                cmp r11, num_buf
                je copy_end
                jmp copy_digit

        copy_end:
        pop rbx
        pop r11
        jmp purintf_cycle

_x:
        call getArg
        push r11
        lea r11, [num_buf]
        inc r11

        push rdx
        push rbx

        xor rdx, rdx
        xor rbx, rbx


        mov bl, 16

        x_loop:

        xor rdx, rdx

        div rbx         ; div

        cmp dl, 0x09
        ja alph

        add dl, 0x30    ; adding 30 to mod

        buf_jmp:
        mov [r11], dl   ; copying to buf
        inc r11         ; moving buf pointer

        test rax, rax   ; checking if zero
        jz x_end    ;

        jmp x_loop

        x_end:

        dec r11
        mov byte [r13], '0'
        inc r13
        mov byte [r13], 'x'
        inc r13

        copy_x:
                push r10
                mov r10, [r11]
                mov byte [r11], 0
                mov [r13], r10
                pop r10

                inc r13
                dec r11
                cmp r11, num_buf
                je copy_x_end
                jmp copy_x

        copy_x_end:

        pop rbx
        pop rdx
        pop r11
        jmp purintf_cycle

        alph:
                add dl, 0x37
                jmp buf_jmp

_o:
        call getArg
        push r11
        lea r11, [num_buf]
        inc r11
        push rbx         ; Saving rbx

        xor rbx, rbx

        mov bl, 8       ; Copying 8 to div

        o_loop:

        push rdx        ; Saving rdx

        xor rdx, rdx
        div rbx         ; div
        add dl, 0x30    ; adding 30 to mod


        mov [r11], dl   ; copying to buf
        inc r11         ; moving buf pointer

        pop rdx

        test rax, rax   ; checking if zero
        jz o_end        ;

        jmp o_loop

        o_end:

        dec r11
        copy_o:
                push r10
                mov r10, [r11]
                mov byte [r11], 0
                mov [r13], r10
                pop r10

                inc r13
                dec r11
                cmp r11, num_buf
                je copy_o_end
                jmp copy_o

        copy_o_end:
        pop rbx
        pop r11
        jmp purintf_cycle

_b:
        call getArg
        push r11
        lea r11, [num_buf]
        inc r11
        push rbx         ; Saving rbx

        xor rbx, rbx

        mov bl, 2       ; Copying 8 to div

        b_loop:

        push rdx        ; Saving rdx

        xor rdx, rdx
        div rbx         ; div
        add dl, 0x30    ; adding 30 to mod


        mov [r11], dl   ; copying to buf
        inc r11         ; moving buf pointer

        pop rdx

        test rax, rax   ; checking if zero
        jz b_end        ;

        jmp b_loop

        b_end:

        dec r11
        mov byte [r13], '0'
        inc r13
        mov byte [r13], 'b'
        inc r13
        copy_b:
                push r10
                mov r10, [r11]
                mov byte [r11], 0
                mov [r13], r10
                pop r10

                inc r13
                dec r11
                cmp r11, num_buf
                je copy_b_end
                jmp copy_b

        copy_b_end:
        pop rbx
        pop r11
        jmp purintf_cycle

        section .data


;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
;/ / / /<data section>  / / / / / / /
;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

buf times 128 db 0
num_buf times 64 db 0

h db "%b %s \n \\\\", 0
strr db "hello world", 0
BUFLEN equ 128
