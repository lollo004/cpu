.data
    val: 9

.text
Start:
    lw val
    add %r0 %r2 %r3
    add %r0 %r2 %r4
    add %r0 %r2 %r5
    add %r0 %r2 %r6
    add %r0 %r2 %r7
    add %r0 %r2 %r8
    add %r0 %r2 %r9
    add %r0 %r2 %r10
    add %r0 %r2 %r11
    add %r0 %r2 %r12
    add %r0 %r2 %r13
    add %r0 %r2 %r14
    add %r0 %r2 %r15
    jmp Halt

Halt:
    jmp Halt