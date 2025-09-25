main:
addi r4, r0, 10
slli r7,r4,2
j fibonacci
extloop:
addi r4,r4,1
slli r7,r4,2
fibonacci:
addi r5,r0,1
addi r1,r0,1
addi r2,r0,1
slt r6,r5,r4
beqz r6,end
loop:
add r3, r1, r2
addi r5,r5,1
add r1,r2,r0
add r2,r3,r0
slt r6,r5,r4
bnez r6,loop
end:
sw 0(r7),r2
j extloop