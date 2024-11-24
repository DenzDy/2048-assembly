# CS 21 WFR/FWX -- S1 AY 2024-2025

# Denzell Robyn Dy and Jose Miguel Lozada - 11/04/2024

# 2048 Program
.macro get_int_input(%dest)
    li $v0, 5 
    syscall
    move %dest, $v0
.end_macro

.macro print_char(%x)
	li $a0, %x
	li $v0, 11
	syscall
.end_macro

.macro get_str_input(%dest, %char_size)
    li $v0, 8 
    la $a0, %dest
    li $a1, %char_size
    syscall
.end_macro

.macro print_str_input(%src)
    li $v0, 4
    la $a0, %src
    syscall
.end_macro

.macro print_grid()
	print_str_input(divider)
	move	$t0, $s0	# get address of first cell, increment at the end of the loop
	
	addi	$t3, $s0, 8	# get cell 2 address
	addi	$t4, $s0, 20	# get cell 5 address
	addi	$t5, $s0, 32	# get cell 8 address (last cell)
	
print_grid_loop:
	print_char(124)		# print bar
	lw	$t1, 0($t0)	# get value of cell to check what to print
	
	beq	$t1, $0, print_cell_0
	addi	$t2, $0, 2	# set t2 to 0, use this to compute for what to compare
	beq	$t1, $t2, print_cell_2
	sll	$t2, $t2, 1	# next value to check
	beq	$t1, $t2, print_cell_4
	sll	$t2, $t2, 1	# next value to check
	beq	$t1, $t2, print_cell_8
	sll	$t2, $t2, 1	# next value to check
	beq	$t1, $t2, print_cell_16
	sll	$t2, $t2, 1	# next value to check
	beq	$t1, $t2, print_cell_32
	sll	$t2, $t2, 1	# next value to check
	beq	$t1, $t2, print_cell_64
	sll	$t2, $t2, 1	# next value to check
	beq	$t1, $t2, print_cell_128
	sll	$t2, $t2, 1	# next value to check
	beq	$t1, $t2, print_cell_256
	sll	$t2, $t2, 1	# next value to check
	beq	$t1, $t2, print_cell_512
	sll	$t2, $t2, 1	# next value to check
	
print_cell_0:
	print_str_input(zero)
	b	next_print_loop
	
print_cell_2:
	print_str_input(two_one)
	b	next_print_loop

print_cell_4:
	print_str_input(two_two)
	b	next_print_loop
	
print_cell_8:
	print_str_input(two_three)
	b	next_print_loop
	
print_cell_16:
	print_str_input(two_four)
	b	next_print_loop

print_cell_32:
	print_str_input(two_five)
	b	next_print_loop
	
print_cell_64:
	print_str_input(two_six)
	b	next_print_loop
	
print_cell_128:
	print_str_input(two_seven)
	b	next_print_loop
	
print_cell_256:
	print_str_input(two_eight)
	b	next_print_loop
	
print_cell_512:
	print_str_input(two_nine)
	b	next_print_loop

next_print_loop:
	beq	$t0, $t3, next_print_loop_2	# after printing cell 2
	beq	$t0, $t4, next_print_loop_2	# after printing cell 5
	beq	$t0, $t5, end_print_loop	# after printing cell 8
	
	addi	$t0, $t0, 4
	b	print_grid_loop
	
next_print_loop_2:
	print_char(124)
	print_str_input(divider)
	addi	$t0, $t0, 4
	b	print_grid_loop

end_print_loop:
	print_char(124)
	print_str_input(divider)
.end_macro

.macro print_num(%x)
	add $a0, %x, $0
	li $v0, 1
	syscall
.end_macro

.macro get_rand(%x)
	li $a1, 1000
	li $v0, 42
	syscall
	div $a0, %x
	mfhi $a0
.end_macro

.macro get_cell_value(%x, %y)   # x: offset, y: return register
	add	%x, %x, $s0	# add offset and base register, store in t0
	lw 	%y, (%x)	# set cell value with offset %x to %y
