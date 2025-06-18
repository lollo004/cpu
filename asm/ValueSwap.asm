.data
    m: 4
    n: 9

.text
Start:
    lw m
    add %r0 %r2 %r4  # %r4 = m
    lw n
    add %r0 %r2 %r5  # %r5 = n

    add %r4 %r5 %r6  # temp = m + n
    sub %r6 %r5 %r4  # new m = temp - n
    sub %r6 %r4 %r5  # new n = temp - new m

    jmp Halt

Halt:
    jmp Halt