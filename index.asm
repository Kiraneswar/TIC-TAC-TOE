; ============================================
;   TIC-TAC-TOE GAME  (8086 Assembly)
;   Works on EMU8086 / MASM (no memory-to-memory ops)
;   Player 1 = 'X' , Player 2 = 'O'
; ============================================

.model small
.stack 100h
.data

; 9 cells (ASCII '1'..'9' initially)
board db '1','2','3','4','5','6','7','8','9'

msgTitle  db 0Dh,0Ah,'*** TIC TAC TOE (8086) ***',0Dh,0Ah,'$'
msgInst   db 0Dh,0Ah,'Player 1 = X, Player 2 = O',0Dh,0Ah,'$'
msgTurn1  db 0Dh,0Ah,'Player ','$'                ; prints player number after this
msgTurn2  db ' turn. Enter position (1-9): $'
msgInvalid db 0Dh,0Ah,'Invalid move. Try again.',0Dh,0Ah,'$'
msgWin    db 0Dh,0Ah,' wins! Congratulations!',0Dh,0Ah,'$'
msgDraw   db 0Dh,0Ah,'Game Draw!',0Dh,0Ah,'$'
sepLine   db 0Dh,0Ah,'---+---+---',0Dh,0Ah,'$'
blankln   db 0Dh,0Ah,'$'

player    db '1'        ; '1' or '2'
pos       db 0          ; ascii input char stored here
moves     db 0          ; number of filled cells

.code
start:
    mov ax,@data
    mov ds,ax

    ; welcome
    lea dx,msgTitle
    mov ah,09h
    int 21h

    lea dx,msgInst
    mov ah,09h
    int 21h

main_loop:
    call display_board

    ; Print "Player " then player (1/2) then prompt
    lea dx,msgTurn1
    mov ah,09h
    int 21h

    mov dl, [player]      ; printable char '1' or '2'
    mov ah,02h
    int 21h

    lea dx,msgTurn2
    mov ah,09h
    int 21h

    ; read one char (echoed)
    mov ah,01h
    int 21h
    mov [pos], al

    call make_move
    cmp al, 1
    jne invalid_label

    ; successful move
    inc byte ptr [moves]
    call display_board

    ; check win
    call check_winner
    cmp al,1
    je player_won

    ; check draw
    mov al, [moves]
    cmp al, 9
    jne swap_and_continue

    ; draw
    lea dx,msgDraw
    mov ah,09h
    int 21h
    jmp endprog

invalid_label:
    lea dx,msgInvalid
    mov ah,09h
    int 21h
    jmp main_loop

swap_and_continue:
    call switch_player
    jmp main_loop

player_won:
    ; Print "Player <n>"
    lea dx,msgTurn1
    mov ah,09h
    int 21h
    mov dl, [player]
    mov ah,02h
    int 21h
    ; Print win text
    lea dx,msgWin
    mov ah,09h
    int 21h
    jmp endprog

; ----------------------------
; display_board - prints a 3x3 board
; ----------------------------
display_board proc
    ; print blank line
    lea dx, blankln
    mov ah,09h
    int 21h

    lea si, board

    ; Row 0: cells 0,1,2
    mov dl, [si]         ; board[0]
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, '|'
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, [si+1]
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, '|'
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, [si+2]
    mov ah,02h
    int 21h

    ; separator
    lea dx, sepLine
    mov ah,09h
    int 21h

    ; Row 1: cells 3,4,5
    lea si, board
    add si, 3
    mov dl, [si]
    mov ah,02h
    int 21h
    mov dl, ' '    ; space and separators
    mov ah,02h
    int 21h
    mov dl, '|'
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, [si+1]
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, '|'
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, [si+2]
    mov ah,02h
    int 21h

    ; separator
    lea dx, sepLine
    mov ah,09h
    int 21h

    ; Row 2: cells 6,7,8
    lea si, board
    add si, 6
    mov dl, [si]
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, '|'
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, [si+1]
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, '|'
    mov ah,02h
    int 21h
    mov dl, ' '
    mov ah,02h
    int 21h
    mov dl, [si+2]
    mov ah,02h
    int 21h

    ; final blank line
    lea dx, blankln
    mov ah,09h
    int 21h

    ret
