# Bitmap display starter code
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.eqv	BASE_ADDRESS	0x10008000
.eqv	SLEEP_TIME	40
.eqv	WIDTH		64
.eqv	SPEED		1
.eqv	V_OF_CHAR	3
.data
Lv:	.byte	1
x:	.word	32
y:	.word	32
index:	.word	0x10008000
score:	.word	0
state:	.word	0

.text
.globl main
main:

on_key_input: 
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened
	jal sleeping
	j on_key_input
keypress_happened:
	lw $t3, 4($t9) # this assumes $t9 is set to 0xfff0000 from before

	jal get_index
	la $t0, index
	lw $t1, 0($t0)
	li $t2, 0x333333
	sw $t2, 0($t1)


	beq $t3, 0x77, respond_to_w # ASCII code of 'w' is 0x77
	beq $t3, 0x61, respond_to_a # ASCII code of 'a' is 0x61
	beq $t3, 0x73, respond_to_s # ASCII code of 's' is 0x73
	beq $t3, 0x64, respond_to_d # ASCII code of 'd' is 0x64
	j on_key_input
respond_to_w:
	la $t0, y
	lw $t1, 0($t0)
	beq $t1, $zero, Render
	addi $t1, $t1, -SPEED
	sw $t1, 0($t0)
	j Render
respond_to_a:
	la $t0, x
	lw $t1, 0($t0)
	beq $t1, $zero, Render
	addi $t1, $t1, -SPEED
	sw $t1, 0($t0)
	j Render
respond_to_s:
	la $t0, y
	lw $t1, 0($t0)
	li $t2, WIDTH
	addi $t2, $t2, -1
	beq $t1, $t2, Render
	addi $t1, $t1, SPEED
	sw $t1, 0($t0)
	j Render
respond_to_d:
	la $t0, x
	lw $t1, 0($t0)
	li $t2, WIDTH
	addi $t2, $t2, -1
	beq $t1, $t2, Render
	addi $t1, $t1, SPEED
	sw $t1, 0($t0)
	
	j Render

Render:
	jal get_index
	la $t0, index
	lw $t1, 0($t0)
	li $t2, 0xffffff
	sw $t2, 0($t1)
	j on_key_input

END:
	li $v0, 10
	syscall
get_index:
	li $t0, WIDTH
	la $t4, x
	lw $t4, 0($t4)
	la $t5, y
	lw $t5, 0($t5)
	li $t6, BASE_ADDRESS
	mult $t5, $t0
	mflo $t0
	add $t0, $t0, $t4
	sll $t0, $t0, 2
	add $t0, $t0, $t6	
	la $t1, index
	sw $t0, 0($t1)
	jr $ra
sleeping:
	li $v0, 32
	li $a0, SLEEP_TIME # Wait one second (1000 milliseconds)
	syscall
	jr $ra
	
