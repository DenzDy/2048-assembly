# CS 21 WFR/FWX -- S1 AY 2024-2025

# Denzell Robyn Dy and Jose Miguel Lozada - 11/04/2024

# 2048 Program
.macro get_int_input(%dest)
    li $v0, 5 
    syscall
    move %dest, $v0
.end_macro

.macro get_str_input(%dest, %char_size)
    li $v0, 8 
    la $a0, %dest
    li $a1, %char_size
    syscall
.end_macro

.macro print_str_input(%src)
    li $v0, 4
    la $a0, %src
    syscall
.end_macro


.text
main:
    get_str_input(string_input, 2)
    print_str_input(string_input)
    j end_program
end_program:
    li $v0, 10
    syscall
    
.data
string_input: .space 2