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

.macro check_win_state()
	li $t0, 0 # row iterator
	li $s7, 3 # game board size
	li $s4, 4
	li $v0, 0
	outer_loop:
	beq $t0, 2, end
	li $t1, 0 # column iterator
	inner_loop:
	beq $t1, 2 inner_loop_end
	
	# calculate current cell address
	mul $t2, $s7, $t0
	add $t2, $t2, $t1
	mul $t2, $t2, $s4
	
	# calculate cell horizontally adjacent address
	mul $t3, $s7, $t0
	add $t3, $t3, $t1
	addi $t3, $t3, 1
	mul $t3, $t3, $s4
	
	# calculate cell with vertically adjacent address
	addi $t4, $t0, 1
	mul $t4, $s7, $t4
	add $t4, $t4, $t1
	mul $t4, $t4, $s4

	# get cell values
	get_cell_value($t2, $t2)
	get_cell_value($t3, $t3)
	get_cell_value($t4, $t4)
	
	# conditionals
	beq $t2, $t3, return_2
	beq $t2, $t4, return_2
	beq $t2, 0, return_2
	loop_return:
	beq $t2, 512, return_1
	addi $t1, $t1, 1
	j inner_loop
	inner_loop_end:
	addi $t0, $t0, 1
	j outer_loop 
		
	return_1:
	li $v0, 1
	j end
	return_2:
	li $v0, 2
	j loop_return
	end:
.end_macro
	
.macro move_up()
	li $t0, 0 # row iterator
	li $s7, 3 # game board size
	li $s4, 4
	li $v0, 0
	outer_loop_1:
	beq $t0, 3, end
	li $t1, 1 # column iterator
	li $t2, 0
	outer_loop_2:
	beq $t1, 3, end_outer_loop_2
	addi $t3, $t1, 0 # checker iterator
	inner_loop:
	beq $t3, 0, end_inner
	# compute for previous cell address
	addi $t3, $t3, -1
	mul $t4, $s7, $t3
	addi $t3, $t3, 1
	add $t4, $t4, $t0 # t4 stores previous cell value
	mul $t4, $t4, $s4 # get address offset
	get_cell_value($t4, $t6) # previous cell value
	# compute for current cell address
	mul $t5, $s7, $t3
	add $t5, $t5, $t0 # t5 stores current cell value
	mul $t5, $t5, $s4 # get address offset
	get_cell_value($t5, $t7) # current cell value
	beq $t6, 0, move_only
	beq $t6, $t7, check_l
	j fail_conditional
	check_l:
	beq $t2, 1, fail_conditional
	li $v0, 1
	add $t6, $t6, $t7 # board[k-1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	addi $t2, $t2, 1
	j fail_conditional
	move_only:
	add $t6, $t6, $t7 # board[k-1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	fail_conditional:
	addi $t3, $t3, -1
	j inner_loop
	end_inner:
	addi $t1, $t1, 1
	j outer_loop_2		
	end_outer_loop_2:
	addi $t0, $t0, 1	
	j outer_loop_1											
	end:				
.end_macro
	
.macro move_down()
	li $t0, 0 # row iterator
	li $s7, 3 # game board size
	li $s4, 4
	li $v0, 0
	outer_loop_1:
	beq $t0, 3, end
	li $t1, 1 # column iterator
	li $t2, 0
	outer_loop_2:
	beq $t1, -1, end_outer_loop_2
	addi $t3, $t1, 0 # checker iterator

	inner_loop:
	beq $t3, 2, end_inner
	# compute for previous cell address
	addi $t3, $t3, 1
	mul $t4, $s7, $t3
	addi $t3, $t3, -1
	add $t4, $t4, $t0 # t4 stores next cell value
	mul $t4, $t4, $s4 # get address offset
	get_cell_value($t4, $t6) # next cell value
	# compute for current cell address
	mul $t5, $s7, $t3
	add $t5, $t5, $t0 # t5 stores current cell value
	mul $t5, $t5, $s4 # get address offset
	get_cell_value($t5, $t7) # current cell value
	beq $t6, 0, move_only
	beq $t6, $t7, check_l
	j fail_conditional
	check_l:
	beq $t2, 1, fail_conditional
	switching:
	li $v0, 1
	add $t6, $t6, $t7 # board[k+1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	addi $t2, $t2, 1
	j fail_conditional
	move_only:
	li $v0, 1
	add $t6, $t6, $t7 # board[k+1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	fail_conditional:
	addi $t3, $t3, 1
	j inner_loop
	end_inner:
	addi $t1, $t1, -1
	j outer_loop_2		
	end_outer_loop_2:
	addi $t0, $t0, 1	
	j outer_loop_1											
	end:				
