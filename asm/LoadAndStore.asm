.data
    x: 42
    y: 0

.text
Start:
    lw x             # Load value of 'x' into %r2
    sw y             # Store value from %r2 into 'y'
    lw y             # Load back into %r2
    add %r0 %r2 %r3  # Copy to %r3 to verify
    jmp Halt

Halt:
    jmp Halt