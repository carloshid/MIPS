###############################str2int######################
.data
.align 2
blank:		.asciiz "\n"
.text
.globl str2int
###############################str2int######################
str2int:
	# $a0 -> address of string, i.e "32", terminated with 0, EOS
	###### returns ########
	# $v0 -> return converted integer value
	# $v1 -> length of integer
	###########################################################
	# Add code here
	
	addi $sp,$sp,-36	#save registers to the stack
	sw $ra,0($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
	sw $s4,20($sp)
	sw $s5,24($sp)
	sw $s6,28($sp)
	sw $s7,32($sp)
	
	add $t0,$a0,$0		#store the address in t0
	add $t2,$0,$0		#counter to store the number of digits
	
loop1:	lb $t1,($t0)		#load the current character
	beq $t1,0,done1		#if null character, end the loop
	addi $t0,$t0,1		#next character
	addi $t2,$t2,1		#add 1 to coutner
	j loop1
	
done1:	add $v1,$t2,$0		#store the length of the integer in v1
	add $t0,$a0,$0		#store the address in t0 again
	addi $t3,$0,1		#store value 1 in t3
	add $t4,$0,$0		#value of the integer to return, intially 0
	
power:	beq $t2,1,loop2		#if t2 is equal to 1, start loop 2
	beq $t2,0,loop2		#if t2 is equal to 0, start loop 2
	mul $t3,$t3,10		#multiply t3 by 10 to get a higher power of 10
	addi $t2,$t2,-1		#subtract 1 from t2
	j power

loop2:	lb $t1,($t0)		#load the current character
	beq $t1,0,done2		#if null character, end the loop
	addi $t1,$t1,-48	#integer value of the current digit
	mul $t5,$t3,$t1		#multiply current digit by corresponding power of 10
	add $t4,$t4,$t5		#add the value of the current digit to the final value
	addi $t0,$t0,1
	div $t3,$t3,10
	j loop2
	
done2:	add $v0,$t4,$0		#store the integer value in v0

	
	lw $ra,0($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
	lw $s4,20($sp)
	lw $s5,24($sp)
	lw $s6,28($sp)
	lw $s7,32($sp)
	addi $sp,$sp,36	#restore registers from the stack
	
	
str2int.return:
	jr $ra
	
	
