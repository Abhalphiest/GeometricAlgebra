#
# File:		ga_main.asm
#
# Author:	Margaret Dorsey
#
# Description:	ga_main.asm basically provides an interface for testing
#		and utilizing the functions of geomalgebra.asm. Thus
#		here we handle mostly user input, validation, and
#		function calls.
#
# Revisions:	see gitlog.txt
#

#
# CONSTANT DEFINITIONS
#

#syscalls
PRINT_STRING = 	4
READ_INT =	5
EXIT = 		10

#for looping
DIMENSION =	8

#
# DATA
#

	.data
	.align	2

first_vector_label:
	.asciiz "First operand: \n"
second_vector_label:
	.asciiz "Second operand: \n"
product_label:
	.asciiz "Product output: \n"
newline:
	.asciiz "\n"

	.align 	2
input_arr:
	.space 32	#the max we would need for 3 dim
#
# FUNCTIONS
#

	.text
	.align	2
	.globl	main
	.globl	print_basis
	.globl	print_ga_object
	.globl	new_ga_object
#	.globl	geom_product

main:
	addi	$sp, $sp, -28		#build our stack frame
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)
	sw	$s5, 24($sp)

	la	$a0, first_vector_label
	ori	$v0, $zero, PRINT_STRING
	syscall

	la	$a0, input_arr		#get ready to call input function
	jal	get_obj_input

	la	$a0, input_arr		#our array is an arg
	jal	new_ga_object
	or	$a0, $zero, $v0
	jal	print_ga_object
	
	la	$a0, newline		#append a newline
	ori	$v0, $zero, PRINT_STRING
	syscall

	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	addi	$sp, $sp, 28
	jr	$ra		#return



#
# Name:	get_obj_input
#
# Description:	prompts the user to give the coefficients of a geometric
#		object
#
# Arguments:	address of a place where we can store our array
#
# Returns:	Nothing
#

get_obj_input:
	addi	$sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)

	or	$s1, $zero, $zero	#loop control
	ori	$s2, $zero, DIMENSION	#setup for loop
	or	$s3, $a0, $zero		#protect our address

get_input_loop:
	slt	$t0, $s1, $s2		#will be 1 if still in bounds
	beq	$t0, $zero, get_input_loop_done
	
	or	$a0, $zero, $s1		#print our basis vector as a label
	jal	print_basis
	ori	$v0, $zero, READ_INT
	syscall
	sw	$v0, 0($s3)
	addi	$s3, $s3, 4
	addi	$s1, $s1, 1
	j	get_input_loop
get_input_loop_done:
	lw	$ra, 0($sp)		#restore stack and return
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	addi	$sp, $sp, 16
	jr	$ra		