.end_macro

.macro move_left()
	li $t0, 0 # row iterator
	li $s7, 3 # game board size
	li $s4, 4
	li $v0, 0
	outer_loop_1:
	beq $t0, 3, end
	li $t1, 1 # column iterator
	li $t2, 0
	outer_loop_2:
	beq $t1, 3, end_outer_loop_2
	addi $t3, $t1, 0 # checker iterator

	inner_loop:
	beq $t3, 0, end_inner
	# compute for previous cell address
	addi $t3, $t3, -1
	mul $t4, $s7, $t0
	add $t4, $t4, $t3 # t4 stores previous cell value
	addi $t3, $t3, 1
	mul $t4, $t4, $s4 # get address offset
	get_cell_value($t4, $t6) # previous cell value
	# compute for current cell address
	mul $t5, $s7, $t0
	add $t5, $t5, $t3 # t5 stores current cell value
	mul $t5, $t5, $s4 # get address offset
	get_cell_value($t5, $t7) # current cell value
	beq $t6, 0, move_only
	beq $t6, $t7, check_l
	j fail_conditional
	check_l:
	beq $t2, 1, fail_conditional
	switching:
	li $v0, 1
	add $t6, $t6, $t7 # board[k-1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	addi $t2, $t2, 1
	j fail_conditional
	move_only:
	li $v0, 1
	add $t6, $t6, $t7 # board[k-1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	fail_conditional:
	addi $t3, $t3, -1
	j inner_loop
	end_inner:
	addi $t1, $t1, 1
	j outer_loop_2		
	end_outer_loop_2:
	addi $t0, $t0, 1	
	j outer_loop_1											
	end:				
.end_macro

.macro move_right()
	li $t0, 0 # row iterator
	li $s7, 3 # game board size
	li $s4, 4
	li $v0, 0
	outer_loop_1:
	beq $t0, 3, end
	li $t1, 1 # column iterator
	li $t2, 0
	outer_loop_2:
	
	beq $t1, -1, end_outer_loop_2
	addi $t3, $t1, 0 # checker iterator
	inner_loop:
	beq $t3, 2, end_inner
	# compute for previous cell address
	addi $t3, $t3, 1
	mul $t4, $s7, $t0
	add $t4, $t4, $t3 # t4 stores next cell value
	addi $t3, $t3, -1
	mul $t4, $t4, $s4 # get address offset
	get_cell_value($t4, $t6) # next cell value
	# compute for current cell address
	mul $t5, $s7, $t0
	add $t5, $t5, $t3 # t5 stores current cell value
	mul $t5, $t5, $s4 # get address offset
	get_cell_value($t5, $t7) # current cell value
	beq $t6, 0, move_only
	beq $t6, $t7, check_l
	j fail_conditional
	check_l:
	beq $t2, 1, fail_conditional
	switching:
	li $v0, 1
	add $t6, $t6, $t7 # board[k+1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	addi $t2, $t2, 1
	j fail_conditional
	move_only:
	li $v0, 1
	add $t6, $t6, $t7 # board[k+1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	fail_conditional:
	addi $t3, $t3, 1
	j inner_loop
	end_inner:
	addi $t1, $t1, -1
	j outer_loop_2		
	end_outer_loop_2:
	addi $t0, $t0, 1	
	j outer_loop_1											
	end:				
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
	
	
	
.macro check_if_board_is_full()
	li $t0, 0
	li $t4, 0
	li $v0, 1
	li $t5, 8
	loop:
		addi $t0, $t4, 0
		addi	$t1, $0, 4	# set t0 to 4 for multiplication
		mul	$t0, $t4, $t1	# multiply offset by 4, store in $t0
		get_cell_value($t0, $t3)
		beq $t3, $0, zero_found
		addi $t4, $t4, 1
	blt $t4, $t5, loop
	li $v0, 0
	b end
	
	zero_found:
		li $v0, 0
	end:
	
