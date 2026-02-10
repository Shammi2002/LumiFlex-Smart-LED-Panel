.global PBmaxCalc
.section .text


PBmaxCalc:
    ; Save registers
    push r28
    push r29
    push r16
    push r17
    
    ; Move array pointer to Y
    movw r28, r24
    
    ; Initialize max value with first element
    ld r16, Y+
    ld r17, Y+
    
    ; Load size into counter
    mov r24, r22
    dec r24  ; Decrement because we already loaded first element
    
loop:
    ; Check if we're done
    tst r24
    breq done
    
    ; Load next element
    ld r18, Y+
    ld r19, Y+
    
    ; Compare with current max
    cp r18, r16
    cpc r19, r17
    brlt skip_update
    
    ; Update max if current element is larger
    mov r16, r18
    mov r17, r19
    
skip_update:
    dec r24
    rjmp loop
    
done:
    ; Move result to return registers
    mov r24, r16
    mov r25, r17
    
    ; Restore registers
    pop r17
    pop r16
    pop r29
    pop r28
    ret
