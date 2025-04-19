# author - Dhriti Barnwal, Durbasmriti Saha

.data
numbers:    .word 20, 30, 10, 40, 50, 60, 30, 25, 10, 5
length:     .word 10

.text
.globl main

main:
    la   $t0, numbers      # $t0 = base address of numbers
    lw   $t1, length       # $t1 = length of array

    addi $t2, $zero, 1     # $t2 = firstUnsortedIndex = 1

outer_loop:
    bge  $t2, $t1, end     # if firstUnsortedIndex >= length, end loop

    # elementToInsert = numbers[firstUnsortedIndex]
    sll  $t3, $t2, 2       # $t3 = firstUnsortedIndex * 4 (word offset)
    add  $t4, $t0, $t3     # $t4 = &numbers[firstUnsortedIndex]
    lw   $t5, 0($t4)       # $t5 = elementToInsert

    addi $t6, $t2, -1      # $t6 = testIndex = firstUnsortedIndex - 1

inner_loop:
    bltz $t6, insert       # if testIndex < 0, exit inner loop

    sll  $t7, $t6, 2       # $t7 = testIndex * 4
    add  $t8, $t0, $t7     # $t8 = &numbers[testIndex]
    lw   $t9, 0($t8)       # $t9 = numbers[testIndex]

    ble  $t9, $t5, insert  # if numbers[testIndex] <= elementToInsert, exit inner loop

    # numbers[testIndex + 1] = numbers[testIndex]
    sw   $t9, 4($t8)

    addi $t6, $t6, -1      # testIndex--
    j    inner_loop

insert:
    sll  $t7, $t6, 2       # $t7 = testIndex * 4
    add  $t8, $t0, $t7     # $t8 = &numbers[testIndex]
    sw   $t5, 4($t8)       # numbers[testIndex + 1] = elementToInsert

    addi $t2, $t2, 1       # firstUnsortedIndex++
    j    outer_loop

end:
    # (Optional) Add code here to print the sorted array if desired
    li   $v0, 10           # exit
    syscall
