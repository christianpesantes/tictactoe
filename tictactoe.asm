
#----------------------------------------------------------
# TicTacToe
# by Christian Pesantes, 1231218
#----------------------------------------------------------

.data
str_nwl: .asciiz "\n"
str_space: .asciiz " "
str_error: .asciiz "error!\n"
str_p1_play: .asciiz "[P1]: "
str_p2_play: .asciiz "[P2]: "
str_p1_win: .asciiz "P1 wins!\n"
str_p2_win: .asciiz "P2 wins!\n"
str_no_win: .asciiz "no winner!\n"
str_menu: .asciiz "enter [1] to play again... [INPUT]: "
str_x: .asciiz "x"
str_o: .asciiz "o"

.align 2				# 2^n; 2^2 = 4; 4 bytes -> integer
int_grid: .space 36		# 9 x 4 = 36
# 1 2 3
# 4 5 6
# 7 8 9
int_game: .space 36		# 9 x 4 = 36
# 0 -> empty slot
# 1 -> empty slot
# 2 -> empty slot

.text
.globl main

#----------------------------------------------------------
main:

	la $s0, int_grid
	la $s1, int_game
	
	jal func_setup_grid
	jal func_setup_game
	jal func_print_grid

	game_loop:
			
		jal func_p1_move
		jal func_print_grid
		
		jal func_check_p1_won
		move $t0, $v0
		# get 0 for keep going
		# get 1 for P1 win
		# get 2 for P2 win
		# get 3 for draw
		beq $t0, 1, p1_win_message
		beq $t0, 3, no_win_message
		
		jal func_p2_move
		jal func_print_grid
		
		jal func_check_p2_won
		move $t0, $v0
		# get 0 for keep going
		# get 1 for P1 win
		# get 2 for P2 win
		# get 3 for draw
		beq $t0, 2, p2_win_message
		beq $t0, 3, no_win_message
		
		j game_loop
		
	p1_win_message:
		li $v0, 4
		la $a0, str_p1_win
		syscall
		j replay

	p2_win_message:
		li $v0, 4
		la $a0, str_p2_win
		syscall
		j replay
		
	no_win_message:
		li $v0, 4
		la $a0, str_no_win
		syscall
		j replay

	replay:
		li $v0, 4
		la $a0, str_menu
		syscall
		li $v0, 5
		syscall
		move $t0, $v0
		beq $t0, 1, main
		j exit

#----------------------------------------------------------
exit:
	li $v0, 10
	syscall
	
# 						function: setup grid
#------------------------------------------------
func_setup_grid:	

	la $t0, ($s0)
	li $t1, 0

	setup_grid_loop:
	
		beq $t1, 9, setup_grid_loop_end	
		addi $t1, $t1, 1
		
		sw $t1, ($t0)
		addi $t0, $t0, 4
		j setup_grid_loop
		
	setup_grid_loop_end:
		jr $ra
		
# 						function: setup game
#------------------------------------------------
func_setup_game:	

	la $t0, ($s1)
	li $t1, 0
	li $t2, 0

	setup_game_loop:
	
		beq $t1, 9, setup_game_loop_end	
		addi $t1, $t1, 1
		
		sw $t2, ($t0)
		addi $t0, $t0, 4
		j setup_game_loop
		
	setup_game_loop_end:
		jr $ra
		
# 						function: print grid
#------------------------------------------------
func_print_grid:	

	la $t0, ($s0)
	la $t4, ($s1)
	li $t1, 0
	li $t2, 3
	
	print_grid_loop:
	
		beq $t1, 9, print_grid_loop_end	
		
		li $v0, 4
		la $a0, str_space
		syscall
		
		print_grid_inner_loop:
		
			beq $t1, $t2, print_grid_inner_loop_end
			
			lw $t3, ($t4)
			beq $t3, 0, print_empty_slot
			beq $t3, 1, print_p1_slot
			beq $t3, 2, print_p2_slot
			
			print_empty_slot:
				li $v0, 1
				lw $a0, ($t0)
				syscall
				j print_continue
				
			print_p1_slot:
				li $v0, 4
				la $a0, str_x
				syscall
				j print_continue
				
			print_p2_slot:
				li $v0, 4
				la $a0, str_o
				syscall
				j print_continue
				
			print_continue:
				li $v0, 4
				la $a0, str_space
				syscall
			
				addi $t0, $t0, 4
				addi $t4, $t4, 4
				addi $t1, $t1, 1
				j print_grid_inner_loop
		
		print_grid_inner_loop_end:
			li $v0, 4
			la $a0, str_nwl
			syscall
			addi $t2, $t2, 3
			j print_grid_loop

	print_grid_loop_end:
		jr $ra
		
