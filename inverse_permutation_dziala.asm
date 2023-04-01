global inverse_permutation

; rdi - wartość n (64 bity)
; rsi - wartość wskaźnika na początek tablicy p (64 bity)

inverse_permutation:
         test    rdi, rdi             ; Sprawdzamy, czy n jest zerem.
         jz      .false               ; Jeśli tak, to zwracamy false.
         mov     rax, 0x80000000      ; Pomocniczo kopiujemy MAXINT + 1 do rax
         cmp     rdi, rax             ; Sprawdzamy, czy n > MAXINT + 1. Jeśli
         jg      .false               ; tak, to także zwracamy false.

         xor     rcx, rcx             ; rcx będzie naszym iteratorem pętli, więc najpierw go zerujemy 
         dec     edi                  ; Łatwiej nam będzie pracować na wartości n-1

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

.false:
         xor     eax, eax
         ret

.invert_while:                        ; prev_idx = edx, curr_val = eax Które rejestry są już niepotrzebne: r9, r10, r11 
         mov     r9d, [rsi+rdx*4]     ; r9d = p[prev_idx]
         test    r9d, r9d
         cmovs   eax, r9d             ; if (p[prev_idx] < 0) { curr_val = p[prev_idx]; }
         test    eax, eax
         js      .nested_while

.return_to_outer_while:
         inc     edx
         cmp     edi, edx             ; Sprawdzamy, czy edx = prev_idx == n-1
         jge     .invert_while
         jmp     .true

.nested_while:                        ; prev_idx = edx, curr_val = eax, r9 useless
         test    eax, eax
         jns     .return_to_outer_while
         and     eax, r8d             ; curr_val = eax = eax & ~(1<<31) = r8d
         xor     r9, r9
         mov     r9d, [rsi+rax*4]      ; r9d = tmp = p[eax] = p[curr_val]
         test    r9d, r9d            ; if (tmp >= 0) { break; }
         jns     .return_to_outer_while
         mov     [rsi+rax*4], edx     ; p[curr_val] = p[eax] = prev_idx = edx
         mov     edx, eax             ; prev_idx = edx = curr_idx = eax
         mov     eax, r9d             ; curr_val = tmp
         jmp     .nested_while

.true:
  lea    rax, [0x1]
  ret             
         
