.data
    val1: 8
    val2: 3

.text
Start:
    lw val1
    add %r0 %r2 %r4
    lw val2
    sub %r4 %r2 %r6  # Not zero
    beq Fail         # Should not branch here
    jmp Success

Fail:
    and %r0 %r0 %r7

Success:
    add %r0 %r1 %r7
    jmp Halt

Halt:
    jmp Halt
