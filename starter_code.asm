;=================================================
; Name: Maksim Kulbaev
; Email: mkulb002@ucr.edu
; 
; Lab: lab 9
; Lab section: 024
; TA: James Luo
;=================================================

; test harness
.orig x3000

    ld r3, stack_base         ; current stack pointer
    ld r4, stack_base         ; base stack pointer
    ld r5, stack_max          ; max stack pointer
    
    ld r6, sub_stack_push_ptr ; load pointer to stack push subroutine into r6
    
    ld r0, hardcode_7         ; load hardcoded decimal 7 into r0
    jsrr r6                   ; push onto top of the stack
    
    ld r0, hardcode_6         ; load hardcoded decimal 6 into r0
    jsrr r6                   ; push onto top of the stack
    
    ld r0, hardcode_5         ; load hardcoded decimal 5 into r0
    jsrr r6                   ; push onto top of the stack
    
    ld r0, hardcode_4         ; load hardcoded decimal 4 into r0
    jsrr r6                   ; push onto top of the stack
    
    ld r0, hardcode_3         ; load hardcoded decimal 3 into r0
    jsrr r6                   ; push onto top of the stack
    
    ld r6, sub_polish_add_ptr ; load pointer to polish add subroutine into r6
    
    jsrr r6                   ; do x = 3 + 4
    jsrr r6                   ; do x += 5
    jsrr r6                   ; do x += 6
    jsrr r6                   ; do x += 7
    
    ld r6, sub_stack_pop_ptr  ; load pointer to stack pop subroutine into r6
    jsrr r6                   ; pop the final result from the stack
    
    and r4, r4, #0            ; finally, reset value at r4
    not r4, r4                ; set all its bits to 1
    and r4, r4, r0            ; and store result in r4
    
    halt                      ; terminate program
;-----------------------------------------------------------------------------------------------
; test harness local data:
stack_base         .fill    xA000 ; stack base pointer
stack_max          .fill    xA100 ; stack max pointer
sub_stack_push_ptr .fill    x3200 ; x3200 subroutine pointer
sub_stack_pop_ptr  .fill    x3400 ; x3400 subroutine pointer
sub_polish_add_ptr .fill    x3600 ; x3600 subroutine pointer

hardcode_7         .fill    #7    ; hardcoded decimal 7
hardcode_6         .fill    #6    ; hardcoded decimal 6
hardcode_5         .fill    #5    ; hardcoded decimal 5
hardcode_4         .fill    #4    ; hardcoded decimal 4
hardcode_3         .fill    #3    ; hardcoded decimal 3
;-----------------------------------------------------------------------------------------------
.end ; end of current section
;===============================================================================================



; subroutines:

;------------------------------------------------------------------------------------------
; Subroutine: SUB_STACK_PUSH
;
; Parameter (R0): The value to push onto the stack
; Parameter (R3): TOS (Top of Stack): A pointer to the current top of the stack
; Parameter (R4): BASE: A pointer to the base (one less than the lowest available
;                       address) of the stack
; Parameter (R5): MAX: The "highest" available address in the stack
;
; Postcondition: The subroutine has pushed (R0) onto the stack (i.e to address TOS+1). 
;		         If the stack was already full (TOS = MAX), the subroutine has printed 
;		         an overflow error message and terminated.
;
; Return Value: R3 ← updated TOS
;------------------------------------------------------------------------------------------
.orig x3200

    st r1, backup_r1_3200    ; store backup for r1
    st r7, backup_r7_3200    ; store backup for r7
    
    not r1, r3               ; get 2's complement of current stack pointer
    add r1, r1, #1           ; don't forget the 1
    add r1, r1, r5           ; subtract to see if stack ptr is less than stack max
    
    brnz label_overflow_3200 ; jump if stack overflows
    
    add r3, r3, #1           ; increment stack pointer
    str r0, r3, #0           ; store whatever is at r0 on top of the stack
    
    ld r1, backup_r1_3200    ; restore backup for r1
    ld r7, backup_r7_3200    ; restore backup for r7
    ret                      ; return
    
label_overflow_3200
    lea r0, overflows_3200   ; load overflow string
    puts                     ; print it to console
    halt                     ; terminate program
