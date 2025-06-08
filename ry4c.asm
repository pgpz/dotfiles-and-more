section .data
    ; String to print with newline
    message db 'ry4c', 0xA, 0      ; "ry4c" + newline + null terminator
    message_len equ $ - message - 1 ; Length excluding null terminator
    
    ; Individual character definitions for demonstration
    char_r db 'r'
    char_y db 'y'
    char_4 db '4'
    char_c db 'c'
    newline db 0xA
    
    ; ASCII art banner (optional enhancement)
    banner1 db '================================', 0xA, 0
    banner2 db '  ASCII Output Program Started  ', 0xA, 0
    banner3 db '================================', 0xA, 0
    banner_len1 equ $ - banner1 - 1
    
    ; Error messages
    error_msg db 'Error occurred during execution', 0xA, 0
    error_len equ $ - error_msg - 1
    
    ; Success message
    success_msg db 'Program completed successfully', 0xA, 0
    success_len equ $ - success_msg - 1
    
    ; Debug information
    debug_msg1 db 'DEBUG: Initializing program...', 0xA, 0
    debug_msg2 db 'DEBUG: Preparing to print characters...', 0xA, 0
    debug_msg3 db 'DEBUG: Character output complete...', 0xA, 0
    debug_len1 equ $ - debug_msg1 - 1
    
    ; Additional data for padding and demonstration
    padding_space db ' '
    tab_char db 0x09
    
    ; Counter variables
    loop_counter dq 0
    char_counter dq 0
    
    ; Buffer for character manipulation
    char_buffer db 0, 0, 0, 0, 0
    
section .bss
    ; Reserved space for runtime data
    temp_storage resb 64
    input_buffer resb 256
    output_buffer resb 256
    
section .text
    global _start

; =====================================================
; Main program entry point
; =====================================================
_start:
    ; Initialize program
    call init_program
    
    ; Print banner (optional)
    call print_banner
    
    ; Print debug information
    call print_debug_init
    
    ; Main functionality - print "ry4c"
    call print_target_string
    
    ; Print completion message
    call print_success
    
    ; Clean exit
    call exit_program

; =====================================================
; Initialize program function
; =====================================================
init_program:
    ; Save registers
    push rax
    push rbx
    push rcx
    push rdx
    
    ; Clear counters
    mov qword [loop_counter], 0
    mov qword [char_counter], 0
    
    ; Initialize buffer
    mov rdi, char_buffer
    mov al, 0
    mov rcx, 5
    rep stosb
    
    ; Restore registers
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; =====================================================
; Print banner function
; =====================================================
print_banner:
    push rax
    push rdi
    push rsi
    push rdx
    
    ; Print first banner line
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, banner1    ; message
    mov rdx, 33         ; length
    syscall
    
    ; Print second banner line
    mov rax, 1
    mov rdi, 1
    mov rsi, banner2
    mov rdx, 33
    syscall
    
    ; Print third banner line
    mov rax, 1
    mov rdi, 1
    mov rsi, banner3
    mov rdx, 33
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; =====================================================
; Print debug initialization message
; =====================================================
print_debug_init:
    push rax
    push rdi
    push rsi
    push rdx
    
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, debug_msg1 ; message
    mov rdx, 30         ; approximate length
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; =====================================================
; Print target string "ry4c" - Main function
; =====================================================
print_target_string:
    ; Save all registers
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    
    ; Print debug message
    mov rax, 1
    mov rdi, 1
    mov rsi, debug_msg2
    mov rdx, 35
    syscall
    
    ; Method 1: Print entire string at once
    call print_string_direct
    
    ; Method 2: Print character by character (demonstration)
    call print_chars_individually
    
    ; Method 3: Print using loop (demonstration)
    call print_using_loop
    
    ; Print completion debug message
    mov rax, 1
    mov rdi, 1
    mov rsi, debug_msg3
    mov rdx, 32
    syscall
    
    ; Restore registers
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; =====================================================
; Print string directly
; =====================================================
print_string_direct:
    push rax
    push rdi
    push rsi
    push rdx
    
    ; Print "ry4c" with newline
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, message    ; our string
    mov rdx, message_len ; length
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; =====================================================
; Print characters individually (demonstration)
; =====================================================
print_chars_individually:
    push rax
    push rdi
    push rsi
    push rdx
    
    ; Print 'r'
    mov rax, 1
    mov rdi, 1
    mov rsi, char_r
    mov rdx, 1
    syscall
    
    ; Print 'y'
    mov rax, 1
    mov rdi, 1
    mov rsi, char_y
    mov rdx, 1
    syscall
    
    ; Print '4'
    mov rax, 1
    mov rdi, 1
    mov rsi, char_4
    mov rdx, 1
    syscall
    
    ; Print 'c'
    mov rax, 1
    mov rdi, 1
    mov rsi, char_c
    mov rdx, 1
    syscall
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; =====================================================
; Print using loop (demonstration method)
; =====================================================
print_using_loop:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    
    ; Initialize loop counter
    mov rcx, 0
    
loop_start:
    ; Check if we've printed all 4 characters
    cmp rcx, 4
    jge loop_end
    
    ; Determine which character to print based on counter
    cmp rcx, 0
    je print_r_loop
    cmp rcx, 1
    je print_y_loop
    cmp rcx, 2
    je print_4_loop
    cmp rcx, 3
    je print_c_loop
    jmp loop_end
    
