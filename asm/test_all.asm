        .text
begin:
        ; setup pointer to expected array
        addi      r6, r0, expected      ; r6 points at current expected word
; ---------------------
; Test: sll (logical left)
; ---------------------
        lw      r5, A_sll(r0)       ; value
        lw      r1, A_shamt1(r0)    ; shift amount (2)
        sll     r2, r5, r1
        lw      r3, 0(r6)
        seq     r4, r2, r3
        beqz    r4, error_test_sll
        addi    r6, r6, 4

; srl (logical right)
        lw      r5, A_srl(r0)
        lw      r1, A_shamt1(r0)
        srl     r2, r5, r1
        lw      r3, 0(r6)
        seq     r4, r2, r3
        beqz    r4, error_test_srl
        addi    r6, r6, 4

; sra (arithmetic right)
        lw      r5, A_sra(r0)
        lw      r1, A_shamt1(r0)
        sra     r2, r5, r1
        lw      r3, 0(r6)
        seq     r4, r2, r3
        beqz    r4, error_test_sra
        addi    r6, r6, 4

; slli (immediate logical left) test edge 0xFFFF sign-extend for imm
        lw      r5, A_sll(r0)
        slli    r2, r5, 0x0003    ; small imm
        lw      r3, 0(r6)
        seq     r4, r2, r3
        beqz    r4, error_test_slli
        addi    r6, r6, 4

        slli    r2, r5, 0xFFFF    ; imm=0xFFFF -> test handling (mod by width or sign?) 
        lw      r3, 0(r6)
        seq     r4, r2, r3
        beqz    r4, error_test_slli_immF
        addi    r6, r6, 4

; srli immediate tests
        lw      r5, A_srl(r0)
        srli    r2, r5, 2
        lw      r3, 0(r6)
        seq     r4, r2, r3
        beqz    r4, error_test_srli
        addi    r6, r6, 4

        srli    r2, r5, 0xFFFF
        lw      r3, 0(r6)
        seq     r4, r2, r3
        beqz    r4, error_test_srli_immF
        addi    r6, r6, 4

; srai immediate
        lw      r5, A_sra(r0)
        srai    r2, r5, 1
        lw      r3, 0(r6)
        seq     r4, r2, r3
        beqz    r4, error_test_srai
        addi    r6, r6, 4

; ---------------------
; Arithmetic: add, sub, addu, subu, addi, subi, addui, subui
; ---------------------
        lw      r10, A_add1(r0)
        lw      r11, A_add2(r0)
        add     r12, r10, r11
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_add
        addi    r6, r6, 4

        lw      r10, A_sub1(r0)
        lw      r11, A_sub2(r0)
        sub     r12, r10, r11
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sub
        addi    r6, r6, 4

        ; addu/subu unsigned variants (test overflow wrap)
        lw      r10, A_max_uint(r0)
        lw      r11, A_one(r0)
        addu    r12, r10, r11
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_addu
        addi    r6, r6, 4

        subu    r12, r11, r10    ; 1 - MAX_UINT -> wraps
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_subu
        addi    r6, r6, 4

        ; addi immediate tests (include 0xFFFF)
        lw      r10, A_addi_base(r0)
        addi    r12, r10, 5
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_addi
        addi    r6, r6, 4

        addi    r12, r10, 0xFFFF
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_addi_immF
        addi    r6, r6, 4

        ; subi / subui / addui
        lw      r10, A_subi_base(r0)
        subi    r12, r10, 3
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_subi
        addi    r6, r6, 4

        subui   r12, r10, 0xFFFF
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_subui
        addi    r6, r6, 4

        addui   r12, r10, 0xFFFF
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_addui
        addi    r6, r6, 4

