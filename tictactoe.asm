
data segment       
    new_line db 13, 10, "$"
    
    game_draw db "_|_|_", 13, 10
              db "_|_|_", 13, 10
              db "_|_|_", 13, 10, "$"   
              
               
    
    ;Allocates space for an array game_pointer with 9 elements.
    ; This array will store pointers to positions in game_draw.                                 
    game_pointer db 9 DUP(?)  
    
    
    win_flag db 0 
    player db "0$"     
    
    
     
     ;   Messages for different game states and instructions.
     ; each ending with newlines and "$" for formatting.
    game_over_message db "Game Over", 13, 10, "$"    
    game_start_message db "Start", 13, 10, "$"
    player_message db "PLAYER $"   
    win_message db " WIN!$"   
    type_message db "TYPE A POSITION: $"
ends

stack segment 
                
    
    dw   128  dup(?)     
    ; Declares a stack segment with 128 words (each word is 2 bytes)
    
ends         

extra segment
    
ends

code segment
start:
    ; set segment registers   
    ; This part sets the segment registers (ds and es) to the addresses of the data and extra segments.
    mov     ax, data
    mov     ds, ax
    mov     ax, extra
    mov     es, ax

    ; game start   
    call    set_game_pointer    
            
main_loop:  
    call    clear_screen   
      
    ;display the game start message  
    lea     dx, game_start_message 
    call    print
     
    ; Displays a newline for formatting. 
    lea     dx, new_line
    call    print                      
                   
    ;Displays the player message and the current player ("0" or "1").               
    lea     dx, player_message
    call    print
    lea     dx, player
    call    print  
    
    ;Displays another newline for formatting.
    lea     dx, new_line
    call    print    
    
    ;Displays the current state of the Tic-Tac-Toe game.
    lea     dx, game_draw
    call    print    
    
    lea     dx, new_line
    call    print    
    
    
    ;Displays the message prompting the player to type a position.
    lea     dx, type_message    
    call    print            
                        
    ; read draw position 
    ;Calls the read_keyboard subroutine to get the player's input.                  
    call    read_keyboard
    
                       
    ; calculate draw position 
    ;Subtracts 49 from the ASCII value of the input to convert it to a valid array index.
    ;Calls the update_draw subroutine to update the game state.                  
    sub     al, 49               
    mov     bh, 0
    mov     bl, al                                  
                                  
    call    update_draw                                    
                                                          
    call    check  
                       
    ; check if game ends
    ;Compares the win flag to 1. If true, jumps to the game_over label.                   
    cmp     win_flag, 1  
    je      game_over  
                     
    
    ; Calls the change_player subroutine to switch the current player.                
    call    change_player 
    
    
    ;Jumps back to the main_loop label to continue the game.        
    jmp     main_loop 
    
      

;;;SUBROUTINES      
      
 ; Flips the value of the current player (XOR with 1).   
change_player:   
    lea     si, player    
    xor     ds:[si], 1 
    
    ret
      
      
      
;Updates the game state based on the current player's move (X or O).      
update_draw:
    mov     bl, game_pointer[bx]
    mov     bh, 0
    
    lea     si, player
    
    cmp     ds:[si], "0"
    je      draw_x     
                  
    cmp     ds:[si], "1"
    je      draw_o              
                  
    draw_x:
    mov     cl, "x"
    jmp     update

    draw_o:          
    mov     cl, "o"  
    jmp     update    
          
    update:         
    mov     ds:[bx], cl
      
    ret 
       

;Calls the check_line subroutine to check for a win.       
check:
    call    check_line
    ret     
       
 
;Checks for a winning line on the Tic-Tac-Toe board.       
check_line:
    mov     cx, 0
    
    check_line_loop:     
    cmp     cx, 0
    je      first_line
    
    cmp     cx, 1
    je      second_line
    
    cmp     cx, 2
    je      third_line  
    
    call    check_column
    ret    
        
    first_line:    
    mov     si, 0   
    jmp     do_check_line   

    second_line:    
    mov     si, 3
    jmp     do_check_line
    
    third_line:    
    mov     si, 6
    jmp     do_check_line        

    do_check_line:
    inc     cx
  
    mov     bh, 0
    mov     bl, game_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      check_line_loop
    
    inc     si
    mov     bl, game_pointer[si]    
    cmp     al, ds:[bx]
    jne     check_line_loop 
      
    inc     si
    mov     bl, game_pointer[si]  
    cmp     al, ds:[bx]
    jne     check_line_loop
                 
                         
    mov     win_flag, 1
    ret         
       
       
  
