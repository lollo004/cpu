.data
    a: 10
    b: 3

.text
Start:
    lw a
    add %r0 %r2 %r4  # %r4 = a
    lw b
    add %r4 %r2 %r5  # %r5 = a + b
    sub %r4 %r2 %r6  # %r6 = a - b
    and %r4 %r2 %r7  # %r7 = a & b
    or  %r4 %r2 %r8  # %r8 = a | b
    jmp Halt

Halt:
    jmp Halt
