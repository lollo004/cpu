.data

    n: 20
    i: 2
    

.text
Start:
    lw n
    add %r0 %r2 %r3
    lw i
    add %r0 %r2 %r5
    and %r0 %r0 %r4
    
Loop:
    add %r4 %r5 %r4
    sub %r3 %r4 %r6
    beq Halt
    jmp Loop

Halt:
    jmp Halt
