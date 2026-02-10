.section .text
.global surfaceTensionCalc


surfaceTensionCalc:
    ; Save all registers we'll use
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r28
    push r29
    
    ; Set up frame pointer
    in r28, 0x3d
    in r29, 0x3e
    
    ; Save input parameters to preserved registers
    ; P0 is in r25:r24:r23:r22 -> save to r2:r3:r4:r5
    movw r2, r22    ; Move lower word
    movw r4, r24    ; Move upper word
    
    ; P1 is in r21:r20:r19:r18 -> save to r6:r7:r8:r9
    movw r6, r18
    movw r8, r20
    
    ; d is in r17:r16:r15:r14 -> save to r10:r11:r12:r13
    movw r10, r14
    movw r12, r16
    
    ; Calculate P2 = P0 + h * d * g
    ; First calculate h = 0.155 (h0 + r = 0.15 + 0.005)
    ldi r22, 0x52   ; 0.155 in IEEE-754 format
    ldi r23, 0xB8
    ldi r24, 0x1E
    ldi r25, 0x3E
    
    ; Move d to working registers for multiplication
    movw r18, r10   ; Move saved d value
    movw r20, r12
    
    ; Call AVR libc multiply
    call __mulsf3   ; h * d
    
    ; Result is in r25:r24:r23:r22
    ; Load g (9.81)
    push r22        ; Save h*d result
    push r23
    push r24
    push r25
    
    ldi r18, 0xC3   ; 9.81 in IEEE-754 format
    ldi r19, 0xF5
    ldi r20, 0x1C
    ldi r21, 0x41
    
    pop r25         ; Restore h*d
    pop r24
    pop r23
    pop r22
    
    call __mulsf3   ; (h*d) * g
    
    ; Add P0 to get P2
    movw r18, r2    ; Move saved P0
    movw r20, r4
    
    call __addsf3   ; P2 = P0 + (h*d*g)
    
    ; Save P2 temporarily
    push r22
    push r23
    push r24
    push r25
    
    ; Calculate P1 - P2
    movw r22, r6    ; Move saved P1
    movw r24, r8
    
    pop r21         ; Restore P2
    pop r20
    pop r19
    pop r18
    
    call __subsf3   ; P1 - P2
    
    ; Multiply by r/2 (0.005/2 = 0.0025)
    push r22        ; Save (P1-P2)
    push r23
    push r24
    push r25
    
    ldi r18, 0x0A   ; 0.0025 in IEEE-754 format
    ldi r19, 0xD7
    ldi r20, 0xA3
    ldi r21, 0x3B
    
    pop r25         ; Restore (P1-P2)
    pop r24
    pop r23
    pop r22
    
    call __mulsf3   ; Final result = (P1-P2) * (r/2)
    
    ; Result is now in r25:r24:r23:r22
    
    ; Restore saved registers
    pop r29
    pop r28
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    
    ret