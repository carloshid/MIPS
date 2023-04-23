.data

inputFileName:	.asciiz	"life-input.txt"
outputFileName:	.asciiz "life-output.txt"

array:	.space	10000	#max possible number of cells	(1 byte for each to store character)
array2:	.space 	10000	


.text
main:
	# read the integer n from the standard input
	jal readInt
	# now $v0 contains the number of generations n you should simulate
	
	
	add $s0,$v0,$0	#s0 contains n
	la $s1,inputFileName	#s1 = address of input filename
	
	li $v0,13	#open file
	move $a0,$s1
	li $a1,0
	syscall
	
	move $s2,$v0	#store file descriptor in s2
	
	li $v0,14	#read file
	move $a0,$s2	#file descriptor
	la $s3,array
	move $a1,$s3	#buffer
	la $a2,10100	#100 rows of 100 characters max + 100 new line characters (worst case)
	syscall		
	
	add $t0,$0,$0	#counter
	add $s5,$0,$0	#s5 = width
	add $s6,$0,$0	#s6 = height
	
loop:	add $t1,$s3,$t0	#current address = first address + counter
	lb $t2,($t1)		#load the current character
	beq $t2,0,end_of_array	
	beq $t2,'\n',new_line
	j skip
	
new_line:	addi $s6,$s6,1	#add 1 to height
	beq $s5,0,width		#if we dont yet have the width, set it
	j skip			#otherwise, skip this step
width:	add $s5,$s5,$t0	#width = counter
	
skip:	addi $t0,$t0,1


	j loop
	
	
end_of_array:	add $s4,$t0,$0	#s4 = total number of characters
		sub $s7,$s4,$s6	#s7 = total number of cells (subtract the new line characters)

	li $v0,16	#close file
	move $a0,$s2
	syscall
	
	add $a0,$s0,$0
	jal next_gen
	
	la $s1,outputFileName	#s1 = address of output filename
	li $v0,13	#open file
	move $a0,$s1
	li $a1,1
	syscall
	move $s3,$v0 	#s3 = file descriptor
	
	move $a0,$s3
	li $v0,15
	la $s7,array
	move $a1,$s7	#write file
	move $a2,$s4
	syscall
	
	li $v0,16	#close file
	move $a0,$s3
	syscall
	
	
	li $v0, 10	# exit the program
	syscall



next_gen:	#a0 = number of generations left, will store the next generation in array 2, and once its done, it will copy it back into array and call itself until n = 0
	addi $sp,$sp,-4	#save registers to the stack
	sw $ra,0($sp)
	
	add $t0,$0,$0	#counter
	add $t1,$0,$0	#number of adjacent cells with value '1'
	
	addi $t3,$s5,1	#w + 1
	
gen_loop:	
	beq $t0,$s4,copy_array
	add $t1,$0,$0	#reset adjacent cells
	div $t0,$t3 #  (counter) mod (w + 1) and store in t4
	mfhi $t4
	beq $t4,$s5,nl	
	
	#check top left:
	slt $t2,$t0,$s5	#top row
	beq $t2,1,skip_tl
	beq $t4,0,skip_tl #left column
	
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter - width - 2
	sub $t6,$t6,$s5
	addi $t6,$t6,-2
	lb $t5,($t6)	#top left char
	beq $t5,'0',skip_tl
	addi $t1,$t1,1	#if its 1, add 1 to adjacent cells
	
skip_tl:
	#check top:
	slt $t2,$t0,$s5	#top row
	beq $t2,1,skip_t
	
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter - width - 1
	sub $t6,$t6,$s5
	addi $t6,$t6,-1
	lb $t5,($t6)	#top char
	beq $t5,'0',skip_t
	addi $t1,$t1,1	#if its 1, add 1 to adjacent cells
	
skip_t:
	#check top right:
	slt $t2,$t0,$s5	#top row
	beq $t2,1,skip_tr
	addi $t5,$s5,-1
	beq $t4,$t5,skip_tr #if right column
	
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter - width
	sub $t6,$t6,$s5
	lb $t5,($t6)	#top right char
	beq $t5,'0',skip_tr
	addi $t1,$t1,1	#if its 1, add 1 to adjacent cells