; ---------------------
; Logical: and, or, xor, andi, ori, xori
; ---------------------
        lw      r10, A_mask1(r0)
        lw      r11, A_mask2(r0)
        and     r12, r10, r11
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_and
        addi    r6, r6, 4

        or      r12, r10, r11
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_or
        addi    r6, r6, 4

        xor     r12, r10, r11
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_xor
        addi    r6, r6, 4

        andi    r12, r10, 0xFFFF
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_andi
        addi    r6, r6, 4

        ori     r12, r10, 0x1234
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_ori
        addi    r6, r6, 4

        xori    r12, r10, 0xFFFF
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_xori
        addi    r6, r6, 4

; ---------------------
; Comparisons (seq, sne, seqi, snei etc.)
; Need at least two tests per comparison (result 0 and 1)
; ---------------------

        ; seq tests
        lw      r10, C_seq_a(r0)
        lw      r11, C_seq_a(r0)
        seq     r12, r10, r11    ; should be 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_seq_p1
        addi    r6, r6, 4

        lw      r11, C_seq_b(r0)
        seq     r12, r10, r11    ; should be 0
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_seq_p0
        addi    r6, r6, 4

        ; seqi immediate tests (use 0xFFFF)
        lw      r10, C_seqi_base(r0)
        seqi    r12, r10, 5      ; expect 0
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_seqi_0
        addi    r6, r6, 4

        addui   r10, r0, 0xFFFF  ; is not sign extended
        seqi    r12, r10, 0xFFFF ; 0xFFFFFFFF != 0x0000FFFF
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_seqi_immF
        addi    r6, r6, 4

        ; sne tests
        lw      r10, C_sne_a(r0)
        lw      r11, C_sne_b(r0)
        sne     r12, r10, r11    ; expect 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sne_p1
        addi    r6, r6, 4

        lw      r11, C_sne_a(r0)
        sne     r12, r10, r11    ; expect 0
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sne_p0
        addi    r6, r6, 4

        ; snei
        lw      r10, C_snei_base(r0)
        snei    r12, r10, 0xFFFF
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_snei
        addi    r6, r6, 4

; ---------------------
; Relational signed: slt, sgt, sle, sge, slti, sgti, slei, sgei
; Each tested both 0 and 1
; ---------------------
        lw      r10, R_slt_neg5(r0)
        lw      r11, R_slt_pos3(r0)
        slt     r12, r10, r11    ; -5 < 3 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_slt_p1
        addi    r6, r6, 4

        slt     r12, r11, r10    ; 3 < -5 -> 0
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_slt_p0
        addi    r6, r6, 4

        ; slti immediate
        lw      r10, R_slti_base(r0)
        slti    r12, r10, 10     ; 2 < 10 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_slti
        addi    r6, r6, 4

        slti    r12, r10, 0xFFFF ; 2 < -1 -> 0
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_slti_immF
        addi    r6, r6, 4

        ; sgt / sgti
        lw      r11, R_slt_pos3(r0)
        lw      r10, R_slt_neg5(r0)
        sgt     r12, r11, r10    ; 3 > -5 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sgt_p1
        addi    r6, r6, 4

        sgt     r12, r10, r11    ; -5 > 3 -> 0
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sgt_p0
        addi    r6, r6, 4

        sgti    r12, r11, 1      ; 3 > 1 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sgti
        addi    r6, r6, 4

        ; sle / sge / slei / sgei
        sle     r12, r10, r11    ; -5 <= 3 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sle_p1
        addi    r6, r6, 4

        sge     r12, r11, r11    ; 3 >= 3 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sge_p1
        addi    r6, r6, 4

        slei    r12, r10, 0xFFFF ; -5 <= -1 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_slei
        addi    r6, r6, 4

        sgei    r12, r11, 3      ; 3 >= 3 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sgei
        addi    r6, r6, 4

