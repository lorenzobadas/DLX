        .text
begin:
        addi    r2,r0,1024
        addi    r2,r2,-32
        sw      28(r2),r31
        sw      24(r2),r8
        addi    r8,r2,32
        addi    r15,r0,10
        sw      -20(r8),r15
        lw      r10,-20(r8)
        jal     factorial
        sw      fact(r0),r10
        addi    r15,r0,0
        add     r10,r0,r15
        lw      r31,28(r2)
        lw      r8,24(r2)
        addi    r2,r2,32
        
endloop:
        j       endloop


mult_func:
        addi    r2,r2,-48
        sw      44(r2),r31
        sw      40(r2),r8
        addi    r8,r2,48
        sw      -36(r8),r10
        sw      -40(r8),r11
        sw      -20(r8),r0
        sw      -24(r8),r0
        j       L2
L3:
        lw      r14,-20(r8)
        lw      r15,-36(r8)
        add     r15,r14,r15
        sw      -20(r8),r15
        lw      r15,-24(r8)
        addi    r15,r15,1
        sw      -24(r8),r15
L2:
        lw      r14,-24(r8)
        lw      r15,-40(r8)
        slt     r12,r14,r15
        bnez    r12,L3
        lw      r15,-20(r8)
        add     r10,r0,r15
        lw      r31,44(r2)
        lw      r8,40(r2)
        addi    r2,r2,48
        jr      r31

factorial:
        addi    r2,r2,-48
        sw      44(r2),r31
        sw      40(r2),r8
        addi    r8,r2,48
        sw      -36(r8),r10
        addi    r15,r0,1
        sw      -20(r8),r15
        addi    r15,r0,1
        sw      -24(r8),r15
        j       L6
L7:
        lw      r11,-24(r8)
        lw      r10,-20(r8)
        jal     mult_func
        sw      -20(r8),r10
        lw      r15,-24(r8)
        addi    r15,r15,1
        sw      -24(r8),r15
L6:
        lw      r14,-24(r8)
        lw      r15,-36(r8)
        sle     r12,r14,r15
        bnez    r12,L7
        lw      r15,-20(r8)
        add     r10,r0,r15
        lw      r31,44(r2)
        lw      r8,40(r2)
        addi    r2,r2,48
        jr      r31

        .data
        .space 300
fact:
        .word 0