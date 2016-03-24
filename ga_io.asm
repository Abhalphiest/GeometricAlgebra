# File: 	ga_io.asm
# 
# Author: 	Margaret Dorsey
#
# Description: 	A collection of functions for printing out geometric algebra
#		results.
#

#
# CONSTANT DEFINITIONS
#

#syscall
PRINT_INT =	1
PRINT_STRING = 	4

#
# DATA
#
	.data
	.align 	2

#basis vectors

e0_print:
	.asciiz "e0\t"
e1_print:
	.asciiz "e1\t"
e2_print:
	.asciiz "e2\t"
e3_print:
	.asciiz "e3\t"
e12_print:
	.asciiz "e12\t"
e23_print:
	.asciiz "e23\t"
e31_print:
	.asciiz "e31\t"
e123_print:
	.asciiz "e123\t"

	.align	2



basis_tbl:
	.word 	e0_print
	.word	e1_print
	.word	e2_print
	.word	e3_print
	.word	e12_print
	.word	e23_print
	.word	e31_print
	.word	e123_print

#
# FUNCTIONS
#

	.text
	.align 	2
	.globl	print_ga_object
	.globl	print_basis

#
# Name: 	print_basis
#
# Description:	prints a basis vector based on a bit field integer
#
# Arguments:	a0: integer representing a basis vector
#
# Returns:	Nothing.
#

print_basis:
	addi	$sp, $sp, -4	#build our stack frame
	sw	$ra, 0($sp)

	la	$t0, basis_tbl	#get the address of our lookup table
	sll	$a0, 2		#change from word addressed to byte addressed
	add	$t0, $t0, $a0	
	lw	$a0, 0($t0)	#address of our null terminated string
	ori	$v0, $zero, PRINT_STRING
	syscall			#print our stuff

	lw	$ra, 0($sp)	#restore stack frame
	addi	$sp, $sp, 4
	jr	$ra		#return to caller

#
# Name:		print_ga_object
#
# Description:	prints out a geometric algebra object structure in basis
#		vector notation.
#
# Arguments:	a0: address of a geometric object
#
# Returns:	Nothing
#

print_ga_object:
	addi	$sp, $sp, -20		#build our stack frame
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)		#protect our argument
	sw	$s1, 8($sp)		#protect our length
	sw	$s2, 12($sp)		#loop control
	sw	$s3, 16($sp)		#pointer in struct

	or	$s0, $a0, $zero		#save our address
	lw	$s1, 0($s0)		#get our length
	or	$s2, $zero, $zero	#initialize loop control
	addi	$s3, $s0, 4		#skip the first word
print_ga_loop:
	slt	$t0, $s2, $s1		#still more things to print?
	beq	$t0, $zero, print_ga_loop_done

	lw	$a0, 0($s3)		#print coefficient
	ori	$v0, $zero, PRINT_INT	
	syscall

	lw	$a0, 4($s3)		#print our basis vector
	jal	print_basis
	
	addi	$s3, $s3, 8		#go to next term
	addi	$s2, $s2, 1
	j	print_ga_loop		#back to top
print_ga_loop_done:


	lw	$ra, 0($sp)		#restore our stack frame
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra			#return to caller
