.data
    test: 123

.text
Start:
    lw test
    add %r0 %r2 %r0  # This should not change %r0 — must stay 0
    or  %r0 %r2 %r3  # Move to %r3 to verify
    jmp Halt

Halt:
    jmp Halt
