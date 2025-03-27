
%macro PUSH6 0x0
        push r9  ; 6
        push r8  ; 5
        push rcx ; 4
        push rdx ; 3
        push rsi ; 2
        push rdi ; 1
%endmacro


section .text
        global purintf

; ----------------------------------|
;       PURINTF START               |
; ----------------------------------|
purintf:                           ;|
                                   ;|
        pop rax                    ;|
                                   ;|
        PUSH6                      ;|
        mov r15, rbp               ;|
                                   ;|
        mov rbp, rsp               ;|
        add rbp, 8                 ;|
                                   ;|
        push rax                   ;|
;-----------------------------------|
                                   ;|
        mov rsi, rdi               ;|
        call linelen               ;|
                                   ;|
        mov r10, rax               ;|
        xor rax, rax               ;|
                                   ;|
        mov r11, 2                 ;|
                                   ;|
        mov rsi, rdi               ;|
        lea rdi, [buf]             ;|
                                   ;|
;----------------------------------;|

        purintf_cycle:
                lodsb  ;<-------------------|
                dec r10                    ;|
                test r10, r10              ;|
                jz purintf_end             ;|
                                           ;|
                cmp al, '%'                ;|
                je percents                ;|
                                           ;|
                _default:                  ;|
                stosb                      ;|
                jmp purintf_cycle ;<--------|
        purintf_end:
; -------------------------------------------|

        lea rsi, [buf]
        mov rdi, 1
        call linelen
        mov rdx, rax
        lea rsi, [buf]
        mov rax, 1
        syscall

        mov rbp, r15

        ret

; |################################################################|
; |////////////////////////////////////////////////////////////////|
; |################################################################|


percents:

        lodsb
        dec r10
        push rax
        cmp al, '%'
        je _prcnt
        cmp rax, 'b'
        jb _default
        cmp rax, 'x'
        ja _default
        jmp [(rax - 'b') * 8 + jmp_table]

section .rodata

;#########################################
;<<<<<<<<<<<<<< JUMP TABLE >>>>>>>>>>>>>>>
;#########################################

;-------------------------------------- ;|
jmp_table:                              ;|
        dq _b                           ;|
        dq _c                           ;|
        dq _d                           ;|
        dq _default                     ;|
        dq _f                           ;|
        dq 'o' - 'f'- 1  dup _default   ;|
        dq _o                           ;|
        dq 's' - 'o' - 1 dup  _default  ;|
        dq _s                           ;|
        dq 'x' - 's' - 1 dup _default   ;|
        dq _x                           ;|
;----------------------------------------|

section .text


; Function for counting line length
; ----------------------------------|
; Entry:        Line address in rsi |
; Return:       Line length in ax   |
; Destr:        rcx, r12            |
; ----------------------------------|

linelen:
        xor rbx, rbx

        chzr:
                lodsb
                test al, al
                jz chzr_end
                inc rbx
                jmp chzr

        chzr_end:
        mov rax, rbx
        inc rax
        ret

; |###########################################|
; |          %c, %s, %d, %o, %b, %x           |
; |###########################################|

;---------------------------------------------|

_c:
        pop rax

        mov rax, [rbp]
        add rbp, 8
        inc r11

        stosb
        jmp purintf_cycle

;----------------------------------------------|
;----------------------------------------------|

_d:
        pop rax

        mov rax, [rbp]
        add rbp, 8
        inc r11

        call decnum2str
        jmp purintf_cycle

;----------------------------------------------|
;----------------------------------------------|

_x:

        pop rax

        mov rax, [rbp]
        add rbp, 8
        inc r11

        push rcx
        mov cl,  4
        mov rbx, 15
        push rsi
        mov rsi, str_x

        call num2str

        pop rsi
        pop rcx
        jmp purintf_cycle

;----------------------------------------------|
;----------------------------------------------|

_o:
        pop rax
        mov rax, [rbp]
        add rbp, 8
        inc r11

        push rcx
        mov cl,  3
        mov rbx, 7

        push rsi
        mov rsi, str_o

        call num2str

        pop rsi
        pop rcx
        jmp purintf_cycle

;----------------------------------------------|
;----------------------------------------------|

_b:
        pop rax
        mov rax, [rbp]
        add rbp, 8
        inc r11

        push rcx
        mov cl,  1
        mov rbx, 1

        push rsi
        mov rsi, str_b

        call num2str
        pop rsi

        pop rcx
        jmp purintf_cycle

;--------------------------------------------|
;--------------------------------------------|

_f:
        pop rax

        mov rax, [rbp]
        add rbp, 8
        inc r11
        mov r14, 10
        call float2str
        jmp purintf_cycle

;--------------------------------------------|
;--------------------------------------------|

_prcnt:
        pop rax
        stosb
        jmp purintf_cycle

;--------------------------------------------|
;--------------------------------------------|

