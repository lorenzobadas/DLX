main:
addi r4, r0, 10
nop
nop
nop
slli r7,r4,2
j fibonacci
nop
nop
nop

extloop:
addi r4,r4,1
nop
nop
nop
slli r7,r4,2

fibonacci:
addi r5,r0,1
addi r1,r0,1
addi r2,r0,1
nop
slt r6,r5,r4
nop
nop
nop
beqz r6,end
nop
nop
nop
loop:
add r3, r1, r2
addi r5,r5,1
add r1,r2,r0
nop
add r2,r3,r0
slt r6,r5,r4
nop
nop
nop
bnez r6,loop
nop
nop
nop
end:
sw 0(r7),r2
j extloop
nop
nop
nop