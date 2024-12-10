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
	beq $t0, 3, end
	li $t1, 0 # column iterator
	inner_loop:
	beq $t1, 3, inner_loop_end
	
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
	beq $t1, 2, skip_horizontal
	beq $t2, $t3, return_2
	skip_horizontal:
	beq $t0, 2, skip_vertical
	beq $t2, $t4, return_2
	skip_vertical:
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
	li $s4, 4 # 4 for address multiplier
	li $v0, 0 # 
	outer_loop_1:
	beq $t0, 3, end # conditional for outer loop (row iteration)
	li $t1, 1 # column iterator
	li $t2, 0 # counter for amount of switches per column
	outer_loop_2:
	beq $t1, 3, end_outer_loop_2 # conditional for outer loop (column iteration)
	addi $t3, $t1, 0 # checker iterator (starts from middle row, goes up to bottom row)
	inner_loop:
	beq $t3, 0, end_inner # conditional for inner loop (adjacent (above current) cell checker)
	# compute for previous cell address
	addi $t3, $t3, -1 # decrease current cell in column to get previous cell (above current)
	mul $t4, $s7, $t3 # converting indexes to offset (row index * board size + column index)
	addi $t3, $t3, 1 # revert decrease for future computations of current cell
	add $t4, $t4, $t0 # t4 stores previous cell value
	mul $t4, $t4, $s4 # get address offset of previous cell value
	get_cell_value($t4, $t6) # get previous cell value
	# compute for current cell address
	mul $t5, $s7, $t3 # converting indexes to offset (row index * board size + column index)
	add $t5, $t5, $t0 # t5 stores current cell value
	mul $t5, $t5, $s4 # get address offset
	get_cell_value($t5, $t7) # get current cell value
	beq $t6, 0, move_only # checks if previous cell (above) is zero
	beq $t6, $t7, check_l # check if previous cell (above) is fusable
	j fail_conditional # jump to end of loop if conditions fail (implies no merge or move available)
	check_l: 
	beq $t7, 0, fail_conditional
	beq $t2, 1, fail_conditional # stops fusing of tiles if number of fuses is already 1
	li $v0, 1 # indicator that movement occurred (for movement input that does nothing)
	add $t6, $t6, $t7 # adds cell above and current cell, puts sum in cell above
	li $t7, 0 # sets current cell to 0
	sw $t6, 0($t4) # store new value to cell above current
	sw $t7, 0($t5) # store new value to current cell
	addi $t2, $t2, 1 # iterate fuse counter by 1 
	j fail_conditional
	move_only:
	beq $t7, 0, fail_conditional
	li $v0, 1 # indicator that movement occurred (for movement input that does nothing)
	add $t6, $t6, $t7 # board[k-1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	fail_conditional:
	addi $t3, $t3, -1 # decreasee inner loop conditional by 1
	j inner_loop # return to inner_loop label
	end_inner: # end of inner loop
	addi $t1, $t1, 1 # add column iterator by 1
	j outer_loop_2	# return to outer_loop_2 label	
	end_outer_loop_2: # end of outer loop 2
	addi $t0, $t0, 1 # add row iterator by 1
	j outer_loop_1	# return to outer_loop_1 label							
	end: # end of algorithm
.end_macro
	
.macro move_down()
	li $t0, 0 # row iterator
	li $s7, 3 # game board size
	li $s4, 4 #
	li $v0, 0
	outer_loop_1:
	beq $t0, 3, end
	li $t1, 1 # column iterator
	li $t2, 0 # counter for amount of switches per column
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
	beq $t7, 0, fail_conditional
	beq $t2, 1, fail_conditional
	switching:
	beq $t7, 0, fail_conditional
	li $v0, 1
	add $t6, $t6, $t7 # board[k+1][i] += board[k][i]
	li $t7, 0 # board[k][i] = 0
	sw $t6, 0($t4) # store to cell
	sw $t7, 0($t5) # store to cell
	addi $t2, $t2, 1
	j fail_conditional
	move_only:
	beq $t7, 0, fail_conditional
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
	li $s4, 4 # 4 for address offset multiplier
	li $v0, 0 # return value for movement/fuse indicator
	outer_loop_1: # row iterator loop
	beq $t0, 3, end # row iterator condition
	li $t1, 1 # column iterator
	li $t2, 0 # counter for number of fuses per column
	outer_loop_2: # column iterator loop
	beq $t1, 3, end_outer_loop_2 # conditional for column iterator loop
	addi $t3, $t1, 0 # checker iterator

	inner_loop: # loop for adjacent cells (left)
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
	beq $t7, 0, fail_conditional
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
	beq $t7, 0, fail_conditional
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
	beq $t7, 0, fail_conditional
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
	beq $t7, 0, fail_conditional
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
	
	addi	$t3, $s0, 140	# get cell 35 (last cell) address
	addi	$t4, $0, 0	# counter for row
	addi	$t5, $0, 0	# column counter

print_grid_loop:
	print_char(124)		# print bar
	lw	$t1, 0($t0)	# get value of cell to check what to print
	
	beq	$t1, $0, print_cell_0
	beq	$t1, 2, print_cell_2
	beq	$t1, 4, print_cell_4
	beq	$t1, 8, print_cell_8
	beq	$t1, 16, print_cell_16
	beq	$t1, 32, print_cell_32
	beq	$t1, 64, print_cell_64
	beq	$t1, 128, print_cell_128
	beq	$t1, 256, print_cell_256
	beq	$t1, 512, print_cell_512
	beq	$t1, 1012, print_cell_1012
	beq	$t1, 2048, print_cell_2048
	
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
	
print_cell_1012:
	print_str_input(two_ten)
	b	next_print_loop
	
print_cell_2048:
	print_str_input(two_eleven)
	b	next_print_loop

next_print_loop:
	beq	$t4, 5, next_print_loop_2	# after printing cell 5
	beq	$t0, $t3, end_print_loop	# after printing cell 35
	
	addi	$t0, $t0, 4
	addi	$t4, $t4, 1
	b	print_grid_loop
	
next_print_loop_2:
	beq	$t5, 5, end_print_loop
	print_char(124)
	print_str_input(divider)
	addi	$t0, $t0, 4
	addi	$t4, $0, 0
	addi	$t5, $t5, 1
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
		addi	$t0, $0, 36	# for rand modulo
		get_rand($t0)		# generates random position
		addi	$t1, $0, 4	# set t0 to 4 for multiplication
		mul	$t0, $a0, $t1	# multiply offset by 4, store in $t0
		addi	$t2, $0, 2
		addi $t1, $t0, 0        # save current offset to $t1 resgiter for get_cell_value.
		get_cell_value($t1, $t3)
	bne $t3, 0, loop               # checks if randomly picked cell is not empty. Loops if it is not empty
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
	ble $t4, $t5, loop
	li $v0, 0 # return 0 if board is full
	b end
	
	zero_found:
		li $v0, 1 # return 1 if board is not full
	end:
	
.end_macro

.macro ask_for_move()
	li	$s4, 4		# sets s4 to the constant 4
