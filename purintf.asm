

section .text
        global purintf

; _start:
        ; mov rsi, 40
        ; call purintf


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
        lea r12, [h]               ;mov r12, rdi    ;|      Getting
        push rcx        ;|
        call linelen    ;|      Line Length
        pop rcx

        push rax        ;|      Pushing line length

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

                mov [r13], al  ; Copying a byte if it is not starting with percent
                inc r13
                jmp purintf_cycle
        purintf_end:
; -------------------------------------

        lea rsi, [buf]
        mov rdi, 1
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
        jmp purintf_cycle

_d:
        jmp purintf_cycle


        section .data


;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
;/ / / / <data section>  / / / / / / /
;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

buf times 128 db 0
h db "hello %c", 0
BUFLEN equ 128
