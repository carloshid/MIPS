####################################write Image#####################
.data
.text
.globl write_image
####################################write Image#####################
write_image:
	# $a0 -> image struct
	# $a1 -> output filename
	# $a2 -> type (0 -> P5, 1->P2)
	################# returns #################
	# void
	# Add code here.
	
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
	
	
	move $s0,$a0	#address of structure
	move $s1,$a1	#filename
	move $s2,$a2	#P2 if 1, P5 if 0
	
	
	
	lw $s4,0($s0)	#width
	lw $s5,4($s0)	#height
	lw $s6,8($s0)	#max value
	
	
	mul $s3,$s4,$s5	#multiply width x height
	mul $t2,$s3,5	#multiply by 4 (3 digits and 1 spaces)
	addi $t2,$t2,16	#add 16 for the header
	move $t9,$t2
	
	add $a0,$t2,$0	#use the previous value as the size of the buffer	
	
	addi $sp,$sp,-4	#create buffer
	sw $ra,0($sp)	
	jal malloc
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	move $s7,$v0
	move $t8,$s7
	
	li $t1,80
	sb $t1,($t8)
	addi $t8,$t8,1
	beq $s2,0,skip5
	li $t1,50
	sb $t1,($t8)
	addi $t8,$t8,1
	j skip2
skip5:	li $t1,53
	sb $t1,($t8)
	addi $t8,$t8,1
skip2:	li $t1,10
	sb $t1,($t8)
	addi $t8,$t8,1


	
	move $a0,$s4	#width to string
	addi $sp,$sp,-4
	sw $ra,0($sp)	
	jal int2str
	lw $ra,0($sp)
	addi $sp,$sp,4
	move $s4,$v0
	
	beq $s2,1,line
	
	move $t1,$s4
	lb $t2,($t1)
wloop:	beq $t2,32,endw
	addi $t1,$t1,1
	lb $t2,($t1)
	j wloop
endw:	addi $t3,$0,10
	sb $t3,($t1)
	
line:	
	
	move $t1,$v1
	
	add $t3,$0,$0
	move $t4,$s4
loopw:	beq $t1,0,donew
	lb $t2,($t4)
	sb $t2,($t8)
	addi $t4,$t4,1
	addi $t8,$t8,1
	addi $t1,$t1,-1
	
	j loopw
donew:	
	
	
	
	
	move $a0,$s5	#height to string
	addi $sp,$sp,-8
	sw $ra,0($sp)
	sw $s4,4($sp)	

	
	
	move $a0,$s5
	jal int2str
		
	lw $ra,0($sp)
	lw $s4,4($sp)
	addi $sp,$sp,8
	move $s5,$v0
	
	
	
	move $t1,$s5
	lb $t2,($t1)
hloop:	beq $t2,32,endh
	addi $t1,$t1,1
	lb $t2,($t1)
	j hloop
endh:	addi $t3,$0,10
	sb $t3,($t1)
	
	move $t1,$v1
	
	add $t3,$0,$0
	move $t4,$s5
looph:	beq $t1,0,doneh
	lb $t2,($t4)
	sb $t2,($t8)
	addi $t4,$t4,1
	addi $t8,$t8,1
	addi $t1,$t1,-1
	
	j looph
doneh:	
	
	
	
	
	
	move $a0,$s6	#max value to string
	addi $sp,$sp,-4
	sw $ra,0($sp)	
	jal int2str
	lw $ra,0($sp)
	addi $sp,$sp,4
	move $s6,$v0
	
	move $t1,$s6
	lb $t2,($t1)
mloop:	beq $t2,32,endm
	addi $t1,$t1,1
	lb $t2,($t1)
	j mloop
endm:	addi $t3,$0,10
	sb $t3,($t1)
	
	
	move $t1,$v1
	
	add $t3,$0,$0
	move $t4,$s6
loopm:	beq $t1,0,donem
	lb $t2,($t4)
	sb $t2,($t8)
	addi $t4,$t4,1
	addi $t8,$t8,1
	addi $t1,$t1,-1
	
	j loopm
donem:
	
	
	
	beq $s2,0,p5
	
	
p2:	add $t1,$s3,$0	#number of bytes
	add $t2,$s0,12	#first byte
	lw $s4,0($s0)	#width
	addi $t3,$s4,-1
	add $s5,$t2,$t3	#next line change
loop2:	beq $t1,0,end2
	lb $t3,($t2)
	slti $t4,$t3,10
	beq $t4,1,one
	slti $t4,$t3,100
	beq $t4,1,two
	
three:	div $t5,$t3,100
	addi $t6,$t5,48
	sb $t6,($t8)
	addi $t8,$t8,1
	mul $t5,$t5,100
	sub $t3,$t3,$t5
	
two:	div $t5,$t3,10
	addi $t6,$t5,48
	sb $t6,($t8)
	addi $t8,$t8,1
	mul $t5,$t5,10
	sub $t3,$t3,$t5

one:	addi $t6,$t3,48
	sb $t6,($t8)
	addi $t8,$t8,1
	
	
	beq $t2,$s5,ch_line	#check if its time to change lines
	
	addi $t6,$0,32
	sb $t6,($t8)
	add $t8,$t8,1
	j e_of_l

ch_line:addi $t6,$0,10
	sb $t6,($t8)
	addi $t8,$t8,1
	add $s5,$s5,$s4

e_of_l:
	addi $t1,$t1,-1
	addi $t2,$t2,1
	j loop2
	
end2:	sub $t9,$t8,$s7
	j write
	
p5:	add $t1,$s3,$0	#number of bytes
	add $t2,$s0,12	#first byte
loop5:	beq $t1,0,end5
	lb $t3,($t2)
	sb $t3,($t8)
	addi $t2,$t2,1
	addi $t8,$t8,1
	addi $t1,$t1,-1
	j loop5
end5:	sub $t9,$t8,$s7
	
	

write:
		
	li $v0,13	#open file
	move $a0,$s1
	li $a1,1
	syscall
	move $s3,$v0
	
	
	
	
	
	move $a0,$s3
	li $v0,15
	move $a1,$s7	#write file
	move $a2,$t9
	syscall
	
	li $v0,16	#close file
	move $a0,$s3
	syscall
	
	
	
	
	
	
	
	
	
	
write_image.return:
	
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
