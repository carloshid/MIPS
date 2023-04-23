.data

string1:	.asciiz "Step "
string2:	.asciiz ": move disk "
string3:	.asciiz " from "
string4:	.asciiz " to "
string5:	.asciiz "\n"

counter:	.word	1

.text
main:	
        # read the integer n from the standard input
	jal readInt
	# now $v0 contains the number of disk n


	add $s0,$v0,$0	#s0 will contain the original n
	add $s1,$v0,$0	#s1 contains n
	addi $s2,$0,'A'	#s2 : initial source
	addi $s3,$0,'C'	#s3 : initial target
	addi $s4,$0,'B'	#s4 : initial aux

	jal move_disks		#move all disks from source to target


	
	li $v0, 10	# exit the program
	syscall





move_disks:	#beq $s1,$s0,done		#at this point s1 = n , s2 = source , s3 = target, s4 = aux

	#save registers to the stack
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
	
	beq $s1,1,single
	j multiple
	
single:		la $a0,string1	#Step
		jal printStr
		lw $t2,counter
		add $a0,$t2,$0	#Step
		jal printInt
		addi $t2,$t2,1	#increase counter
		sw $t2,counter		
		la $a0,string2	#:move disk
		jal printStr
		add $a0,$s1,$0	#current disk number
		jal printInt
		la $a0,string3	#from
		jal printStr
		add $a0,$s2,$0	#source
		jal printChar
		la $a0,string4	#to
		jal printStr
		add $a0,$s3,$0	#target
		jal printChar
		la $a0,string5	#\n
		jal printStr
		
		j end		#end of current move
		
	
multiple:	#load the registers for the first smaller move
		addi $s1,$s1,-1	# n = n - 1
		add $t1,$s3,$0	#source = source, target = aux, aux = target
		add $s3,$s4,$0
		add $s4,$t1,$0
		
		jal move_disks
		
		addi $s1,$s1,1	#change back to original n, s, t, a
		add $t1,$s3,$0	
		add $s3,$s4,$0
		add $s4,$t1,$0
		
		#move nth disk from source to target
		la $a0,string1	#Step
		jal printStr
		lw $t2,counter
		add $a0,$t2,$0	#Step
		jal printInt
		addi $t2,$t2,1	#increase counter
		sw $t2,counter		
		la $a0,string2	#:move disk
		jal printStr
		add $a0,$s1,$0	#current disk number
		jal printInt
		la $a0,string3	#from
		jal printStr
		add $a0,$s2,$0	#source
		jal printChar
		la $a0,string4	#to
		jal printStr
		add $a0,$s3,$0	#target
		jal printChar
		la $a0,string5	#\n
		jal printStr
		
		#load the registers for the second smaller move
		addi $s1,$s1,-1	# n = n - 1
		add $t1,$s4,$0	#source = aux, target = target, aux = source
		add $s4,$s2,$0
		add $s2,$t1,$0
		
		jal move_disks
		
end:	

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

	
	
	







########### Helper functions for IO ###########

# read an integer
# int readInt()
readInt:
	li $v0, 5
	syscall
	jr $ra
	
# print an integer
# printInt(int n)
printInt:
	li $v0, 1
	syscall
	jr $ra

# print a character
# printChar(char c)
printChar:
	li $v0, 11
	syscall
	jr $ra
	
# print a null-ended string
# printStr(char *s)
printStr:
	li $v0, 4
	syscall
	jr $ra
	
	
	
done:
