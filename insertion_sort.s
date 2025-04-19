# author - Dhriti Barnwal, Durbasmriti Saha

.data
numbers:    .word 20, 36, 12, 46, 50, 69, 30, 44, 10, 5
length:     .word 10

.text
.globl main

main:
    la   $t0, numbers      # $t0 = base address of numbers
    lw   $t1, length       

    addi $t2, $zero, 1     

outer_loop:
    bge  $t2, $t1, end     

    sll  $t3, $t2, 2       
    add  $t4, $t0, $t3     
    lw   $t5, 0($t4)       

    addi $t6, $t2, -1      

inner_loop:
    bltz $t6, insert       

    sll  $t7, $t6, 2       
    add  $t8, $t0, $t7     
    lw   $t9, 0($t8)       

    ble  $t9, $t5, insert  

    sw   $t9, 4($t8)

    addi $t6, $t6, -1      
    j    inner_loop

insert:
    sll  $t7, $t6, 2       
    add  $t8, $t0, $t7     
    sw   $t5, 4($t8)       

    addi $t2, $t2, 1       
    j    outer_loop

end:
    li   $v0, 10           # exit
    syscall
