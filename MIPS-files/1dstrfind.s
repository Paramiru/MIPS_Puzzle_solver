
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
outmsg:			.asciiz  "Program finished"

        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dictionary_idx:		.space 4004	# Starting index of each word in dictionary

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!

		li	$t0, 0				# idx = 0;
		li	$t1, 0				# start_idx = 0;
		li	$t2, 0				# dict_idx = 0;

		

store_st_index:					# Storing the starting index 
						# of each word in the dictionary
		lb 	$a1, dictionary($t0)	# c_input = dictionary[idx];
		
		beq	$a1, $0, strfind_setup	# if (c_input == '\0') {break;}
		addi $v0, $0, 10
		beq	$a1, $v0, add_to_array	# if (c_input == '\n') do...
		add	$t0, $t0, 1		# idx += 1;
		j 	store_st_index
		

add_to_array:
		
		sw	$t1, dictionary_idx($t2) # dictionary_idx[dict_idx] = start_idx
		add	$t2, $t2, 4		 # dict_idx ++ -> Add 4 since int array
		
#		li	$v0, 1                   #This prints the number
#		move	$a0, $t1                 #followed by a newline
#		syscall                          #just to check
#		
#		li	$v0, 11                  # that the code is 
#		addi	$a0, $zero, 10           # actually working
#		syscall
		
		add	$t1, $t0, 1		 # start_idx = idx + 1;
		add	$t0, $t0, 1		 # idx += 1;
		
		j	store_st_index
		 
strfind_setup:

		srl	$t2, $t2, 2		# Divide by 4 since we were adding 4 each 
						# time bc dictionary_idx is an int array.
		add	$s0, $t2, $zero		# $s0 is length of dictionary: dict_num_words = dict_idx;
		
		li	$t0, 0			# idx = 0;
		li	$t1, 0			# grid_idx = 0;

		
		move	$t6, $s0		# This stores the length of the array in $t6
						# It is 12 for the given .txt file
		sll	$t6, $t6, 2		# Multiply by 4 bc we're adding 4 each time to the loop
		
strfind:
	# Use load byte because grid is a char array	
	lb	$a1, grid($t1)			# Load grid[grid_idx]
	beq	$a1, $0, check_if_print_minus_one	# if grid[grid_idx] == \0 print -1
	
	beq	$t0, $t6, update_grid_idx	# if idx = dict_num_words -> for loop has finished updated:	
	la	$a2, dictionary			# word = dictionary
	lw	$t3, dictionary_idx($t0)	# get the starting int of the word
	
	add	$a2, $a2, $t3			# word = dictionary + dictionary_idx[idx]
	li	$s4, 0				# Store LENGTH of the word!!!!
	
	la	$a3, grid			# string = grid
	add	$a3, $a3, $t1			# string = grid + grid_idx
	
	jal	contain
	
	beq	$v1, 1, print_

	addi	$t0, $t0, 4			# idx++ from the for loop	
	j	strfind
	

contain:	
	lb	$t4, ($a2)			# load char from word
	lb	$t5, ($a3)			# load char from string
	beq	$t4, $t5, followContains	# if they are equal, move to the following char
	addi 	$v0, $0, 10			# newline in ascii is 10
	beq	$t4, $v0, isequal		# if word is equal to newline set v1 to 1 and go to contains
	li	$v1, 0				# if not equal set v1 to zero and go back to
	jr	$ra				# strfind
	
update_grid_idx:
	add	$t1, $t1, 1			# grid_idx++
	li	$t0, 0				# set idx to zero after end of for loop
	j	strfind
	
	
isequal:
	li	$v1, 1				# if equal set v1 to 1
	jr	$ra

followContains:
	addi	$s4, $s4, 1			# stores the length if the words are the same
	addi	$a2, $a2, 1
	addi	$a3, $a3, 1
	j	contain
			
print_:
	li	$v0, 1
	move	$a0, $t1			# print $t1 which is grid_idx
	syscall
	
	li	$v0, 11
	li	$a0, 32
	syscall
	
	move	$s2, $a2
	j	print_word
comeback:	
	li	$v0, 11
	li	$a0, 10
	syscall
	
	addi	$t0, $t0, 4
	
	j	strfind
	
############# MOVE THE ADDRESS OF THE WORD WHICH SHOULD BE NEWLINE TO ANOTHER REGISTER #########
############# SUBTRACT LENGTH OF WORD FROM IT SO THAT WE HAVE THE FIRST CHARACTER ##############
############# AND THEN PRINT_WORD SHOULD WORK NOW!!!!!!!!! I Hope at least it does #############
	
print_word:
	move	$s3, $s2
	
	sub	$s3, $s3, $s4	# get the addrss of the firs char

	lb	$t7, ($s3)
	beq	$t7, $0, comeback
	addi 	$v0, $0, 10
	beq	$t7, $v0, comeback
	li	$v0, 11
	move	$a0, $t7
	syscall
	addi	$s2, $s2, 1
	li	$s5, 1
	j	print_word
		
		

print_minus_one:
	li	$v0, 1
	li	$a0, -1
	syscall
	j	main_end

check_if_print_minus_one:
	beqz	$s5, print_minus_one




#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