start_ask_for_move:
	li $v0, 4            # System call for print_string
	la $a0, movement_prompt       # Load address of prompt string
	syscall

	li $v0, 8
	la $a0, inp_buffer
	li $a1, 100
	syscall
	la $t0, inp_buffer
	lb $t0, 0($t0)
	
	la $t1, move_w
	lb $t1, 0($t1)
	beq	$t0, $t1, w_input	# checks if input matches move_w string
	la $t1, move_wc
	lb $t1, 0($t1)
	beq	$t0, $t1, w_input	# checks if input matches move_wc string

	la $t1, move_a
	lb $t1, 0($t1)
	beq	$t0, $t1, a_input	# checks if input matches move_a string
	la $t1, move_ac
	lb $t1, 0($t1)
	beq	$t0, $t1, a_input	# checks if input matches move_ac string
	
	la $t1, move_s
	lb $t1, 0($t1)
	beq	$t0, $t1, s_input	# checks if input matches move_s string
	la $t1, move_sc
	lb $t1, 0($t1)
	beq	$t0, $t1, s_input	# checks if input matches move_sc string

	la $t1, move_d
	lb $t1, 0($t1)
	beq	$t0, $t1, d_input	# checks if input matches move_d string
	la $t1, move_dc
	lb $t1, 0($t1)
	beq	$t0, $t1, d_input	# checks if input matches move_dc string

	la $t1, move_x			# load move_x string address to t1
	lb $t1, 0($t1)			# load first byte of move_x string address to get actual character
	beq	$t0, $t1, x_input	# checks if input matches move_x string
	la $t1, move_xc			# load move_xc string address to t1
	lb $t1, 0($t1)			# load first byte of move_xc string address to get actual character
	beq	$t0, $t1, x_input	# checks if input matches move_xc string

	la $t1, move_3
	lb $t1, 0($t1)
	beq	$t0, $t1, disable_random	# checks if input matches 3 string

	la $t1, move_4
	lb $t1, 0($t1)
	beq	$t0, $t1, enable_random	# checks if input matches 4 string
	
	b start_ask_for_move
w_input:
	move_up()
	beq	$v0, 1, end_movement
	reset_registers()
	print_grid()
	b start_ask_for_move
	
a_input:
	move_left()
	beq	$v0, 1, end_movement
	reset_registers()
	print_grid()
	b start_ask_for_move
	
s_input:
	move_down()
	beq	$v0, 1, end_movement
	reset_registers()
	print_grid()
	b start_ask_for_move
	
d_input:
	move_right()
	beq	$v0, 1, end_movement
	reset_registers()
	print_grid()
	b start_ask_for_move
	
x_input:
	li $v0, 10
	syscall
	
enable_random:
	reset_registers()
	print_grid()
	print_str_input(newtile_msg)
	
	b main_game_loop_random
	
disable_random:
	reset_registers()
	print_grid()
	print_str_input(newtiledisable_msg)
	
	b main_game_loop_no_random
	
end_movement:
	
.end_macro

.macro custom_game_input()
	addi	$t2, $0, 4
	
cg_input_start:
	print_str_input(custom_game_cell_msg)
	get_int_input($t0)		# ask for cell number
	beq	$t0, 0, after_add	# 0 to end configuration
	subi	$t0, $t0, 1		# -1 if not "end configuration"
	
cg_input_loop:
	print_str_input(custom_game_cell_value_msg)
	get_int_input($t1)
	
	beq $t1, 0, next
	beq $t1, 2, next
	beq $t1, 4, next
	beq $t1, 8, next
	beq $t1, 16, next
	beq $t1, 32, next
	beq $t1, 64, next
	beq $t1, 128, next
	beq $t1, 256, next
	beq $t1, 512, next
	print_str_input(invalid_custom_input)
	b cg_input_loop
	next:
	mul	$t4, $t2, $t0	# get proper offset for set_cell_value
	set_cell_value($t4, $t1)	# set the cell with offset t4 to value in t1
	b	cg_input_start
.end_macro

.text
main:
	jal start_game
	j main_game_loop_random
	
start_game:
	print_str_input(start_msg)
	get_int_input($t0)
	addi	$t1, $0, 1
	addi	$t2, $0, 2
	beq	$t0, $t1, new_game_loop
	beq	$t0, $t2, custom_game_loop_start
	
new_game_loop:

	li	$v0, 9		# sbrk
	li	$a0, 144	# need 36 cells, 9*36 = 144
	syscall			# sbrk, memory location now in v0
	
	move	$s0, $v0	# stores CELL 0 address in $s0
	add_random_two_to_board()
	add_random_two_to_board()
	print_grid()
	jr $ra
	
