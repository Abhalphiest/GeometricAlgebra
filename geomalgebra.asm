# File: 	geomalgebra.asm
#
# Author:	Margaret Dorsey
#
# Description:	Handles all the functions inherent to geometric algebra
#		objects, like the product, and also the building of those
#	 	objects.
#
# Revision:	see gitlog.txt
#

#
# CONSTANT DEFINITIONS
#

MEM_BOUND = 	400

#syscalls
EXIT = 		10

#
# DATA
#
	.data
	.align	2

mem_pool:
	.space	400	#we're cheesing it because heap management is hard
			# and should be added later
pool_ptr:
	.word mem_pool	#pointer to the start of our pool



#
# FUNCTIONS
#

	.text
	.align	2
	.globl	new_ga_object
#
# Name: 	new_ga_object
#
# Description:	takes an array of coefficients and makes a geometric object
#		out of them, taking memory from the mem pool for now
#
# Arguments:	a0: pointer to an array of ints length 8
#
# Returns:	pointer to a geometric object
#

new_ga_object:
					#no stack for leaf function
	ori	$t0, $zero, 8		#set up for our loop
	or	$t1, $zero, $zero
	la	$t2, pool_ptr
	lw	$t3, 0($t2)		#the ptr to where our next mem is
	addi	$t3, $t3, 4		#leave space for our length
	or	$t5, $zero, $zero	#counter for length

	la	$t6, mem_pool
	addi	$t6, $t6, MEM_BOUND
coeff_loop:
	slt	$t4, $t1, $t0		#bounds checking on array
	beq	$t4, $zero, coeff_loop_done

	slt	$t4, $t3, $t6		#do we still have memory left?
	beq	$t4, $zero, mem_gone
	
	lw	$t4, 0($a0)		#get coefficient
	beq	$t4, $zero, coeff_stored#skip all this stuff for 0 coeff
	
	sw	$t4, 0($t3)		#our coefficient
	sw	$t1, 4($t3)		#our basis vec
	addi	$t3, $t3, 8		#move our memory along
	addi	$t5, $t5, 1	
	
coeff_stored:
	addi	$a0, $a0, 4		#next part of array
	addi	$t1, $t1, 1		#increment our loop control
	j	coeff_loop
coeff_loop_done:
	lw	$v0, 0($t2)		#get where our struct started again
	sw	$t5, 0($v0)		#put our length at the beginning
	sw	$t3, 0($t2)		#update the persistent ptr
	
	jr	$ra			#return
mem_gone:
	ori	$v0, $zero, EXIT	#we'll just go die for now
	syscall