# 						function: player 1 move
#------------------------------------------------
func_p1_move:
	
	la $t1, ($s1)
	li $t5, 1
	
	func_p1_loop:
		li $v0, 4
		la $a0, str_p1_play
		syscall
		li $v0, 5
		syscall
		move $t2, $v0
		
		beq $t2, 1, func_p1_check_0
		beq $t2, 2, func_p1_check_1
		beq $t2, 3, func_p1_check_2
		beq $t2, 4, func_p1_check_3
		beq $t2, 5, func_p1_check_4
		beq $t2, 6, func_p1_check_5
		beq $t2, 7, func_p1_check_6
		beq $t2, 8, func_p1_check_7
		beq $t2, 9, func_p1_check_8
		j func_p1_error_message
		
		func_p1_check_0:
			addi $t1, $t1, 0
			lw $t0, ($t1)
			bnez $t0, func_p1_error_message
			sw $t5, ($t1)
			j func_p1_loop_end
			
		func_p1_check_1:
			addi $t1, $t1, 4
			lw $t0, ($t1)
			bnez $t0, func_p1_error_message
			sw $t5, ($t1)
			j func_p1_loop_end
			
		func_p1_check_2:
			addi $t1, $t1, 8
			lw $t0, ($t1)
			bnez $t0, func_p1_error_message
			sw $t5, ($t1)
			j func_p1_loop_end
			
		func_p1_check_3:
			addi $t1, $t1, 12
			lw $t0, ($t1)
			bnez $t0, func_p1_error_message
			sw $t5, ($t1)
			j func_p1_loop_end
			
		func_p1_check_4:
			addi $t1, $t1, 16
			lw $t0, ($t1)
			bnez $t0, func_p1_error_message
			sw $t5, ($t1)
			j func_p1_loop_end
			
		func_p1_check_5:
			addi $t1, $t1, 20
			lw $t0, ($t1)
			bnez $t0, func_p1_error_message
			sw $t5, ($t1)
			j func_p1_loop_end
			
		func_p1_check_6:
			addi $t1, $t1, 24
			lw $t0, ($t1)
			bnez $t0, func_p1_error_message
			sw $t5, ($t1)
			j func_p1_loop_end
			
		func_p1_check_7:
			addi $t1, $t1, 28
			lw $t0, ($t1)
			bnez $t0, func_p1_error_message
			sw $t5, ($t1)
			j func_p1_loop_end
			
		func_p1_check_8:
			addi $t1, $t1, 32
			lw $t0, ($t1)
			bnez $t0, func_p1_error_message
			sw $t5, ($t1)
			j func_p1_loop_end
		
		func_p1_error_message:
			li $v0, 4
			la $a0, str_error
			syscall
			la $t1, ($s1)
			j func_p1_loop
		
	func_p1_loop_end:
		jr $ra
	
# 						function: player 2 move
#------------------------------------------------
func_p2_move:
	
	la $t1, ($s1)
	li $t5, 2
	
	func_p2_loop:
		li $v0, 4
		la $a0, str_p2_play
		syscall
		li $v0, 5
		syscall
		move $t2, $v0
		
		beq $t2, 1, func_p2_check_0
		beq $t2, 2, func_p2_check_1
		beq $t2, 3, func_p2_check_2
		beq $t2, 4, func_p2_check_3
		beq $t2, 5, func_p2_check_4
		beq $t2, 6, func_p2_check_5
		beq $t2, 7, func_p2_check_6
		beq $t2, 8, func_p2_check_7
		beq $t2, 9, func_p2_check_8
		j func_p2_error_message
		
		func_p2_check_0:
			addi $t1, $t1, 0
			lw $t0, ($t1)
			bnez $t0, func_p2_error_message
			sw $t5, ($t1)
			j func_p2_loop_end
			
		func_p2_check_1:
			addi $t1, $t1, 4
			lw $t0, ($t1)
			bnez $t0, func_p2_error_message
			sw $t5, ($t1)
			j func_p2_loop_end
			
		func_p2_check_2:
			addi $t1, $t1, 8
			lw $t0, ($t1)
			bnez $t0, func_p2_error_message
			sw $t5, ($t1)
			j func_p2_loop_end
			
		func_p2_check_3:
			addi $t1, $t1, 12
			lw $t0, ($t1)
			bnez $t0, func_p2_error_message
			sw $t5, ($t1)
			j func_p2_loop_end
			
		func_p2_check_4:
			addi $t1, $t1, 16
			lw $t0, ($t1)
			bnez $t0, func_p2_error_message
			sw $t5, ($t1)
			j func_p2_loop_end
			
		func_p2_check_5:
			addi $t1, $t1, 20
			lw $t0, ($t1)
			bnez $t0, func_p2_error_message
			sw $t5, ($t1)
			j func_p2_loop_end
			
		func_p2_check_6:
			addi $t1, $t1, 24
			lw $t0, ($t1)
			bnez $t0, func_p2_error_message
			sw $t5, ($t1)
			j func_p2_loop_end
			
		func_p2_check_7:
			addi $t1, $t1, 28
			lw $t0, ($t1)
			bnez $t0, func_p2_error_message
			sw $t5, ($t1)
			j func_p2_loop_end
			
		func_p2_check_8:
			addi $t1, $t1, 32
			lw $t0, ($t1)
			bnez $t0, func_p2_error_message
			sw $t5, ($t1)
			j func_p2_loop_end
		
		func_p2_error_message:
			li $v0, 4
			la $a0, str_error
			syscall
			la $t1, ($s1)
			j func_p2_loop
		
	func_p2_loop_end:
		jr $ra
	