custom_game_loop_start:
	li	$v0, 9		# sbrk
	li	$a0, 144	# need 36 cells, 9*36 = 144
	syscall
	move	$s0, $v0	# stores cell 0 in s0
	b	custom_game_loop_new
	
	
	# original code
	print_str_input(configuration_prompt)
	addi	$t0, $0, 0	# loop initial value
	addi	$t1, $0, 36	# loop guard
	addi	$t2, $0, 4	# for multiplication
	
	li	$v0, 9		# sbrk
	li	$a0, 144	# need 36 cells, 9*36 = 144
	syscall
	move	$s0, $v0

	
custom_game_loop_original:
	beq	$t0, $t1, after_add	# exit loop
	get_int_input($t3)	# get value to set cell
	beq $t3, 0, next
	beq $t3, 2, next
	beq $t3, 4, next
	beq $t3, 8, next
	beq $t3, 16, next
	beq $t3, 32, next
	beq $t3, 64, next
	beq $t3, 128, next
	beq $t3, 256, next
	beq $t3, 512, next
	print_str_input(invalid_custom_input)
	j custom_game_loop_original
	next:
	mul	$t5, $t2, $t0	# get proper offset for set_cell_value
	set_cell_value($t5, $t3)	# set the cell with offset t5 to value in t3
	addi	$t0, $t0, 1	# i = i + 1
	b	custom_game_loop_original

custom_game_loop_new:
	custom_game_input()

	
after_add:
	check_win_state()
	beq $v0, 1, win		# check win state returns 1 if win
	beq $v0, 0, lose	# check win state returns 2 if lose
				# else 0
	print_grid()
	reset_registers()
	jr $ra

main_game_loop_random:
	ask_for_move()
	check_if_board_is_full()
	beq $v0, 0, skip_generation
	add_random_two_to_board()
	skip_generation:
	check_win_state()
	beq	$v0, 1, win
	beq	$v0, 0, lose
	print_grid()
	b main_game_loop_random
	
main_game_loop_no_random:
	ask_for_move()
	check_win_state()
	beq	$v0, 1, win
	beq	$v0, 0, lose
	print_grid()
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
divider: .asciiz "\n+----+----+----+----+----+----+\n"
cells: .asciiz "|   |   |   |\n"

inp_buffer: .space 100

zero: .asciiz "    "
two_one: .asciiz "  2 "
two_two: .asciiz "  4 "
two_three: .asciiz "  8 "
two_four: .asciiz " 16 "
two_five: .asciiz " 32 "
two_six: .asciiz " 64 "
two_seven: .asciiz " 128"
two_eight: .asciiz " 256"
two_nine: .asciiz " 512"
two_ten: .asciiz "1024"
two_eleven: .asciiz "2048"

move_w: .asciiz "w\n"
move_a: .asciiz "a\n"
move_s: .asciiz "s\n"
move_d: .asciiz "d\n"
move_x: .asciiz "x\n"
move_wc: .asciiz "W\n"
move_ac: .asciiz "A\n"
move_sc: .asciiz "S\n"
move_dc: .asciiz "D\n"
move_xc: .asciiz "X\n"
move_3: .asciiz "3\n"
move_4: .asciiz "4\n"

start_msg: .asciiz "Choose [1] or [2]\n[1] New Game\n[2] Start from a State\n"
invalid_custom_input: .asciiz "Invalid Input!, Please choose from powers of 2 to 2048 only\n"
movement_prompt: .asciiz "Enter a move: "
configuration_prompt: "\nEnter a board configuration:\n"

win_msg: .asciiz "\nCongratulations! You have reached the 2048 tile!\n"
lose_msg: .asciiz "\nGame over.\n"

newtile_msg: .asciiz "New tile generation enabled.\n"
newtiledisable_msg: .asciiz "New tile generation disabled.\n"

custom_game_cell_msg: .asciiz "Enter a cell number (1 to 36, 0 to end configuration): \n"
custom_game_cell_value_msg: .asciiz "Enter a cell value (powers of 2 only): \n"
