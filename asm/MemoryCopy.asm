.data
    src: 77
    dst: 0

.text
Start:
    lw src
    sw dst
    lw dst
    add %r0 %r2 %r5  # Verify value copied
    jmp Halt

Halt:
    jmp Halt