; Checks for a winning column on the Tic-Tac-Toe board.       
check_column:
    mov     cx, 0
    
    check_column_loop:     
    cmp     cx, 0
    je      first_column
    
    cmp     cx, 1
    je      second_column
    
    cmp     cx, 2
    je      third_column  
    
    call    check_diagonal
    ret    
        
    first_column:    
    mov     si, 0   
    jmp     do_check_column   

    second_column:    
    mov     si, 1
    jmp     do_check_column
    
    third_column:    
    mov     si, 2
    jmp     do_check_column        

    do_check_column:
    inc     cx
  
    mov     bh, 0
    mov     bl, game_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      check_column_loop
    
    add     si, 3
    mov     bl, game_pointer[si]    
    cmp     al, ds:[bx]
    jne     check_column_loop 
      
    add     si, 3
    mov     bl, game_pointer[si]  
    cmp     al, ds:[bx]
    jne     check_column_loop
                 
                         
    mov     win_flag, 1
    ret        


;Checks for a winning diagonal on the Tic-Tac-Toe board.
check_diagonal:
    mov     cx, 0
    
    check_diagonal_loop:     
    cmp     cx, 0
    je      first_diagonal
    
    cmp     cx, 1
    je      second_diagonal                         
    
    ret    
        
    first_diagonal:    
    mov     si, 0                
    mov     dx, 4 ;tamanho do pulo
    jmp     do_check_diagonal   

    second_diagonal:    
    mov     si, 2
    mov     dx, 2
    jmp     do_check_diagonal       

    do_check_diagonal:
    inc     cx
  
    mov     bh, 0
    mov     bl, game_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      check_diagonal_loop
    
    add     si, dx
    mov     bl, game_pointer[si]    
    cmp     al, ds:[bx]
    jne     check_diagonal_loop 
      
    add     si, dx
    mov     bl, game_pointer[si]  
    cmp     al, ds:[bx]
    jne     check_diagonal_loop
                 
                         
    mov     win_flag, 1
    ret  
           

;Displays the game over screen with the result (win or draw).
game_over:        
    call    clear_screen   
    
    lea     dx, game_start_message 
    call    print
    
    lea     dx, new_line
    call    print                          
    
    lea     dx, game_draw
    call    print    
    
    lea     dx, new_line
    call    print

    lea     dx, game_over_message
    call    print  
    
    lea     dx, player_message
    call    print
    
    lea     dx, player
    call    print
    
    lea     dx, win_message
    call    print 

    jmp     fim    
  

; Initializes the game_pointer array with indices pointing to different positions in game_draw.     
set_game_pointer:
    lea     si, game_draw
    lea     bx, game_pointer          
              
    mov     cx, 9   
    
    loop_1:
    cmp     cx, 6
    je      add_1                
    
    cmp     cx, 3
    je      add_1
    
    jmp     add_2 
    
    add_1:
    add     si, 1
    jmp     add_2     
      
    add_2:                                
    mov     ds:[bx], si 
    add     si, 2
                        
    inc     bx               
    loop    loop_1 
 
    ret  
         

;Subroutine to print the content of the DX register (message) to the console using DOS interrupt 21h.     
print:      ; print dx content  
    mov     ah, 9
    int     21h   
    
    ret 
    
 
; Subroutine to clear the console screen using DOS interrupt 10h.
clear_screen:       
    mov     ah, 0fh
    int     10h   
    
    mov     ah, 0
    int     10h
    
    ret
       

;Subroutine to read a key from the keyboard and return the ASCII code in the AH register using DOS interrupt 21h    
read_keyboard:
    mov     ah, 1       
    int     21h  
    
    ret      
      
;An infinite loop that effectively ends the program.      
fim:
    jmp     fim         


;Ends the code segment and specifies the entry point (start) for the program      
code ends

end start
