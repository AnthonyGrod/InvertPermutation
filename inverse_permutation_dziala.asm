global inverse_permutation

; rdi - value n passed as first argument
; rsi - pointer to the arrray p passed as second argument

inverse_permutation:
         test    rdi, rdi             ; Checking if n==0.
         jz      .false               ; If so, we return false.
         mov     rax, 0x80000000      ; Moving value (1<<31) to rax.
         cmp     rdi, rax             ; Checking if n > (1<<31).
         jg      .false               ; If so, we return false.

         xor     rcx, rcx             ; We will be using rcx as loop iterator so we zero it.
         dec     edi                  ; n-1 value will be more useful than n later.

.loop_range:                          ; Etykieta pętli, w której będziemy sprawdzać, czy wszystkie elementy tablicy są w zakresie [0, n) JAK.rdi+0x20*rcx
         mov     edx, [rsi+rcx*4]     ; ecx będzie naszym iteratorem.
         cmp     edx, 0x0             ; Sprawdzamy, czy element nie jest mniejszy od zera.
         jl      .false               ; Jeśli tak, to zwracamy false.
         cmp     edx, edi             ; Sprawdzamy, czy element jest większy od n-1.
         jg      .false               ; Jeśli tak, to zwracamy false.
         inc     ecx                  ; Przechodzimy do następnego pola tablicy p
         cmp     edi, ecx             ; Patrzymy, czy nasz iterator jest większy od n-1
         jge     .loop_range          ; Jeśli tak to wracamy na początek pętli

         xor     ecx, ecx             ; Jeśli jednak iterator był równy n, to zerujemy rcx do następnej pętli
         mov     r8, 0x1              ; Do rejestru r8 w następnych trzech linijkach
         shl     r8, 0x1f             ; wpisujemy wartość ~(1<<31). Ta liczba pomoże
         mov     r9, r8               ; w flipowaniu bitu znaku w intach.
         not     r8                   ; W r9 natomiast będziemy mieć (1<<31)

.loop_unique:                         ; Tu będziemy sprawdzać, czy elementy są unikalne
         mov     eax, [rsi+rcx*4]     ; Do eax wpisujemy kolejny element tablicy p. // j = p[i]
         and     rax, r8              ; Zmieniamy bit znaku w rax (o ile tam był) // j = p[i] & ~(1<<31)
         mov     edx, [rsi+rax*4]     ; edx = p[j]
         mov     r10d, edx            ; Tworzymy kopię edx w r10, czyli r10=p[j].
         xor     r10d, r8d            ; r10d = p[j] ^ ~(1<<31)
         cmp     r10d, 0x0             ; Sprawdzamy, czy edx jest mniejsze od 0
         jl      .reverse_while       ; Jeśli tak, to permutacja jest niepoprawna i musimy cofnąć zmiany
         or      [rsi+rax*4], r9d     ; p[j] |= 1<<31
         inc     ecx
         cmp     edi, ecx
         jge     .loop_unique
         xor     rdx, rdx
         jmp     .invert_while

.reverse_while:                       ; Jeśli okaże się, że p nie zawiera unikalnych liczb, to trzeba będzie przywrócić zmiany
         test    ecx, ecx             ; Jeśli tu skoczyliśmy, to i=ecx, j=eax
         jz      .false               ; Jeśli rejestr ecx (czyli zmienna i) == 0 to zwracamy false
         dec     ecx
         mov     r10d, [rsi+rcx*4]    ; j = r10d = p[i]
         and     r10d, r8d            ; j = r10d & ~(1<<31) = p[i] & ~(1<<31)
         and     [rsi+r10*4], r8d      ; p[j] &= ~(1<<31)
         jmp     .reverse_while          

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
         
