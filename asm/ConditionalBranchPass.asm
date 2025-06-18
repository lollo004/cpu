.data
    val1: 5
    val2: 5

.text
Start:
    lw val1
    add %r0 %r2 %r4
    lw val2
    sub %r4 %r2 %r6  # Should be zero
    beq Success
    jmp Fail

Success:
    add %r0 %r1 %r7  # Success: %r7 = 1
    jmp Halt

Fail:
    and %r0 %r0 %r7  # Fail: %r7 = 0

Halt:
    jmp Halt