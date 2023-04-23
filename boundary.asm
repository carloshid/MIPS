###############################image boundary######################
.data
.text
.globl image_boundary
##########################image boundary##################
image_boundary:
	# $a0 -> image struct
	############return###########
	# $v0 -> image struct s.t. contents containing only binary values 0,1


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
	
	
	
	sw $s1,0($s6)	#save the width, height,max value in new image
	sw $s2,4($s6)
	addi $t1,$0,1
	sw $t1,8($s6)
	
	
	
	move $t1,$s4	#number of values
	addi $t2,$0,1
	
loop:	addi $t6,$t2,11		#t6 = pointer in new image
	add $t6,$t6,$s6
	addi $t0,$t2,11
	add $t0,$t0,$s0
	
	#check top
	slt $t3,$t2,$s1
	beq $t3,1,zero
	beq $t2,$s1,zero
	
	sub $t4,$t2,$s1
	addi $t5,$t4,11		#pointer in old image
	add $t5,$t5,$s0
	lb $t4,($t5)
	beq $t4,0,zero	
skip_t:
	
	#check bottom
	sub $t3,$s4,$s1
	slt $t4,$t3,$t2
	beq $t4,1,zero
	
	add $t4,$t2,$s1
	addi $t5,$t4,11
	add $t5,$t5,$s0
	lb $t4,($t5)
	beq $t4,0,zero
skip_b:

	#check right
	div $t2,$s1
	mfhi $t3
	beq $t3,0,zero
	
	addi $t5,$t2,12
	add $t5,$t5,$s0
	lb $t4,($t5)
	beq $t4,0,zero
skip_r:
	
	#check left
	div $t2,$s1
	mfhi $t3
	beq $t3,1,zero
	
	addi $t5,$t2,10
	add $t5,$t5,$s0
	lb $t4,($t5)
	beq $t4,0,zero
skip_l:
	
	
	sb $0,($t6)
	j no_zero
	
zero:	
	lb $t5,($t0)
	beq $t5,0,no
	addi $t3,$0,1
	sb $t3,($t6)
	j no_zero
no:	sb $0,($t6)
	
no_zero:
        beq $t2,$t1,end
        addi $t2,$t2,1
        
        
        j loop
        
        
end:       
        
        move $v0,$s6
        
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
        

image_boundary.return:
	jr $ra
