	.text

loop:
addi r1, r0, 4
addi r2, r0, 8
addi r3, r0, 12
addi r4, r0, 16
addi r5, r0, 20
addi r6, r0, 24
addi r7, r0, 28
addi r8, r0, 32
addi r9, r0, 36
addi r10, r0, 40
addi r11, r0, 44
addi r12, r0, 48
addi r13, r0, 52
addi r14, r0, 56
addi r15, r0, 60
addi r16, r0, 64
addi r17, r0, 68
addi r18, r0, 72
addi r19, r0, 76
addi r20, r0, 80
addi r21, r0, 84
addi r22, r0, 88
addi r23, r0, 92
addi r24, r0, 96
addi r25, r0, 100
addi r26, r0, 104
addi r27, r0, 108
addi r28, r0, 112
addi r29, r0, 116
addi r30, r0, 120
addi r31, r0, 124
sb array(r1), r1
sb array(r2), r2
sb array(r3), r3
sw array(r4), r4
sw array(r5), r5
sw array(r6), r6
sw array(r7), r7
sb array(r8), r8
sb array(r9), r9
sb array(r10), r10
sb array(r11), r11
sh array(r12), r12
sh array(r13), r13
sh array(r14), r14
sh array(r15), r15
sw array(r16), r16
sw array(r17), r17
sw array(r18), r18
sw array(r19), r19
sb array(r20), r20
sb array(r21), r21
sb array(r22), r22
sb array(r23), r23
sh array(r24), r24
sh array(r25), r25
sh array(r26), r26
sh array(r27), r27
sw array(r28), r28
sw array(r29), r29
sw array(r30), r30
sw array(r31), r31
lb r1,  array(r1)
lb r2,  array(r2)
lb r3,  array(r3)
lb r4,  array(r4)
lb r5,  array(r5)
lb r6,  array(r6)
lb r7,  array(r7)
lb r8,  array(r8)
lb r9,  array(r9)
lb r10, array(r10)
lb r11, array(r11)
lb r12, array(r12)
lb r13, array(r13)
lb r14, array(r14)
lb r15, array(r15)
lb r16, array(r16)
lb r17, array(r17)
lb r18, array(r18)
lb r19, array(r19)
lb r20, array(r20)
lb r21, array(r21)
lb r22, array(r22)
lb r23, array(r23)
lb r24, array(r24)
lb r25, array(r25)
lb r26, array(r26)
lb r27, array(r27)
lb r31, array(r31)
lb r28, array(r28)
lb r29, array(r29)
lb r30, array(r30)
addi r1,  r0, 0
addi r2,  r0, 0
addi r3,  r0, 0
addi r4,  r0, 0
addi r5,  r0, 0
addi r6,  r0, 0
addi r7,  r0, 0
addi r8,  r0, 0
addi r9,  r0, 0
addi r10, r0, 0
addi r11, r0, 0
addi r12, r0, 0
addi r13, r0, 0
addi r14, r0, 0
addi r15, r0, 0
addi r16, r0, 0
addi r17, r0, 0
addi r18, r0, 0
addi r19, r0, 0
addi r20, r0, 0
addi r21, r0, 0
addi r22, r0, 0
addi r23, r0, 0
addi r24, r0, 0
addi r25, r0, 0
addi r26, r0, 0
addi r27, r0, 0
addi r28, r0, 0
addi r29, r0, 0
addi r30, r0, 0
addi r31, r0, 0
j loop
nop
nop
nop
nop
nop
nop

  .data
code_space:
  .space 528
array:
  .space 128