_s:
        pop rax

        mov rax, [rbp]
        add rbp, 8
        inc r11

        push rsi
        mov rsi, rax
        push rsi
        call linelen
        pop rsi

        cmp rax, 128
        ja _s_syscall
        cmp rax, 64
        ja _s_write_buf

        xor rax, rax

        string_loop:
                lodsb
                test al, al
                jz string_loop_end
                stosb
                jmp string_loop

        string_loop_end:
        pop rsi

        jmp purintf_cycle

;--------------------------------------------|
;--------------------------------------------|


_s_syscall:
        push rsi
        push rdx
        push rdi
        push rax

        mov rdx, rax
        mov rdi, 1
        mov rax, 1
        syscall

        pop rax
        pop rdi
        pop rdx
        pop rsi

        jmp string_loop_end

;--------------------------------------------|
;--------------------------------------------|


_s_write_buf:
        push rax
        push rdx
        push rdi
        push rcx

        push rsi
        lea rsi, [buf]
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
        pop rsi

        push rsi
        call linelen
        pop rsi

        mov rcx, rax
        lea rdi, [buf]

        write_buf:
        lodsb
        stosb
        dec rcx
        cmp rcx, 0
        je write_buf_end
        jmp write_buf

        write_buf_end:

        pop rcx
        pop rdi
        pop rdx
        pop rax

        jmp string_loop

;-----------------------------------------------|
;-----------------------------------------------|


; Function for turning dec number to string
;--------------------------------|
; Entry: number in rax           |
; Exit:  dec number in buf       |
; Destr: rax, rbx, rdx           |
;--------------------------------|

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

        add dl, 0x30            ; adding 30 to mod

        mov [r11], dl           ; copying to buf
        inc r11                 ; moving buf pointer

        test rax, rax           ; checking if zero
        jz decnum2str_end

        jmp decnum2str_loop


        decnum2str_end:
        dec r11

        pop rax

        push rsi
        mov rsi, r11

        deccopy_num2str:
                std
                lodsb

                inc rsi
                mov byte [rsi], 0
                dec rsi

                cld
                stosb

                cmp rsi, num_buf
                je deccopy_num2str_end
                jmp deccopy_num2str

        deccopy_num2str_end:

        pop rsi
        pop rbx
        pop rdx
        pop r11
        ret

neg_ecx:
        pop rcx
        mov byte [rdi], '-'
        inc rdi

        neg eax

        pop rbx

        push rax

        jmp neg_ecx_cont


; Function for turning dec number to string
;---------------------------------------------
; Entry: degree in r14, mask in rbx, shr in cl
; Exit:  dec number in buf
; Destr: rax, rbx, rdx
;---------------------------------------------


num2str:

        movsw

        push r11
        lea r11, [num_buf]
        inc r11

        num2str_loop:

        push rax

        and rax, rbx    ;|      Mod by rbx
        mov rdx, rax    ;|      moving it to rdx

        pop rax

        shr rax, cl

        mod2text:

        push r11
        lea r11, [alphabet]
        add r11, rdx
        mov dl, [r11]
        pop r11

        num2str_jmp:

        mov [r11], dl   ; copying to buf
        inc r11         ; moving buf pointer

        test rax, rax   ; checking if zero
        jz num2str_end  ;

        jmp num2str_loop

        num2str_end:
        dec r11

        push rsi
        mov rsi, r11


        jmp copy_num2str

        copy_num2str:
                std
                lodsb
                cld
                stosb

                cmp rsi, num_buf
                je copy_num2str_end
                jmp copy_num2str

        copy_num2str_end:

        cld

        pop rsi
        pop r11
        ret


; Function for turning float number to string
;--------------------------------|
; Entry: degree in r14           |
; Exit:  dec number in buf       |
; Destr: rax, rbx, rdx           |
;--------------------------------|

float2str:

        push r11
        lea r11, [num_buf]
        inc r11

        push rax
        push rbx
        push rcx

        mov ebx, eax

        and ebx, 0x80000000

        cmp ebx, 0
        jne no_neg_float

        mov byte [r13], '-'
        inc r13

        no_neg_float:


        mov ecx, eax
        and ecx, 0x007fffff

        mov eax, ecx

        mov rbx, 10

        float2str_loop:

        xor rdx, rdx

        div rbx

        add dl, 0x30            ; adding 30 to mod

        mov [r11], dl           ; copying to buf
        inc r11                 ; moving buf pointer

        test rax, rax           ; checking if zero
        jz float2str_end

        jmp float2str_loop


        float2str_end:
        dec r11

        copy_float2str:
                push r10
                mov r10, [r11]
                mov byte [r11], 0
                mov [r13], r10
                pop r10

                inc r13
                dec r11
                cmp r11, num_buf
                je copy_float2str_end
                jmp copy_float2str

        copy_float2str_end:

        pop rcx
        pop rbx
        pop rax
        pop r11

        ret


        section .data


;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
;/ / / /<data section>  / / / / / / /
;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

section .data

; 64 green zone addition
buf times 128 + 64 db 0

alphabet db "0123456789ABCDEF"

str_b db '0b'
str_x db '0x'
str_o db '0o'

num_buf times 64 db 0