; ---------------------
; Unsigned relational: sltu, sgeu, sleu, sgtu, sltui, sgtui, sleui, sgeui
; ---------------------
        lw      r10, U_big(r0)     ; big unsigned near MAX_UINT
        lw      r11, U_small(r0)
        sltu    r12, r10, r11    ; should be 0 (big < small false)
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sltu_p0
        addi    r6, r6, 4

        sgtu    r12, r10, r11    ; big > small unsigned -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sgtu_p1
        addi    r6, r6, 4

        sltui   r12, r11, 0xFFFF  ; 2 < 65535 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sltui
        addi    r6, r6, 4

        sgtui   r12, r10, 0x0001  ; big > 1 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sgtui
        addi    r6, r6, 4

        sleu    r12, r11, r10     ; small <= big -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sleu
        addi    r6, r6, 4

        sgeu    r12, r10, r11     ; big >= small -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sgeu
        addi    r6, r6, 4

        sleui   r12, r11, 0xFFFF   ; 2 <= 65535 -> 1
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sleui
        addi    r6, r6, 4

        sgeui   r12, r11, 0xFFFF   ; 2 >= 65535 -> 0
        lw      r3, 0(r6)
        seq     r4, r12, r3
        beqz    r4, error_test_sgeui
        addi    r6, r6, 4

; ---------------------
; Misc arithmetic variants tested earlier: (addu, subu done)
; ---------------------

; ---------------------
; Memory / pointer tests: (lw/sw assumed working) - not required to test
; ---------------------

; ---------------------
; Branches and jumps: use to reach success or errors
; ---------------------
success:
        j       success
        nop ; nop to force the creation of a different label

; ---------------------
; Error labels - one per test (jump to self infinite loop)
; ---------------------
error_test_sll:
        j error_test_sll
        nop
error_test_slli:
        j error_test_slli
        nop
error_test_slli_immF:
        j error_test_slli_immF
        nop
error_test_srl:
        j error_test_srl
        nop
error_test_srli:
        j error_test_srli
        nop
error_test_srli_immF:
        j error_test_srli_immF
        nop
error_test_sra:
        j error_test_sra
        nop
error_test_srai:
        j error_test_srai
        nop
error_test_add:
        j error_test_add
        nop
error_test_sub:
        j error_test_sub
        nop
error_test_addu:
        j error_test_addu
        nop
error_test_subu:
        j error_test_subu
        nop
error_test_addi:
        j error_test_addi
        nop
error_test_addi_immF:
        j error_test_addi_immF
        nop
error_test_subi:
        j error_test_subi
        nop
error_test_addui:
        j error_test_addui
        nop
error_test_subui:
        j error_test_subui
        nop

error_test_and:
        j error_test_and
        nop
error_test_or:
        j error_test_or
        nop
error_test_xor:
        j error_test_xor
        nop
error_test_andi:
        j error_test_andi
        nop
error_test_ori:
        j error_test_ori
        nop
error_test_xori:
        j error_test_xori
        nop

error_test_seq_p1:
        j error_test_seq_p1
        nop
error_test_seq_p0:
        j error_test_seq_p0
        nop
error_test_seqi_0:
        j error_test_seqi_0
        nop
error_test_seqi_immF:
        j error_test_seqi_immF
        nop
error_test_sne_p1:
        j error_test_sne_p1
        nop
error_test_sne_p0:
        j error_test_sne_p0
        nop
error_test_snei:
        j error_test_snei
        nop

error_test_slt_p1:
        j error_test_slt_p1
        nop
error_test_slt_p0:
        j error_test_slt_p0
        nop
error_test_slti:
        j error_test_slti
        nop
error_test_slti_immF:
        j error_test_slti_immF
        nop
error_test_sgt_p1:
        j error_test_sgt_p1
        nop
error_test_sgt_p0:
        j error_test_sgt_p0
        nop
error_test_sgti:
        j error_test_sgti
        nop
error_test_sle_p1:
        j error_test_sle_p1
        nop
error_test_sge_p1:
        j error_test_sge_p1
        nop
error_test_slei:
        j error_test_slei
        nop
error_test_sgei:
        j error_test_sgei
        nop

error_test_sltu_p0:
        j error_test_sltu_p0
        nop