# 						function: check p1 won
#------------------------------------------------
func_check_p1_won:

	# 0 1 2	
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 0
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0

	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 1, func_check_p1_won_end_1
	
	# 3 4 5	
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 12
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0

	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 1, func_check_p1_won_end_1
	
	# 6 7 8	
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 24
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0

	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 1, func_check_p1_won_end_1
	
	# 0
	# 3
	# 6
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 0
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 12
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 24
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 1, func_check_p1_won_end_1
	
	# 1
	# 4
	# 7
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 16
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 28
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 1, func_check_p1_won_end_1
	
	# 2
	# 5
	# 8
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 8
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 20
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 32
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 1, func_check_p1_won_end_1
	
	# 0
	#   4
	#     8
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 0
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 16
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 32
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 1, func_check_p1_won_end_1
	
	#     2
	#   4
	# 6
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 8
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 16
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 24
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 1, func_check_p1_won_end_1
	
	la $t1, ($s1)
	li $t0, 0
	
	func_check_p1_empty_slot_loop:
		
		beq $t0, 9, func_check_p1_won_end_3
		lw $t2, ($t1)
		beq $t2, 0, func_check_p1_won_end_0
		addi $t1, $t1, 4
		addi $t0, $t0, 1
		j func_check_p1_empty_slot_loop
	
	func_check_p1_won_end_0:
		li $v0, 0
		jr $ra
		
	func_check_p1_won_end_1:
		li $v0, 1
		jr $ra
		
	func_check_p1_won_end_3:
		li $v0, 3
		jr $ra

# 						function: check p2 won
#------------------------------------------------
func_check_p2_won:

	# 0 1 2	
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 0
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0

	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 8, func_check_p2_won_end_2
	
	# 3 4 5	
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 12
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0

	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 8, func_check_p2_won_end_2
	
	# 6 7 8	
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 24
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0

	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 8, func_check_p2_won_end_2
	
	# 0
	# 3
	# 6
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 0
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 12
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 24
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 8, func_check_p2_won_end_2
	
	# 1
	# 4
	# 7
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 4
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 16
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 28
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 8, func_check_p2_won_end_2
	
	# 2
	# 5
	# 8
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 8
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 20
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 32
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 8, func_check_p2_won_end_2
	
	# 0
	#   4
	#     8
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 0
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 16
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 32
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 8, func_check_p2_won_end_2
	
	#     2
	#   4
	# 6
	la $t1, ($s1)
	li $t0, 1
	
	addi $t1, $t1, 8
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	la $t1, ($s1)
	addi $t1, $t1, 16
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
		
	la $t1, ($s1)
	addi $t1, $t1, 24
	lw $t2, ($t1)
	mult $t0, $t2
	mflo $t0
	
	beq $t0, 8, func_check_p2_won_end_2
	
	la $t1, ($s1)
	li $t0, 0
	
	func_check_p2_empty_slot_loop:
		
		beq $t0, 9, func_check_p2_won_end_3
		lw $t2, ($t1)
		beq $t2, 0, func_check_p2_won_end_0
		addi $t1, $t1, 4
		addi $t0, $t0, 1
		j func_check_p2_empty_slot_loop
	
	func_check_p2_won_end_0:
		li $v0, 0
		jr $ra
		
	func_check_p2_won_end_2:
		li $v0, 2
		jr $ra
		
	func_check_p2_won_end_3:
		li $v0, 3
		jr $ra