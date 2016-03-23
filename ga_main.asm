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

#
# FUNCTIONS
#

	.text
	.align	2
	.globl	main
	.globl	print_basis
	.globl	print_ga_object
#	.globl	new_ga_object
#	.globl	geom_product

main:
	addi	$sp, $sp, -24		#build our stack frame
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)

	or	$s4, $zero, $zero	#loop control
	ori	$s3, $zero, DIMENSION	#set up for loop bound
get_input_loop:
	slt	$t0, $s4, $s3		#will be 1 if we are still in
	beq	$t0, $zero, validate_input

validate_input:

	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	addi	$sp, $sp, 24
	jr	$ra		#return