error_test_sgtu_p1:
        j error_test_sgtu_p1
        nop
error_test_sltui:
        j error_test_sltui
        nop
error_test_sgtui:
        j error_test_sgtui
        nop
error_test_sleu:
        j error_test_sleu
        nop
error_test_sgeu:
        j error_test_sgeu
        nop
error_test_sleui:
        j error_test_sleui
        nop
error_test_sgeui:
        j error_test_sgeui
        nop

; ---------------------
; Data section: operands and expected results in exact order used above
; ---------------------
        .data
        .space 1484

; Operand data (organize by labels referenced above)
A_sll:
        .word 0x00000011
A_srl:
        .word 0x80000000
A_sra:
        .word 0x80000000
A_shamt1:
        .word 2

A_add1:
        .word 5
A_add2:
        .word 7

A_sub1:
        .word 10
A_sub2:
        .word 3

A_max_uint:
        .word 0xFFFFFFFF
A_one:
        .word 1

A_addi_base:
        .word 100
A_subi_base:
        .word 50

A_mask1:
        .word 0x0F0F0F0F
A_mask2:
        .word 0x00FF00FF

C_seq_a:
        .word 42
C_seq_b:
        .word 43
C_seqi_base:
        .word 0xFFFF0005
C_snei_base:
        .word 0x1

C_sne_a:
        .word 9
C_sne_b:
        .word 10

R_slt_neg5:
        .word -5
R_slt_pos3:
        .word 3
R_slti_base:
        .word 2

U_big:
        .word 0xFFFFFFFE
U_small:
        .word 2

A_mask3:
        .word 0x12345678

; Other small operands
A_sll_extra:
        .word 0x00000001

; Expected results in the same order as tests above
expected:
; sll
        .word 0x00000044            ; 0x11 << 2 = 0x44
; srl
        .word 0x20000000            ; 0x80000000 >> 2 logical = 0x20000000
; sra
        .word 0xE0000000            ; arithmetic right shift preserving sign (0x80000000 >> 2 = 0xE0000000)
; slli (small)
        .word 0x00000088
; slli immF
        .word 0x80000000
; srli
        .word 0x20000000
; srli immF
        .word 0x00000001
; srai
        .word 0xC0000000            ; arithmetic >>1 for 0x80000000 -> 0xC0000000

; slli tests consumed 8 expected entries above; continue with arithmetic
; add
        .word 12                    ; 5 + 7
; sub
        .word 7                     ; 10 - 3
; addu (wrap)
        .word 0x00000000            ; 0xFFFFFFFF + 1 = 0 (wrap)
; subu
        .word 2                     ; 1 - 0xFFFFFFFF (unsigned wrap) -> 2 (depends on semantics)
; addi
        .word 105
; addi immF
        .word 0x00000063
; subi
        .word 47
; subui
        .word 0xFFFF0033
; addui
        .word 0x00010031

; and
        .word 0x000F000F
; or
        .word 0x0FFF0FFF
; xor
        .word 0x0FF00FF0
; andi
        .word 0x00000F0F
; ori
        .word 0x0F0F1F3F
; xori
        .word 0x0F0FF0F0

; seq (1)
        .word 1
; seq (0)
        .word 0
; seqi 0
        .word 0
; seqi immF
        .word 0

; sne (1)
        .word 1
; sne (0)
        .word 0
; snei
        .word 1

; slt (1)
        .word 1
; slt (0)
        .word 0
; slti
        .word 1
; slti immF
        .word 0

; sgt (1)
        .word 1
; sgt (0)
        .word 0
; sgti
        .word 1

; sle (1)
        .word 1
; sge (1)
        .word 1
; slei
        .word 1
; sgei
        .word 1

; sltu (0)
        .word 0
; sgtu (1)
        .word 1
; sltui
        .word 1
; sgtui
        .word 1
; sleu
        .word 1
; sgeu
        .word 1
; sleui
        .word 1
; sgeui
        .word 0

; End of expected array
