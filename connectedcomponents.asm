###############################connected components######################
.data
.text
.globl connected_components
########################## connected components ##################
connected_components:
	# $a0 -> image struct
	############return###########
	# $v0 -> image struct with labelled connected components
	# $v1 -> number of connected components (equivalent to number of unique labels)
	
	
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
        addi $t2,$0,0	#current value
        
        add $s5,$0,$0	#current highest label
        
        add $a0,$0,400
        
        addi $sp,$sp,-4	#create buffer for equivalence groups (will support 20 bytes per connected component up to 20 of them)
	sw $ra,0($sp)	
	jal malloc
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	move $s6,$v0	#address of array for equivalence groups
        
        
loop:	addi $t3,$t2,12		#t3 = pointer to current value
	add $t3,$t3,$s0
	lb $t6,($t3)	#t6 = current value
	beq $t6,0,next
	
	#check top
	slt $t4,$t2,$s1		#t4 = 1 if on top edge
	beq $t4,1,skip_t
	
	sub $t4,$t2,$s1
	addi $t5,$t4,12		#t5 = pointer to value above
	add $t5,$t5,$s0
	lb $t4,($t5)		#t4 = value above
	j left
	
skip_t: add $t4,$0,$0	


left:	#check left
	div $t2,$s1	#divide by w, if remainder is 0, we are on the left edge
	mfhi $t5
	beq $t5,0,skip_l
	
	addi $t7,$t2,11
	add $t7,$t7,$s0	#t7 = pointer to left value
	lb $t5,($t7)	#t5 = left value
	j check		
	
skip_l:	add $t5,$t0,$0

check:	add $t7,$t4,$t5	#add top and left (0 if both are 0)
	beq $t7,0,new_label
	beq $t4,0,left_label
	beq $t5,0,top_label
	beq $t4,$t5,top_label
	
	#top equivalence group
	addi $t7,$t4,-1
	mul $t7,$t7,20
	add $t7,$t7,$s6
top_loop:
	lb $t0,($t7)	#check if we are at the end of the current group and if so jump to add_t label
	beq $t0,0,add_t
	addi $t7,$t7,1
	j top_loop	
	
add_t:	sb $t5,($t7)	#save left label in top equivalence group
	addi $t7,$t7,1
	sb $0,($t7)	#new end
	
	#left equivalence group
	addi $t7,$t5,-1
	mul $t7,$t7,20
	add $t7,$t7,$s6
left_loop:
	lb $t0,($t7)	#check if we are at the end of the current group and if so jump to add_l label
	beq $t0,0,add_l
	addi $t7,$t7,1
	j left_loop
	
add_l:	sb $t4,($t7)	#save top label in left equivalence group
	addi $t7,$t7,1
	sb $0,($t7)	#new end
	
	slt $t7,$t4,$t5	#if top < left, use top label, otherwise use left label
	beq $t7,1,top_label
	j left_label
	
	
left_label:
	sb $t5,($t3)	#save left label in the current value
	j next

top_label:
	sb $t4,($t3)	#save top label in the current value
	j next
	


new_label:	
	addi $s5,$s5,1	#set the current value to 1 more than the highest label
	sb $s5,($t3)
	addi $t4,$s5,-1	#t4 = pointer to the start of the current label in the equivalence groups array corresponding
	mul $t4,$t4,20	
	add $t4,$t4,$s6
	sb $s5,($t4)	#save the current label as the first one in the group
	add $t4,$t4,1	#current end of the group
	sb $s0,($t4)	#use value 0 as delimiter	
	

next:	addi $t2,$t2,1
	beq $t2,$s4,end
	j loop

end:	add $t2,$0,0

loop2:	addi $t3,$t2,12		#t3 = pointer to current value
	add $t3,$t3,$s0
	lb $t6,($t3)	#t6 = current value
	beq $t6,0,next2
	
	addi $t4,$t6,-1	
	mul $t4,$t4,20
	add $t4,$t4,$s6	#t4 = pointer to the start of the equivalence group
	
loop3:	addi $t4,$t4,1	#next element in the group
	
	lb $t5,($t4)
	beq $t5,0,end3
	slt $t7,$t5,$t6
	beq $t7,1,smaller
	j bigger

smaller:move $t6,$t5	#jump here if next label checked is lower than current
	sb $t6,($t3)
	
bigger:	j loop3
	
	
end3:		
	

next2:	addi $t2,$t2,1
	beq $t2,$s4,end2
	j loop2


end2:	sw $s5,8($s0)
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

connected_components.return:
	jr $ra