.end_macro

.macro ask_for_move()
	li	$s4, 4		# sets s4 to the constant 4
start_ask_for_move:
	li $v0, 4            # System call for print_string
	la $a0, movement_prompt       # Load address of prompt string
	syscall
	
	li $v0, 12
	syscall
	
	move	$t0, $v0
	
	li	$t1, 87		# ASCII FOR W
	subu	$t2, $t1, $t0	# is INPUT equal to W?
	beq	$t2, $0, w_input
	
	li	$t1, 65		# ASCII FOR A
	subu	$t2, $t1, $t0	# is INPUT equal to A?
	beq	$t2, $0, a_input
	
	li	$t1, 83		# ASCII FOR S
	subu	$t2, $t1, $t0	# is INPUT equal to S?
	beq	$t2, $0, s_input
	
	li	$t1, 68		# ASCII FOR D
	subu	$t2, $t1, $t0	# is INPUT equal to D?
	beq	$t2, $0, d_input
	
	li	$t1, 88		# ASCII FOR X
	subu	$t2, $t1, $t0	# is INPUT equal to X?
	beq	$t2, $0, x_input
	
	li	$t1, 51		# ASCII FOR 3
	subu	$t2, $t1, $t0	# is INPUT equal to 3?
	beq	$t2, $0, disable_random
	
	li	$t1, 52		# ASCII FOR 4
	subu	$t2, $t1, $t0	# is INPUT equal to 4?
	beq	$t2, $0, enable_random
	
	b start_ask_for_move
	
w_input:
	move_up()
	reset_registers()
	b end_movement
	
a_input:
	move_left()
	reset_registers()
	b end_movement
	
s_input:
	move_down()
	reset_registers()
	b end_movement
	
d_input:
	move_right()
	reset_registers()
	b end_movement
	
x_input:
	li $v0, 10
	syscall
	
enable_random:
	reset_registers()
	print_grid()
	b main_game_loop_random
	
disable_random:
	reset_registers()
	print_grid()
	b main_game_loop_no_random
	
end_movement:
	
.end_macro


.text
main:
	jal start_game
	jal main_game_loop_random
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
	j init_cg_loop_random
	
custom_game_loop_start:
	addi	$t0, $0, 0	# loop initial value
	addi	$t1, $0, 9	# loop guard
	addi	$t2, $0, 4	# for multiplication
	
	li	$v0, 9		# sbrk
	li	$a0, 36		# need 9 cells, 9*4 = 36
	syscall
	move	$s0, $v0
	
custom_game_loop:
	beq	$t0, $t1, after_add	# exit loop
	get_int_input($t3)	# get value to set cell
	mul	$t5, $t2, $t0	# get proper offset for set_cell_value
	set_cell_value($t5, $t3)	# set the cell with offset t5 to value in t3
	addi	$t0, $t0, 1	# i = i + 1
	b	custom_game_loop

add_random_two_cg:
	add_random_two_to_board()
	j after_add  
			
init_cg_loop_random:
	add_random_two_to_board()
	j after_add


cg_loop:
	check_if_board_is_full()
	beq $v0, 0, add_random_two_cg              # placeholder for conditional to allow new random two
after_add:
	check_win_state()
	beq $v0, 1, win
	beq $v0, 0, lose

	print_grid()
	# move_down()
	print_num($v0)
	print_grid()
	reset_registers()
	jr $ra

main_game_loop_random:
	subu	$sp, $sp, 4
	sw	$ra, ($sp)
	ask_for_move()
	add_random_two_to_board()
	print_grid()
	check_win_state()
	
	b main_game_loop_random
	
main_game_loop_no_random:
	ask_for_move()
	print_grid()
	check_win_state()
	
	b main_game_loop_no_random
	
win:
	print_grid()
	print_str_input(win_msg)
	j end_program

lose:
	print_grid()
        print_str_input(lose_msg)
	j end_program

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
movement_prompt: .asciiz "\nEnter a move\n"
win_msg: .asciiz "\nCongratulations! You have reached the 512 tile!\n"
lose_msg: .asciiz "\nGame over.\n"
test: .asciiz "\ntest\n"
3_msg: .asciiz "\nNew tile generation disabled.\n"
4_msg: .asciiz "\nNew tile generation enabled.\n"
