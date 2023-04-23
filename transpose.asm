##########################image transpose##################
.data
.text
.globl transpose
##########################image transpose##################
transpose:
	# $a0 -> image struct
	###############return################
	# $v0 -> image struct s.t. contents containing the transpose image.
	# Note that you need to rewrite width, height and max_value information
	
	
	# Adds your codes here 
	
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
	
	move $s0,$a0	#old image
        lw $s1,0($s0)	#width
        lw $s2,4($s0)	#height
        lw $s3,8($s0)	#max value
        
        mul $s4,$s1,$s2	#number of values
        
        addi $s5,$s4,12	#total size = 12 + s4
       
        
        move $a0,$s5
        
        addi $sp,$sp,-4	#create buffer for new image
	sw $ra,0($sp)	
	jal malloc
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	move $s6,$v0	#address of new image
	
	sw $s2,0($s6)	#save the width, height,max value in new image
	sw $s1,4($s6)
	sw $s3,8($s6)
	
	move $t1,$s4	#number of values
	addi $t2,$0,0
	
loop:	addi $t3,$t2,12	#t3 = pointer in old image
	add $t3,$t3,$s0
	lb $t7,($t3)
	
	div $t2,$s1	#divide current position by width, row # is LO, column # is HI, starting at 0
	mflo $t4	#t4 is old row / new column   0
	mfhi $t5	#t5 is old column / new row   1
	
	
	mul $t6,$t5,$s2	#calculate the position in the new array
	add $t6,$t6,$t4
	add $t6,$t6,12	
	add $t6,$t6,$s6	#get the address from the position
	
	sb $t7,($t6)
		
	
	addi $t2,$t2,1
        beq $t2,$t1,end
        
        j loop
        
end:	move $v0,$s6
	
	
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
	

	
        

transpose.return:
	jr $ra
