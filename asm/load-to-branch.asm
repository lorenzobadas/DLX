        .text
begin:
        lw    r1, one(r0)
        bnez  r1, begin
endless:
        j     endless

        .data
.space  100
one:    
        .word 1