display_board endp

; ----------------------------
; make_move - validate and place mark
; Input: [pos] = ascii key read
; Output: AL = 1 if success, 0 if invalid
; ----------------------------
make_move proc
    mov al, [pos]        ; ascii char
    cmp al, '1'
    jl bad
    cmp al, '9'
    jg bad
    sub al, '1'          ; 0..8 in AL

    ; extend AL into BX (index)
    xor bx, bx
    mov bl, al           ; BX = index

    lea si, board
    add si, bx
    mov cl, [si]         ; current content of cell
    cmp cl, 'X'
    je bad
    cmp cl, 'O'
    je bad

    ; find symbol from player: if player='1' -> 'X' else 'O'
    mov al, [player]
    cmp al, '1'
    je mark_X
    mov al, 'O'
    jmp do_mark
mark_X:
    mov al, 'X'
do_mark:
    mov [si], al
    mov al, 1
    ret

bad:
    mov al, 0
    ret
make_move endp

; ----------------------------
; switch_player: toggle '1' <-> '2'
; ----------------------------
switch_player proc
    mov al, [player]
    cmp al, '1'
    je set2
    mov byte ptr [player], '1'
    ret
set2:
    mov byte ptr [player], '2'
    ret
switch_player endp

; ----------------------------
; check_winner: AL=1 if current player's symbol has a win
; uses [player] to determine target char
; ----------------------------
check_winner proc
    mov al, 0
    mov dl, [player]
    cmp dl, '1'
    je targ_X
    mov dl, 'O'
    jmp cw_start
targ_X:
    mov dl, 'X'
cw_start:
    lea si, board

    ; row 0: [0],[1],[2]
    mov al, [si]
    cmp al, dl
    jne r1
    mov al, [si+1]
    cmp al, dl
    jne r1
    mov al, [si+2]
    cmp al, dl
    jne r1
    mov al,1
    ret
r1:
    ; row1: [3],[4],[5]
    mov al, [si+3]
    cmp al, dl
    jne r2
    mov al, [si+4]
    cmp al, dl
    jne r2
    mov al, [si+5]
    cmp al, dl
    jne r2
    mov al,1
    ret
r2:
    ; row2: [6],[7],[8]
    mov al, [si+6]
    cmp al, dl
    jne c1
    mov al, [si+7]
    cmp al, dl
    jne c1
    mov al, [si+8]
    cmp al, dl
    jne c1
    mov al,1
    ret
c1:
    ; col0: [0],[3],[6]
    mov al, [si]
    cmp al, dl
    jne c2
    mov al, [si+3]
    cmp al, dl
    jne c2
    mov al, [si+6]
    cmp al, dl
    jne c2
    mov al,1
    ret
c2:
    ; col1: [1],[4],[7]
    mov al, [si+1]
    cmp al, dl
    jne c3
    mov al, [si+4]
    cmp al, dl
    jne c3
    mov al, [si+7]
    cmp al, dl
    jne c3
    mov al,1
    ret
c3:
    ; col2: [2],[5],[8]
    mov al, [si+2]
    cmp al, dl
    jne d1
    mov al, [si+5]
    cmp al, dl
    jne d1
    mov al, [si+8]
    cmp al, dl
    jne d1
    mov al,1
    ret
d1:
    ; diag [0],[4],[8]
    mov al, [si]
    cmp al, dl
    jne d2
    mov al, [si+4]
    cmp al, dl
    jne d2
    mov al, [si+8]
    cmp al, dl
    jne d2
    mov al,1
    ret
d2:
    ; diag [2],[4],[6]
    mov al, [si+2]
    cmp al, dl
    jne no
    mov al, [si+4]
    cmp al, dl
    jne no
    mov al, [si+6]
    cmp al, dl
    jne no
    mov al,1
    ret
no:
    mov al,0
    ret
check_winner endp

endprog:
    mov ah,4Ch
    int 21h

end start
