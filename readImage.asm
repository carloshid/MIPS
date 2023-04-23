#########################Read Image#########################
.data
temp_string: .space 4 
.text
.globl read_image


#########################Read Image#########################
read_image:
	# $a0 -> input file name, it will be either P2 or P5 file
        # You need to check the char after 'P' to determine the image type. 
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################
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
	
	move $s2,$a0	#filename
	
	addi $a0,$0,20
	
	addi $sp,$sp,-4
	sw $ra,0($sp)	
	jal malloc
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	
	
	move $s3,$v0	#store address of current buffer
		
	li $v0,13	#open file
	move $a0,$s2
	li $a1,0
	syscall
	
	move $s1,$v0	#store file descriptor in s1
	
	li $v0,14	#read file
	move $a0,$s1	#file descriptor
	move $a1,$s3	#buffer
	la $a2,20
	syscall		
		
	addi $t0,$s3,1	#current character	
	
	lb $s7,($t0)	#2nd character, either 2 or 5 = s7
	addi $t0,$t0,2
	
	lb $t2,($t0)	#width
	addi $t2,$t2,-48
	addi $t0,$t0,1
	lb $t3,($t0)
	addi $t0,$t0,1
	#bne $t3,32,w2
	slti $t7,$t3,40
	beq $t7,0,w2
	j wdone
w2:	mul $t2,$t2,10
	add $t3,$t3,-48
	add $t2,$t2,$t3
	lb $t3,($t0)
	addi $t0,$t0,1
	#bne $t3,32,w3
	slti $t7,$t3,40
	beq $t7,0,w3
	j wdone
w3:	mul $t2,$t2,10
	add $t3,$t3,-48
	add $t2,$t2,$t3
	addi $t0,$t0,1
wdone:	move $s4,$t2	# s4 = width

	#li $v0,1
	#move $a0,$s4
	#syscall
	
	lb $t2,($t0)	#height
	add $t2,$t2,-48
	addi $t0,$t0,1
	lb $t3,($t0)
	addi $t0,$t0,1
	#bne $t3,10,h2
	slti $t7,$t3,40
	beq $t7,0,h2
	j hdone
h2:	mul $t2,$t2,10
	add $t3,$t3,-48
	add $t2,$t2,$t3
	lb $t3,($t0)
	addi $t0,$t0,1
	#bne $t3,10,h3
	slti $t7,$t3,40
	beq $t7,0,h3
	j hdone
h3:	mul $t2,$t2,10
	add $t3,$t3,-48
	add $t2,$t2,$t3
	addi $t0,$t0,1
hdone:	move $s5,$t2	# s5 = height

	lb $t2,($t0)	#max value
	add $t2,$t2,-48
	addi $t0,$t0,1
	lb $t3,($t0)
	addi $t0,$t0,1
	bne $t3,10,m2
	j mdone
m2:	mul $t2,$t2,10
	add $t3,$t3,-48
	add $t2,$t2,$t3
	lb $t3,($t0)
	addi $t0,$t0,1
	bne $t3,10,m3
	j mdone
m3:	mul $t2,$t2,10
	add $t3,$t3,-48
	add $t2,$t2,$t3
	addi $t0,$t0,1
mdone:	move $s6,$t2	# s6 = max value
	
	mul $t3,$s4,$s5	#multiply width x height
	mul $t2,$t3,5	#multiply by 5 (3 digits and 2 spaces)
	addi $t2,$t2,16	#add 16 for the header
	addi $t3,$t3,12 #add space for 3 words in t3
	
	add $a0,$t2,$0	#use the previous value as the size of the buffer	
	
	addi $sp,$sp,-4	#create buffer
	sw $ra,0($sp)	
	jal malloc
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	move $s3,$v0	#store address of new buffer
	
	li $v0,14	#read file
	move $a0,$s1	#file descriptor
	move $a1,$s3	#buffer
	move $a2,$t2
	syscall
	
	add $a0,$t3,$0
	addi $sp,$sp,-4	#create buffer to store the width, heigh, max value and array of the structure (width x height + 12)
	sw $ra,0($sp)	
	jal malloc
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	move $s0,$v0	#store address of array

	# At this point, t0 = pointer in the file starting at first value ; t1 = pointer to first value of structure ; t2 = size of file buffer ; t3 = size of structure in bytes
	addi $t1,$s0,12
	sw $s4,0($s0)	#save the width,height and max value as words
	sw $s5,4($s0)
	sw $s6,8($s0)
	
	beq $s7,50,p2	#if 2nd character is equal to 2, jump to p2
	j p5		#else jump to p5	


p2:	

	add $t5,$0,$0	#set t5 and t6 to 0 ; t5 = current integer ; t6 = position in temp string
	la $t6,temp_string
	add $t7,$0,$0

loop2:	lb $t4,($t0)

	#li $v0,11
	#move $a0,$t4
	#syscall
	
	addi $t0,$t0,1
	beq $t4,0,next2
	beq $t4,32,next2
	beq $t4,10,next2
	sb $t4,($t6)
	addi $t6,$t6,1
	addi $t7,$t7,1
	j loop2
	

next2:	sb $0,($t6)	#save null character
	la $t6,temp_string	#reset position in temp_string
	
	beq $t4,0,skip
	beq $t7,$0,loop2
	add $t7,$0,$0
skip:	
	move $a0,$t6	#convert the string to an integer
	addi $sp,$sp,-28
	sw $ra,0($sp)
	sw $t0,4($sp)
	sw $t1,8($sp)
	sw $t2,12($sp)
	sw $t3,16($sp)
	sw $t4,20($sp)
	sw $t5,24($sp)
	jal str2int
	lw $ra,0($sp)
	lw $t0,4($sp)
	lw $t1,8($sp)
	lw $t2,12($sp)
	lw $t3,16($sp)
	lw $t4,20($sp)
	lw $t5,24($sp)
	addi $sp,$sp,28
	
	move $t5,$v0	#store the integer
	
	#li $v0,1
	#move $a0,$t5
	#syscall
	
	#li $v0,11
	#addi $a0,$0,32
	#syscall
	
	
	
	sb $t5,($t1)	#save as byte in the structure
	addi $t1,$t1,1
	
	
	beq $t4,0,end2
	j loop2
	

end2:	lb $s2,105($s0)
	move $v0,$s0
	lb $s2,105($v0)
	j read_image.return






p5:	mul $t5,$s4,$s5		#number of bytes
	

	

loop5:	beq $t5,$0,end5		# t5 = 0 => all bytes done
	lb $t4,($t0)	
	addi $t0,$t0,1
	sb $t4,($t1)
	addi $t1,$t1,1
	addi $t5,$t5,-1
	j loop5
	
end5:	move $v0,$s0
	
	
	
	
	
	#For P2 you need to use str2int 
	
	
	


read_image.return:
	
	li $v0,16	#close file and return
	move $a0,$s1
	
	syscall
	move $v0,$s0
	
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
	
	jr $ra
	
	
	