;-----------------------------------------------------------------------------------------------
; SUB_STACK_PUSH local data
backup_r1_3200 .blkw #1 ; backup for r1
backup_r7_3200 .blkw #1 ; backup for r7
overflows_3200 .stringz "\nStack overflow!\n"
;-----------------------------------------------------------------------------------------------
.end ; end of current region
;===============================================================================================



;------------------------------------------------------------------------------------------
; Subroutine: SUB_STACK_POP
;
; Parameter (R3): TOS (Top of Stack): A pointer to the current top of the stack
; Parameter (R4): BASE: A pointer to the base (one less than the lowest available                      
;                       address) of the stack
; Parameter (R5): MAX: The "highest" available address in the stack
;
; Postcondition: The subroutine has popped MEM[TOS] off of the stack.
;		         If the stack was already empty (TOS = BASE), the subroutine has 
;                printed an underflow error message and terminated.
;
; Return Value: R0 ← value popped off the stack
;		        R3 ← updated TOS
;------------------------------------------------------------------------------------------
.orig x3400

    st r1, backup_r1_3400     ; store backup for r1
    st r7, backup_r7_3400     ; store backup for r7
    
    not r1, r4                ; get 2's complement of base stack pointer
    add r1, r1, #1            ; don't forget the 1
    add r1, r1, r3            ; subtract to see if stack ptr is greater than stack base
    
    brnz label_underflow_3400 ; jump if stack underflows
    
    ldr r0, r3, #0            ; pop whatever is on top of the stack into r0
    add r3, r3, #-1           ; decrement stack pointer
    
    ld r1, backup_r1_3400     ; restore backup for r1
    ld r7, backup_r7_3400     ; restore backup for r7
    ret                       ; return
    
label_underflow_3400
    lea r0, underflow_3400    ; load underflow string
    puts                      ; print it to console
    halt                      ; terminate program
;-----------------------------------------------------------------------------------------------
; SUB_STACK_POP local data
backup_r1_3400 .blkw #1 ; backup for r1
backup_r7_3400 .blkw #1 ; backup for r7
underflow_3400 .stringz "\nStack underflow!\n"
;-----------------------------------------------------------------------------------------------
.end ; end of current section
;===============================================================================================



;------------------------------------------------------------------------------------------
; Subroutine: SUB_POLISH_ADD
;
; Parameter (R3): TOS (Top of Stack): A pointer to the current top of the stack
; Parameter (R4): BASE: A pointer to the base (one less than the lowest available                      
;                       address) of the stack
; Parameter (R5): MAX: The "highest" available address in the stack
;
; Postcondition: The subroutine has popped two value off from the top of the stack,
;                added them together, and pushed on top of the stack.
;
; Return Value: R3 ← updated TOS
;------------------------------------------------------------------------------------------
.orig x3600

    st r0, backup_r0_3600      ; store backup for r0
    st r1, backup_r1_3600      ; store backup for r1
    st r6, backup_r6_3600      ; store backup for r6
    st r7, backup_r7_3600      ; store backup for r1
    
    ld r6, sub_stack_pop_3600  ; load pointer to stack pop subroutine into r6
    
    jsrr r6                    ; call subroutine at address at r6
    
    and r1, r1, #0             ; reset value at r1
    not r1, r1                 ; set all bits to 1
    and r1, r1, r0             ; store r1 = r0
    
    jsrr r6                    ; call subroutine at address at r6
    
    add r0, r0, r1             ; add 2 popped values
    
    ld r6, sub_stack_push_3600 ; load pointer to stack push subroutine into r6
    
    jsrr r6                    ; call subroutine at address at r6
    
    ld r0, backup_r0_3600      ; restore backup for r0
    ld r1, backup_r1_3600      ; restore backup for r1
    ld r6, backup_r6_3600      ; restore backup for r6
    ld r7, backup_r7_3600      ; restore backup for r7
    ret

;-----------------------------------------------------------------------------------------------
; SUB_POLISH_ADD local data
backup_r0_3600 .blkw #1         ; backup for r0
backup_r1_3600 .blkw #1         ; backup for r1
backup_r6_3600 .blkw #1         ; backup for r6
backup_r7_3600 .blkw #1         ; backup for r7
sub_stack_push_3600 .fill x3200 ; address of stack push subroutine
sub_stack_pop_3600  .fill x3400 ; address of stack pop subroutine
;-----------------------------------------------------------------------------------------------
.end ; end of current section
;===============================================================================================



.orig xA000 ; stack
stack_A000 .blkw #100
.end ; end of program