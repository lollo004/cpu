.data
    iter: 4

.text
Start:
    lw iter
    add %r0 %r2 %r3  # %r3 = counter
    and %r0 %r0 %r4  # Accumulator

Loop:
    add %r4 %r1 %r4  # Add 1
    sub %r3 %r1 %r3  # Decrement
    beq End
    jmp Loop

End:
    jmp Halt

Halt:
    jmp Halt
