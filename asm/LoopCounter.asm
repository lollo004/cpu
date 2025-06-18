.data
    count: 3

.text
Start:
    lw count
    add %r0 %r2 %r5  # %r5 = loop counter
    and %r0 %r0 %r6  # %r6 = loop accumulator (sum)

Loop:
    add %r6 %r1 %r6  # Add 1 each time
    sub %r5 %r1 %r5  # Decrement counter
    beq End
    jmp Loop

End:
    jmp Halt

Halt:
    jmp Halt