.end_macro

.macro set_cell_value(%x, %y)	# x: offset, y: value
	add	%x, %x, $s0	# add offset and base register, store in t0
	add	$t8, $0, %y
	sw 	$t8, (%x)	# set cell value with offset %x to %y
	
.end_macro

.macro reset_registers()
	addi	$t0, $0, 0
	addi	$t1, $0, 0
	addi	$t2, $0, 0
	addi	$t3, $0, 0
	addi	$t4, $0, 0
	addi	$t5, $0, 0
	addi	$t6, $0, 0
	addi	$t7, $0, 0
	addi	$t8, $0, 0
	addi	$t9, $0, 0
.end_macro

.macro add_random_two_to_board()
	loop:
		addi	$t0, $0, 9	# for rand modulo
		get_rand($t0)		# generates random position
		addi	$t1, $0, 4	# set t0 to 4 for multiplication
		mul	$t0, $a0, $t1	# multiply offset by 4, store in $t0
		addi	$t2, $0, 2
		addi $t1, $t0, 0        # save current offset to $t1 resgiter for get_cell_value.
		get_cell_value($t1, $t3)
	bne $t3, $0, loop               # checks if randomly picked cell is not empty. Loops if it is not empty
	set_cell_value($t0, $t2)	# set the cell with offset t0 to value in t3
.end_macro
	
	
	
.macro 


.text
main:
	jal start_game
	j end_program
	
start_game:
	
	print_str_input(start_msg)
	get_int_input($t0)
	addi	$t1, $0, 1
	addi	$t2, $0, 2
	beq	$t0, $t1, new_game_loop
	beq	$t0, $t2, custom_game_loop_start
	
new_game_loop:
	addi	$t0, $0, 9	# for rand modulo
	get_rand($t0)		# generates random position
	print_num($a0)		# print random num (0 to 9 for offset)
	
	addi	$t1, $0, 4	# set t0 to 4 for multiplication
	mul	$t0, $a0, $t1	# multiply offset by 4, store in $t0
	li	$v0, 9		# sbrk
	li	$a0, 36		# need 9 cells, 9*4 = 36
	syscall			# sbrk, memory location now in v0
	
	move	$s0, $v0	# stores CELL 0 address in $s0
	addi	$t2, $0, 2
	#set_cell_value($t0, $t2)	# set the cell with offset t0 to value in t3
	#print_grid()
	add_random_two_to_board()
	print_grid()
	add_random_two_to_board()
	print_grid()
	reset_registers()
	jr	$ra
	
custom_game_loop_start:
	addi	$t0, $0, 0	# loop initial value
	addi	$t1, $0, 9	# loop guard
	addi	$t2, $0, 4	# for multiplication
	
	li	$v0, 9		# sbrk
	li	$a0, 36		# need 9 cells, 9*4 = 36
	syscall
	move	$s0, $v0
	
custom_game_loop:
	beq	$t0, $t1, end_custom_game_loop	# exit loop
	get_int_input($t3)	# get value to set cell
	mul	$t5, $t2, $t0	# get proper offset for set_cell_value
	set_cell_value($t5, $t3)	# set the cell with offset t5 to value in t3
	addi	$t0, $t0, 1	# i = i + 1
	b	custom_game_loop
	
end_custom_game_loop:
	print_grid()
	reset_registers()
	jr	$ra
	
cg_loop:
	
	
end_program:
	li $v0, 10
	syscall
    
.data
move_input: .space 2
divider: .asciiz "\n+---+---+---+\n"
cells: .asciiz "|   |   |   |\n"

zero: .asciiz "   "
two_one: .asciiz " 2 "
two_two: .asciiz " 4 "
two_three: .asciiz " 8 "
two_four: .asciiz " 16"
two_five: .asciiz " 32"
two_six: .asciiz " 64"
two_seven: .asciiz "128"
two_eight: .asciiz "256"
two_nine: .asciiz "512"

start_msg: .asciiz "Choose [1] or [2]\n[1] New Game\n[2] Start from a State\n"
