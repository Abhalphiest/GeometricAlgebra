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

#--------------------------
# The sign lookup table uses bit fields to hard code the signs of
# outer products between each basis vector. A 1 in the binary representation
# at the nth position represents a negative product with the nth basis vector
# and a 0 positive.
#--------------------------

sign_tbl:
	.word	0	#bit field for e0
	.word	72	#e1
	.word	18	#e2
	.word	178	#e12
	.word	36	#e3
	.word	200	#e31
	.word	242	#e23
	.word	220	#e123

prod_arr:
	.word	0	#for building our product
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word 	0
	.word	0

#-------------------------
# Geometric objects are structured as follows:
# First 4 bytes store the number of terms (could be 1 byte but word aligned)
# The rest of the object is pairs of coefficient (4bytes) and bit field for
# basis vector (4 bytes) until all terms are recorded.
#
# The basis vector bit field works as follows. The least significant bit 
# represents e1, the second bit represents e2, etc. A bivector, trivector, etc
# can only be a combination of these individual vectors, so for example e123 is
# 111. e0 is zero.
#-------------------------

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



#
# Name: 	geom_product
#
# Description:	finds the geometric product of two geometric object operands
#
# Arguments:	a0: the address of the first operand
#		a1: the address of the second operand
#
# Returns:	the address of a geometric object representing the product
#
	.globl	geom_product
geom_product:
	addi	$sp, $sp, -32		#build our stack frame
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)
	sw	$s5, 24($sp)
	sw 	$s6, 28($sp)

	or	$s0, $a0, $zero		#protect our args
	or	$s1, $a1, $zero
	addi	$s2, $s0, 4		#s2 outer loop control
	addi	$s3, $s1, 4		#s3 inner loop control
	
	lw	$s4, 0($s0)		#set up our loop boundaries
	lw	$s5, 0($s1)
	sll	$s4, 3
	sll	$s5, 3
	add	$s4, $s0, $s4
	add	$s5, $s1, $s5
	addi	$s4, $s4, 4
	addi	$s5, $s5, 4
	la	$s6, prod_arr

prod_loop_out:
	slt	$t0, $s2, $s4
	beq	$t0, $zero, prod_loop_out_done

prod_loop_in:
	slt	$t0, $s3, $s5
	beq	$t0, $zero, prod_loop_in_done
	
	or	$a0, $s2, $zero
	or	$a1, $s3, $zero	#load our args
	
	jal	get_basis_product
	or	$t0, $v1, $zero
	sll	$t0, 2
	add	$t0, $s6, $t0	#get pointer to correct element of array
	lw	$t1, 0($t0)
	add	$t1, $v0, $t1
	sw	$t1, 0($t0)

	addi	$s3, $s3, 8
	j	prod_loop_in
prod_loop_in_done:

	addi	$s2, $s2, 8
	j 	prod_loop_out
prod_loop_out_done:
	or	$a0, $s6, $zero
	jal	new_ga_object	#puts it in v0 for us
	
	or	$a0, $s6, $zero
	jal	clear_product_arr
geom_product_done:
	lw	$ra, 0($sp)		#restore stack and return
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	lw	$s6, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra		

#
# Name:		get_basis_product
#
# Description:	given two basis vectors with coefficients,
#		determines their geometric product or outer product, 
#		including sign.
#
# Arguments:	a0: address of pair of coefficient and basis vector for op 1
#		a1: address of pair of coefficient and basis vector op 2
#
# Returns	v0: coefficient of product
#		v1: basis vector of product
#

get_basis_product:
					#no stack for leaf function
	lw	$t0, 4($a0)
	lw	$t1, 4($a1)		#get basis vectors
	
	la	$t2, sign_tbl
	sll	$t0, 2			#get words
	add	$t0, $t0, $t2		#correct address for lookup
	lw	$t3, 0($t0)		#get bit field for this basis vector
		
	or	$t4, $zero, $zero
	ori	$t5, $zero, 1	
shift_loop:
	slt	$t6, $t4, $t1		#there must be a better way than this
	beq	$t6, $zero, shift_loop_done
	sll	$t5, 1
	addi	$t4, $t4, 1		#increment loop
	j	shift_loop	
shift_loop_done:	
	lw	$t7, 0($a0)		#coefficients
	lw	$t8, 0($a1)		
	and	$t6, $t5, $t3		#check our sign
	beq	$t6, $zero, b_prod	#we're positive then
	addi	$t4, $zero, -1		#for bitwise negation
	xor	$t7, $t4, $t7		#negate our first coefficient
	addi	$t7, $t7, 1
b_prod:
	mult	$t7, $t8
	mflo	$v0			#we now have our coefficient
	lw	$t0, 4($a0)
	xor	$v1, $t0, $t1		#get our new basis vector

	jr	$ra			#return to caller



#
# Name: clear_product_arr
#
# Description: 	sets all the coefficients in the product array back to 0
# 
# Arguments: 	a0: ptr to product arr
#
# Returns:	Nothing
#

clear_product_arr:
					#leaf, no stack
	addi	$t0, $a0, 32		#8 integer loop
	or	$t1, $a0, $zero
	
clear_loop:
	slt	$t2, $t1, $t0
	beq	$t2, $zero, clear_loop_done
	sw	$zero, 0($t1)
	addi	$t1, $t1, 4
	j	clear_loop
clear_loop_done:
	jr	$ra
