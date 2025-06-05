.data
    pi: 3
    a: 1
    b: 16
.text

LabelA:
    add %r1 %r1 %r1
    sub %r1 %r9 %r1
    and %r3 %r5 %r14
    or %r1 %r1 %r10
    jmp LabelA

LabelB:
    add %r1 %r1 %r1
    sub %r1 %r9 %r1
    and %r3 %r5 %r14
    or %r1 %r1 %r10
    jmp LabelB

