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
	.asciiz "First operand: "
second_vector_label:
	.asciiz "Second operand: "
product_label:
	.asciiz "Product output: "
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

	or	$s4, $zero, $zero	#loop control
	ori	$s3, $zero, DIMENSION	#set up for loop bound
	la	$s5, input_arr
get_input_loop:
	slt	$t0, $s4, $s3		#will be 1 if we are still in
	beq	$t0, $zero, validate_input
	or	$a0, $zero, $s4
	jal	print_basis
	ori	$v0, $zero, READ_INT
	syscall
	sw	$v0, 0($s5)
	addi	$s5, $s5, 4
	addi	$s4, $s4, 1
	j	get_input_loop
	
validate_input:
	la	$a0, input_arr		#our array is an arg
	jal	new_ga_object
	or	$a0, $zero, $v0
	jal	print_ga_object

	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	addi	$sp, $sp, 28
	jr	$ra		#return