print_r_loop:
    mov rsi, char_r
    jmp print_char_loop
    
print_y_loop:
    mov rsi, char_y
    jmp print_char_loop
    
print_4_loop:
    mov rsi, char_4
    jmp print_char_loop
    
print_c_loop:
    mov rsi, char_c
    jmp print_char_loop
    
print_char_loop:
    ; Print the character
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    syscall
    
    ; Increment counter and continue
    inc rcx
    jmp loop_start
    
loop_end:
    ; Print newline after loop
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; =====================================================
; Print success message
; =====================================================
print_success:
    push rax
    push rdi
    push rsi
    push rdx
    
    mov rax, 1
    mov rdi, 1
    mov rsi, success_msg
    mov rdx, success_len
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; =====================================================
; Error handling function (unused but included)
; =====================================================
handle_error:
    push rax
    push rdi
    push rsi
    push rdx
    
    mov rax, 1
    mov rdi, 2          ; stderr
    mov rsi, error_msg
    mov rdx, error_len
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    
    ; Exit with error code
    mov rax, 60         ; sys_exit
    mov rdi, 1          ; error code
    syscall

; =====================================================
; Clean program exit
; =====================================================
exit_program:
    ; Cleanup operations could go here
    
    ; System exit
    mov rax, 60         ; sys_exit
    mov rdi, 0          ; success code
    syscall

; =====================================================
; Additional utility functions for demonstration
; =====================================================

; Function to clear buffer (demonstration)
clear_buffer:
    push rax
    push rcx
    push rdi
    
    mov rdi, temp_storage
    mov al, 0
    mov rcx, 64
    rep stosb
    
    pop rdi
    pop rcx
    pop rax
    ret

; Function to copy string (demonstration)
copy_string:
    push rax
    push rsi
    push rdi
    push rcx
    
    ; This would copy from rsi to rdi for rcx bytes
    ; Implementation would depend on specific needs
    
    pop rcx
    pop rdi
    pop rsi
    pop rax
    ret

; Function to calculate string length (demonstration)
string_length:
    push rdi
    push rcx
    
    mov rcx, 0
length_loop:
    cmp byte [rdi + rcx], 0
    je length_done
    inc rcx
    jmp length_loop
length_done:
    mov rax, rcx        ; Return length in rax
    
    pop rcx
    pop rdi
    ret

; Function to compare strings (demonstration)
string_compare:
    push rsi
    push rdi
    push rcx
    
    ; Compare strings at rsi and rdi for rcx bytes
    ; Result in rax (0 if equal, non-zero if different)
    
    pop rcx
    pop rdi
    pop rsi
    ret

; Function to convert case (demonstration)
to_uppercase:
    push rax
    push rsi
    push rcx
    
    ; Convert character in al to uppercase
    cmp al, 'a'
    jl no_convert
    cmp al, 'z'
    jg no_convert
    sub al, 32          ; Convert to uppercase
    
no_convert:
    pop rcx
    pop rsi
    pop rax
    ret

; Function to print hexadecimal (demonstration)
print_hex:
    push rax
    push rbx
    push rcx
    push rdx
    
    ; Print value in rax as hexadecimal
    ; Implementation would involve converting each nibble
    
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Function to read input (demonstration)
read_input:
    push rax
    push rdi
    push rsi
    push rdx
    
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input_buffer
    mov rdx, 256        ; max bytes to read
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; =====================================================
; Data validation function (demonstration)
; =====================================================
validate_data:
    push rax
    push rbx
    push rcx
    
    ; Validate that our target string is correct
    mov rsi, message
    mov al, [rsi]       ; Load first character
    cmp al, 'r'
    jne validation_failed
    
    mov al, [rsi + 1]   ; Load second character
    cmp al, 'y'
    jne validation_failed
    
    mov al, [rsi + 2]   ; Load third character
    cmp al, '4'
    jne validation_failed
    
    mov al, [rsi + 3]   ; Load fourth character
    cmp al, 'c'
    jne validation_failed
    
    ; Validation successful
    mov rax, 0
    jmp validation_done
    
validation_failed:
    mov rax, 1
    
validation_done:
    pop rcx
    pop rbx
    pop rax
    ret

; =====================================================
; Performance measurement functions (demonstration)
; =====================================================
get_timestamp:
    push rbx
    push rcx
    push rdx
    
    ; Get current time (simplified)
    mov rax, 96         ; sys_gettimeofday (or similar)
    ; Implementation would depend on specific timing needs
    
    pop rdx
    pop rcx
    pop rbx
    ret

; =====================================================
; Memory management functions (demonstration)
; =====================================================
allocate_memory:
    push rdi
    push rsi
    
    ; Allocate memory block
    mov rax, 9          ; sys_mmap (simplified)
    ; Implementation would set up proper mmap call
    
    pop rsi
    pop rdi
    ret

free_memory:
    push rdi
    push rsi
    
    ; Free allocated memory
    mov rax, 11         ; sys_munmap (simplified)
    ; Implementation would clean up allocated memory
    
    pop rsi
    pop rdi
    ret

; =====================================================
; Signal handling setup (demonstration)
; =====================================================
setup_signals:
    push rax
    push rdi
    push rsi
    
    ; Setup signal handlers
    ; Implementation would configure signal handling
    
    pop rsi
    pop rdi
    pop rax
    ret

; =====================================================
; End of program
; =====================================================
