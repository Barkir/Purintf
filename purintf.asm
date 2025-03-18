

section .text
        global purintf

; ----------------------------------|
;       PURINTF START               |
; ----------------------------------|
purintf:                           ;|
                                   ;|
        pop rax                    ;|
                                   ;|
        push r9                    ;|
        push r8                    ;|
        push rcx                   ;|
        push rdx                   ;|
        push rsi                   ;|
        push rdi                   ;|
                                   ;|
        mov r15, rbp               ;|
                                   ;|
        mov rbp, rsp               ;|
        add rbp, 8                 ;|
                                   ;|
        push rax                   ;|
;-----------------------------------|


purintf_help:

        lea r13, [buf]  ;|
        mov r12, rdi    ;|      Getting
        push rcx        ;|
        call linelen    ;|      Line Length
        pop rcx
                        ;|
        mov r10, rax    ;|      Saving It
        xor rax, rax    ;|

        xor r11, r11    ;|
        inc r11         ;|      Args Counter
        inc r11         ;|

        mov r12, rdi

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

        mov rbp, r15

        ret


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

;               jump table
;-------------------------------------- ;|
jmp_table:                              ;|
        dq _b                           ;|
        dq _c                           ;|
        dq _d                           ;|
        dq 'o' - 'd'- 1  dup _default   ;|
        dq _o                           ;|
        dq 's' - 'o' - 1 dup  _default  ;|
        dq _s                           ;|
        dq 'x' - 's' - 1 dup _default   ;|
        dq _x                           ;|
;----------------------------------------|

section .text


;       Counting Line Length
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


;       %c label
_c:
        pop rax                         ;|
                                        ;|
        mov rax, [rbp]                  ;|
        add rbp, 8                      ;|
        inc r11                         ;|
                                        ;|
        mov [r13], al                   ;|
        inc r13                         ;|
        jmp purintf_cycle               ;|
                                        ;|

;       %s label
_s:
        pop rax                         ;|
                                        ;|
        mov rax, [rbp]                  ;|
        add rbp, 8                      ;|
        inc r11                         ;|
                                        ;|
        push r12                        ;|
                                        ;|
        mov r12, rax                    ;|
        push r12                        ;|
        call linelen                    ;|
        pop r12                         ;|
                                        ;|
        push r11                        ;|
        mov r11, rax                    ;|
                                        ;|
        cmp r11, 128                    ;|
        ja _s_syscall                   ;|
        cmp r11, 64                     ;|
        ja _s_write_buf                 ;|
                                        ;|
        xor rax, rax                    ;|

        string_loop:                    ;|
                mov al, [r12]           ;|
                inc r12                 ;|
                cmp al, 0               ;|
                je string_loop_end      ;|
                mov [r13], al           ;|
                inc r13                 ;|
                jmp string_loop         ;|
                                        ;|
        string_loop_end:                ;|
        pop r11                         ;|
        pop r12                         ;|
                                        ;|
        jmp purintf_cycle               ;|

_s_syscall:                             ;|
        push rsi                        ;|
        push rdx                        ;|
        push rdi                        ;|
        push rax                        ;|

        mov rdx, r11                    ;|
        mov rsi, r12                    ;|
        mov rdi, 1                      ;|
        mov rax, 1                      ;|
        syscall                         ;|

        pop rax                         ;|
        pop rdi                         ;|
        pop rdx                         ;|
        pop rsi                         ;|
                                        ;|
        jmp string_loop_end             ;|

_s_write_buf:                           ;|
        push rsi                        ;|
        push r12                        ;|
        push r11                        ;|
        push rax                        ;|
        push rdx                        ;|
        push rdi                        ;|
        push rcx                        ;|

        lea r12, [buf]                  ;|
        call linelen                    ;|

        mov rdx, rax                    ;|
        lea rsi, [buf]                  ;|
        mov rdi, 1                      ;|
        mov rax, 1                      ;|
        syscall                         ;|

        mov rcx, rdx                    ;|
        mov al, 0                       ;|
        lea rdi, [buf]                  ;|
        rep stosb                       ;|

        pop rcx                         ;|
        pop rdi                         ;|
        pop rdx                         ;|
        pop rax                         ;|
        pop r11                         ;|
        pop r12                         ;|
        pop rsi                         ;|

        jmp string_loop                 ;|



; Function for turning dec number to string

;--------------------------------
; Entry:
; Exit:  dec number in buf
; Destr: rax, rbx, rdx
;--------------------------------

decnum2str:

        push r11
        lea r11, [num_buf]
        inc r11

        push rdx
        push rbx
        xor rbx, rbx

        push rax

        push rcx

        mov rcx, rax
        and ecx, 0x80000000
        cmp ecx, 0
        jne neg_ecx
        pop rcx

        neg_ecx_cont:
        mov rbx, 10

        decnum2str_loop:

        xor rdx, rdx

        div rbx

        cmp dl, 0x09

        add dl, 0x30            ; adding 30 to mod

        mov [r11], dl           ; copying to buf
        inc r11                 ; moving buf pointer

        test rax, rax           ; checking if zero
        jz decnum2str_end

        jmp decnum2str_loop


        decnum2str_end:
        dec r11

        pop rax

        deccopy_num2str:
                push r10
                mov r10, [r11]
                mov byte [r11], 0
                mov [r13], r10
                pop r10

                inc r13
                dec r11
                cmp r11, num_buf
                je deccopy_num2str_end
                jmp deccopy_num2str

        deccopy_num2str_end:

        pop rbx
        pop rdx
        pop r11
        ret

neg_ecx:
        pop rcx
        mov byte [r13], '-'
        inc r13

        neg eax

        pop rbx

        push rax

        jmp neg_ecx_cont

; Function for turning dec number to string

;--------------------------------
; Entry: degree in r14
; Exit:  dec number in buf
; Destr: rax, rbx, rdx
;--------------------------------

num2str:

        push r11
        lea r11, [num_buf]
        inc r11

        push rdx
        push rbx

        xor rdx, rdx
        xor rbx, rbx


        mov rbx, r14
        sub rbx, 1

        num2str_loop:

        xor rdx, rdx

        push rax

        and rax, rbx    ;|      Mod by rbx
        mov rdx, rax    ;|      moving it to rdx

        pop rax

        cmp r14, 2      ;|
        je shr_1        ;|
        cmp r14, 8      ;|
        je shr_3        ;|      Dividing part
        cmp r14, 16     ;|
        je shr_4        ;|

;<><><><><><><><><><><><><><><> <>
        shr_1:          ;>>>    <>
        shr rax, 1      ;>>>    <>
        jmp mod2text    ;>>>    <>

        shr_3:          ;>>>    <>
        shr rax, 3      ;>>>    <>
        jmp mod2text    ;>>>    <>

        shr_4:          ;>>>    <>
        shr rax, 4      ;>>>    <>
;<><><><><><><><><><><><><><><> <>

        mod2text:
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

        mov rax, [rbp]
        add rbp, 8
        inc r11

        call decnum2str
        jmp purintf_cycle

_x:
        pop rax

        mov rax, [rbp]
        add rbp, 8
        inc r11

        mov r14, 16
        call num2str
        jmp purintf_cycle

_o:
        pop rax

        mov rax, [rbp]
        add rbp, 8
        inc r11

        mov r14, 8
        call num2str
        jmp purintf_cycle

_b:
        pop rax

        mov rax, [rbp]
        add rbp, 8
        inc r11

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
