

global inverse_permutation            ; inverse_permutation is a function that checks whether a given array
                                      ; contains a permutation and if so, inverts it. It requires two arguments:
                                      ; First: n - size of array. Must be in range of size_t (C language).
                                      ; Second: p - pointer to the array. Must be a correct pointer that points to
                                      ; a n-element array. Each element must be in range of an int (C language). 

inverse_permutation:
                                      ; rdi - value n passed as first argument
                                      ; rsi - pointer to the arrray p passed as second argument
         test    rdi, rdi             ; Checking if n == 0.
         jz      .false               ; If so, we return false.
         mov     rax, 0x80000000      ; Moving value (1<<31) to rax.
         cmp     rdi, rax             ; Checking if n > (1<<31).
         jg      .false               ; If so, we return false.

         xor     rcx, rcx             ; We will be using rcx as loop iterator so we zero it.
         dec     edi                  ; n-1 value will be more useful than n later.

         mov     r8d, 0x1              ; We want to have value ~(1<<31) in r8d. So at first we set it to 1.
         shl     r8d, 0x1f             ; Then we shift that one left 31 times.
         mov     r9d, r8d              ; Value (1<<31) also might be handy so we copy it to r9d.
         not     r8d                   ; Then we just simply negate r9d and now it's set to ~(1<<31).

.loop_correct:                        ; .loop_correct label represents a loop that checks if array
                                      ; p holds a proper permutation. ecx will be out iterator.
         mov     eax, [rsi+rcx*4]     ; We assign eax to element of p at index ecx.
         and     eax, r8d             ; We clear sign bit of eax.
         cmp     eax, edi             ; Checking if eax > n-1.
         jg      .reverse_while       ; If so, we jump to .reverse_while label.
         mov     edx, [rsi+rax*4]     ; We assign edx to p[eax].
         mov     r10d, edx            ; Copying edx into r10d.
         xor     r10d, r8d            ; Performing xor on r10d and ~(1<<31).
         cmp     r10d, 0x0            ; Checking if r10d is less than zero.
         jl      .reverse_while       ; If so, array p is not a permutation and we jump to .reverse_while label.
         or      [rsi+rax*4], r9d     ; Performing or on p[eax] and (1<<31).
         inc     ecx                  ; Increasing our iterator - ecx by one.
         cmp     edi, ecx             ; Checking if ecx < n.
         jge     .loop_correct        ; If so, we jump to beginning of our loop
         xor     rdx, rdx             ; If not, we make rdx zero.
         jmp     .invert_while        ; Then we jump to .invert_while label.

.reverse_while:                       ; If p does not contain a permutation we have to reverse changes we've made. 
                                      ; .reverse_while label performs just that.
         test    ecx, ecx             ; Checking if ecx == 0.
         jz      .false               ; If so, we just return false.
         dec     ecx                  ; If not, we decerase ecx by one.
         mov     r10d, [rsi+rcx*4]    ; Assigning r10d to p[ecx].
         and     r10d, r8d            ; Performing and on p[ecx] and ~(1<<31).
         and     [rsi+r10*4], r8d     ; Performing and on p[r10d] and ~(1<<31).
         jmp     .reverse_while       ; Jumping to the beginning of the .reverse_while loop.

.false:                               ; .false label is used to return value representing false.
         xor     eax, eax             ; rax is now equal to zero.
         ret

.invert_while:                        ; .invert_while label represents while loop that inverts the permutation. 
                                      ; edx - current index, eax - value to put into p array.
         mov     r9d, [rsi+rdx*4]     ; Copying p[edx] into r9d register.
         test    r9d, r9d             ; Checking if p[edx] < 0.
         cmovs   eax, r9d             ; If so, eax = p[edx].
         test    eax, eax             ; Checking if p[edx] < 0.
         js      .nested_while        ; If so, we jump to another while loop "nested" inside our current while loop.

.return_to_outer_while:               ; .return_to_outer_while label represents code that belongs to invert_while but is after nested while loop.
         inc     edx                  ; Increasing edx register by one.
         cmp     edi, edx             ; Checking if edx = n-1.
         jge     .invert_while        ; If so, we jump into the beginning of loop.
         jmp     .true                ; If not, we return true.

.nested_while:                        ; .nested_while label represents while loop nested inside invert_while loop.
                                      ; r9d - helper variable.
         test    eax, eax             ; Checking if eax >= 0.
         jns     .return_to_outer_while ; If so, we jump over nested while loop.
         and     eax, r8d             ; Executing arithmetic operation eax := eax & ~(1<<31).
         xor     r9, r9               ; Assigning r9 to 0.
         mov     r9d, [rsi+rax*4]     ; Assigning r9d to p[eax].
         test    r9d, r9d             ; Checking if r9d >= 0.
         jns     .return_to_outer_while ; If so, we jump to the rest of the code of outer loop.
         mov     [rsi+rax*4], edx     ; Assigning p[eax] to edx.
         mov     edx, eax             ; Assigning edx to eax.
         mov     eax, r9d             ; Assigning eax = r9d.
         jmp     .nested_while        ; Jumping to the beginning of nested loop.

.true:                                ; .true label is used to return value representing true.
  lea    rax, [0x1]                   ; Assigning rax to 1;
  ret                                 
         