skip_tr:
	#check left:
	beq $t4,0,skip_l #left column
	
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter - 1
	addi $t6,$t6,-1
	lb $t5,($t6)	#left char
	beq $t5,'0',skip_l
	addi $t1,$t1,1	#if its 1, add 1 to adjacent cells
	
skip_l:	
	#check right:
	addi $t5,$s5,-1
	beq $t4,$t5,skip_r #if right column
	
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter + 1
	addi $t6,$t6,1
	lb $t5,($t6)	#right char
	beq $t5,'0',skip_r
	addi $t1,$t1,1	#if its 1, add 1 to adjacent cells
	
skip_r:	
	#check bottom left:
	add $t6,$0,$s4
	sub $t6,$t6,$t0	#t6 = total - counter
	addi $t7,$s5,2	#t7 = w + 2
	slt $t2,$t6,$t7	#if bottom row
	beq $t2,1,skip_bl
	
	beq $t4,0,skip_bl #left column
	
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter + width
	add $t6,$t6,$s5
	lb $t5,($t6)	#bottom left char
	beq $t5,'0',skip_bl
	addi $t1,$t1,1	#if its 1, add 1 to adjacent cells

skip_bl:
	#check bottom:
	add $t6,$0,$s4
	sub $t6,$t6,$t0	#t6 = total - counter
	addi $t7,$s5,2	#t7 = w + 2
	slt $t2,$t6,$t7	#if bottom row
	beq $t2,1,skip_b
	
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter + width + 1
	add $t6,$t6,$s5
	addi $t6,$t6,1
	lb $t5,($t6)	#bottom  char
	beq $t5,'0',skip_b
	addi $t1,$t1,1	#if its 1, add 1 to adjacent cells
	
skip_b:
	#check bottom right:
	add $t6,$0,$s4
	sub $t6,$t6,$t0	#t6 = total - counter
	addi $t7,$s5,2	#t7 = w + 2
	slt $t2,$t6,$t7	#if bottom row
	beq $t2,1,skip_br
	
	addi $t5,$s5,-1
	beq $t4,$t5,skip_br #if right column
	
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter + width + 2
	add $t6,$t6,$s5
	addi $t6,$t6,2
	lb $t5,($t6)	#bottom right char
	beq $t5,'0',skip_br
	addi $t1,$t1,1	#if its 1, add 1 to adjacent cells
	
skip_br:

	#at this point, all adjacent cells are checked, t1 = number of '1' adjacent cells
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter
	lb $t5,($t6)	#current char
	
	beq $t5,'0',dead	#if current char = '0', jump to dead label
	
alive:	slti $t2,$t1,2	#if less than 2 live neighbours or more than 3, die 
	beq $t2,1,die
	slti $t2,$t1,4
	beq $t2,0,die
	j stay
	
die:	addi $t5,$0,'0'	#set to dead
	j stay
	
dead:	beq $t1,3,revive	#if 3 neighbours, revive
	j stay
	
revive:	addi $t5,$0,'1'	#set to alive
	j stay

stay:	
	la $t6,array2
	add $t6,$t6,$t0	#address of array2 + counter
	sb $t5,($t6)	#save the current char to array 2
	j end
	
nl:	la $t6,array
	add $t6,$t6,$t0	#address of array + counter
	lb $t5,($t6)	#current char
	la $t6,array2
	add $t6,$t6,$t0	#address of array2 + counter
	sb $t5,($t6)	#save the current char to array 2

end:	addi $t0,$t0,1	#increase counter by 1
	j gen_loop
	
	
copy_array:
	add $t0,$0,$0
copy_l:
	beq $t0,$s4,finished
	la $t6,array2
	add $t6,$t6,$t0	#address of array2 + counter
	lb $t5,($t6)	#current char
	la $t6,array
	add $t6,$t6,$t0	#address of array + counter
	sb $t5,($t6)	#save the current char to array 2
	addi $t0,$t0,1
	j copy_l
	
	
finished:
	addi $a0,$a0,-1	#set n to n - 1
	beq $a0,0,done
	jal next_gen
	
done:	
	lw $ra,0($sp)
	addi $sp,$sp,4	#restore registers from the stack
	
	jr $ra



########### Helper functions for IO ###########

# read an integer
# int readInt()
readInt:
	li $v0, 5
	syscall
	jr $ra
