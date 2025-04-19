# author - Dhriti Barnwal, Durbasmriti Saha
.data
arr: .float 0.123, 0.2735, 0.172, 0.3532, 0.1425, 0.5456, 0.214, 0.972
temp: .space 400        # 10 buckets * 10 elements * 4 bytes
indices: .word 0:10     # Count for each bucket
size: .word 8           # Number of elements in arr
buckets: .word 10       # Number of buckets
nl: .asciiz "\n"

.text
main:
    # Initialize pointers and constants
    la $s0, arr         # Base address of input array
    la $s1, temp        # Base address of temp buckets
    la $s2, indices     # Base address of indices
    lw $s3, size        # Number of elements
    lw $s4, buckets     # Number of buckets

    # Initialize bucket counts to zero
    li $t0, 0
init_loop:
    sw $zero, 0($s2)
    addi $s2, $s2, 4
    addi $t0, $t0, 1
    bne $t0, $s4, init_loop

    # Reset indices pointer
    la $s2, indices

    # Phase 1: Scatter elements into buckets
    li $t0, 0          # Element counter

scatter_loop:
    # Load current element
    sll $t1, $t0, 2
    add $t1, $t1, $s0
    lwc1 $f0, 0($t1)   # $f0 = arr[i]

    # Calculate bucket index without mul.s and truncate
    # Alternative method: repeated subtraction

    # Initialize bucket index to 0
    li $t2, 0
    # Create a temporary value of 0.1 (1/10)
    li $t3, 0x3DCCCCCD # Bit pattern for 0.1 in IEEE 754
    mtc1 $t3, $f10
    # Multiply by 10 using repeated addition
    mov.s $f1, $f0     # Copy of original value
    li $t4, 0          # Counter for multiplication

multiply_loop:
    # Add original value 10 times (equivalent to multiplying by 10)
    add.s $f1, $f1, $f0
    addi $t4, $t4, 1
    bne $t4, 9, multiply_loop

    # Now find integer part by repeated subtraction
    li $t5, 0          # Will hold the integer part
    li.s $f2, 1.0      # Our subtraction value

find_integer_part:
    c.lt.s $f1, $f2
    bc1t integer_found
    sub.s $f1, $f1, $f2
    addi $t5, $t5, 1
    j find_integer_part

integer_found:
    move $t2, $t5      # $t2 now contains bucket index

    # Ensure index is within bounds (0-9)
    blt $t2, 0, clamp_low
    bge $t2, 10, clamp_high
    j store_element

clamp_low:
    li $t2, 0
    j store_element

clamp_high:
    li $t2, 9

store_element:
    # Calculate bucket address: temp + (index * 40)
    li $t6, 40
    mult $t2, $t6
    mflo $t3
    add $t3, $t3, $s1

    # Get current position in bucket
    sll $t4, $t2, 2
    add $t4, $t4, $s2
    lw $t5, 0($t4)     # Current count

    # Store element in bucket
    sll $t6, $t5, 2
    add $t6, $t6, $t3
    swc1 $f0, 0($t6)

    # Increment bucket count
    addi $t5, $t5, 1
    sw $t5, 0($t4)

    # Next element
    addi $t0, $t0, 1
    bne $t0, $s3, scatter_loop

    # Phase 2: Sort each bucket
    li $t0, 0          # Bucket counter

sort_loop:
    # Set up for insertion sort
    li $t6, 40
    mult $t0, $t6
    mflo $t1
    add $t1, $t1, $s1  # Current bucket address

    sll $t2, $t0, 2
    add $t2, $t2, $s2
    lw $s7, 0($t2)     # Number of elements in bucket

    # Call insertion sort
    move $a0, $t1      # Bucket address
    move $a1, $s7      # Number of elements
    jal insertion_sort

    # Next bucket
    addi $t0, $t0, 1
    bne $t0, $s4, sort_loop

    # Phase 3: Gather sorted elements back into original array
    li $t0, 0          # Bucket counter
    li $t1, 0          # Destination index

gather_loop:
    # Get current bucket
    li $t6, 40
    mult $t0, $t6
    mflo $t2
    add $t2, $t2, $s1

    # Get count for this bucket
    sll $t3, $t0, 2
    add $t3, $t3, $s2
    lw $t4, 0($t3)

    li $t5, 0          # Element counter

copy_loop:
    beq $t5, $t4, next_bucket

    # Copy element
    sll $t6, $t5, 2
    add $t6, $t6, $t2
    lwc1 $f0, 0($t6)

    sll $t7, $t1, 2
    add $t7, $t7, $s0
    swc1 $f0, 0($t7)

    # Increment counters
    addi $t5, $t5, 1
    addi $t1, $t1, 1
    j copy_loop

next_bucket:
    addi $t0, $t0, 1
    bne $t0, $s4, gather_loop

    # Print sorted array
    jal print_array

    # Exit
    li $v0, 10
    syscall

# Insertion Sort Subroutine
insertion_sort:
    # $a0 = array address
    # $a1 = number of elements
    move $s5, $a0      # Save array address
    move $s6, $a1      # Save element count

    li $t3, 1          # i = 1

insertion_loop:
    bge $t3, $s6, insertion_end

    # Load key
    sll $t4, $t3, 2
    add $t4, $t4, $s5
    lwc1 $f1, 0($t4)   # key = arr[i]

    # j = i - 1
    addi $t5, $t3, -1

inner_loop:
    blt $t5, 0, inner_end

    # Load arr[j]
    sll $t6, $t5, 2
    add $t6, $t6, $s5
    lwc1 $f0, 0($t6)

    # Compare arr[j] and key
    c.lt.s $f0, $f1
    bc1t inner_end

    # arr[j+1] = arr[j]
    addi $t7, $t6, 4
    swc1 $f0, 0($t7)

    # j--
    addi $t5, $t5, -1
    j inner_loop

inner_end:
    # arr[j+1] = key
    addi $t8, $t5, 1
    sll $t8, $t8, 2
    add $t8, $t8, $s5
    swc1 $f1, 0($t8)

    # i++
    addi $t3, $t3, 1
    j insertion_loop

insertion_end:
    jr $ra

# Print Array Subroutine
print_array:
    li $t0, 0          # Counter
    lw $t1, size       # Number of elements

print_loop:
    bge $t0, $t1, print_end

    # Load and print element
    sll $t2, $t0, 2
    add $t2, $t2, $s0
    lwc1 $f12, 0($t2)
    li $v0, 2
    syscall

    # Print newline
    la $a0, nl
    li $v0, 4
    syscall

    # Next element
    addi $t0, $t0, 1
    j print_loop

print_end:
    jr $ra
