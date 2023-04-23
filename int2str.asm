###############################int2str######################
.data
.align 2
int2strBuffer:	.word 36
.text
.globl int2str
###############################int2str######################
int2str:
	# $a0 <- integer to convert
	##############return#########
	# $v0 <- space terminated string 
	# $v1 <- length or number string + 1(for space)
	###############################
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
	
	add $t1,$0,$0		#initialize t1 to 0
	la $v0,int2strBuffer	#store the address of the first character of the string in v0 and t4
	add $t4,$v0,$0
	
	slti $t0,$a0,100
	beq $t0,0,three		#if the integer is >= 100 (3 digits), jump to 'three' label
	slti $t0,$a0,10	
	beq $t0,0,two		#if the integer is >= 10 (2 digits), jump to 'two' label
	j one			#otherwise, jump to 'one' label

three:	div $t2,$a0,100		#get third digit (from right to left)
	addi $t7,$t2,48		#convert digit to ascii value
	sb $t7,($t4)		#save the current digit as a byte
	addi $t4,$t4,1		
	addi $t1,$t1,1		#add 1 to t1 and t4
	mul $t6,$t2,100
	sub $a0,$a0,$t6

two:	div $t2,$a0,10		#get 2nd digit (from right to left)
	addi $t7,$t2,48		#convert digit to ascii value
	sb $t7,($t4)		#save the current digit as a byte
	addi $t4,$t4,1		
	addi $t1,$t1,1		#add 1 to t1
	mul $t6,$t2,10
	sub $a0,$a0,$t6

one:	div $t2,$a0,1		#get 1st digit (from right to left)
	addi $t7,$t2,48		#convert digit to ascii value
	sb $t7,($t4)		#save the current digit as a byte
	addi $t4,$t4,1		
	addi $t1,$t1,1		#add 1 to t1t1

space:	addi $t2,$0,32		#ascii value for space
	sb $t2,($t4)		#save the space as a byte
	
	addi $v1,$t1,1		#store the length of the string (with space) in v1
	
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

int2str.return:
	jr $ra
