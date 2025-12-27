; getname.s
; by Lars Kellogg-Stedman <lars@oddbit.com>
;
; An experiment in reading user input
; and simplifying code through the use
; of macros.

SCNKEY      = $FF9F
GETIN       = $FFE4
CHROUT      = $FFD2

*           = $0061                     ; reserve some zero page locations
strlen      .byte ?                     ; max input length for readln
strbase     .word ?                     ; string base address for println
                                        ; or readln
savey       .byte ?                     ; temporary storage for y register

; wrapper for xprintln function
println     .macro addr
            lda #<\addr                 ; store address of string in strbase...
            sta strbase
            lda #>\addr                 ; ...and strbase+1
            sta strbase+1
            jsr xprintln                ; and call xprintln
            .endm

; wrapper for xreadln function
readln      .macro addr, maxlen
            lda #\maxlen                ; store maxlen in strlen
            sta strlen
            lda #<\addr                 ; store address of string in strbase...
            sta strbase
            lda #>\addr                 ; ...and strbase+1
            sta strbase+1
            jsr xreadln                 ; and call xreadln
            .endm

; BASIC bootstrap. This is a small BASIC
; program that will call `sys $c000`
; (aka `sys 49152`). This allows us to
; run this program with vice by just
; running `x64sc ./a.out`, for example.
*           = $0801
            .word $080c
            .word $000a                 ; 10
            .byte $9e                   ; SYS
            .null "49152"               ; $C000
            .word 0

*           = $C000

; main program starts here
main        #println name_prompt        ; print prompt for name
            #readln corp_name, 20       ; read response
            #println num_prompt         ; print prompt for registration number
            #readln reg_number, 20      ; read response
            #println name_conf          ; print confirmation prompt
            #println corp_name          ; print name response
            #println reg_number         ; print number response

            ; return to BASIC
            rts

; expects the max length in variable
; 'strlen' and stores the input into the
; memory location pointed to by
; 'strbase'.
xreadln     .proc
            lda #0
            sta savey
            sta lastchar
top         jsr SCNKEY                  ; scan keyboard
            jsr GETIN                   ; read key into a
            beq top                     ; loop if nothing was pressed
            cmp #$20                    ; is this a space character?
            bne output                  ; if not process it normally
            cmp lastchar                ; otherwise skip it if the last
            beq top                     ; character was also a space
output      jsr CHROUT                  ; print character to screen
            cmp #13                     ; check for EOL
            beq end                     ; if we found EOL we're done reading
                                        ; input
            sta lastchar
            ldy savey
            sta (strbase),y             ; save character to variable
            iny
            sty savey
            cpy strlen                  ; check length of response against
                                        ; max length
            beq limit                   ; exit if we've hit the limit
            jmp top                     ; otherwise continue reading characters

limit       lda #13                     ; if we exit due to length, print a
            jsr CHROUT                  ; carriage return

end         ldy savey                   ; add null terminator to string
            lda #0
            sta (strbase),y

            rts
            .pend

; prints the null terminated string
; whose address is stored in variable
; 'strbase'.
xprintln    .proc
            ldy #0
top         lda (strbase),y             ; load next character to print
            beq end                     ; exit on NUL
            jsr CHROUT                  ; print character
            iny
            jmp top
end         lda #$0d                    ; print carriage return
            jsr CHROUT
            lda #$0a                    ; print newline
            jsr CHROUT
            rts
            .pend

; variable storage
corp_name   .fill 21, 0
reg_number  .fill 21, 0
name_prompt .null "what is the name of your corporation?"
num_prompt  .null "new astro mining corp reg. number?"
name_conf   .null "you typed:"
lastchar    .byte ?                     ; last character read
