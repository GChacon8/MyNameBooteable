; my_name.asm - Programa que rota el nombre
org 0x8000                      ; La aplicación empieza en 0x8000
bits 16                         ; Código en 16 bits

start:
    mov si, name                ; Cargar la dirección del nombre en SI
    call clear_screen           ; Limpiar la pantalla antes de imprimir
    call print_name             ; Imprimir el nombre
    call keyboard_input         ; Leer la entrada del teclado para rotar el nombre

rotate_left:
    ; Rotar el nombre a la izquierda
    call rotate_string_left
    call clear_screen           ; Limpiar la pantalla
    call print_name
    jmp start

rotate_right:
    ; Rotar el nombre a la derecha
    call rotate_string_right
    call clear_screen           ; Limpiar la pantalla
    call print_name
    jmp start

keyboard_input:
    mov ah, 0x00                ; Espera por una tecla presionada
    int 0x16                    ; Interrupción del BIOS para leer teclado
    cmp al, 0x4B                ; Tecla de flecha izquierda
    je rotate_left
    cmp al, 0x4D                ; Tecla de flecha derecha
    je rotate_right
    jmp start

print_name:
    mov ah, 0x0E                ; Función para imprimir caracteres (BIOS)
.print_loop:
    lodsb                       ; Cargar el siguiente carácter
    cmp al, 0                   ; Si es 0, fin del string
    je .done
    int 0x10                    ; Imprimir carácter
    jmp .print_loop
.done:
    ret

clear_screen:
    ; Usa int 0x10, función 0x06 para limpiar la pantalla
    mov ah, 0x06                ; Función de BIOS para desplazamiento de líneas
    mov al, 0                   ; Número de líneas a desplazar (0 = todas)
    mov bh, 0x07                ; Atributo de texto (fondo negro, texto gris claro)
    mov cx, 0                    ; Esquina superior izquierda (fila y columna)
    mov dx, 0x184F              ; Esquina inferior derecha (fila 24, columna 79)
    int 0x10                    ; Interrupción del BIOS para limpiar pantalla
    ret

rotate_string_left:
    ; Rotar los caracteres del string a la izquierda
    push si
    mov si, name
    lodsb
    mov dl, al                  ; Guarda el primer carácter
.loop:
    lodsb
    stosb                       ; Mueve los caracteres a la izquierda
    cmp al, 0
    jne .loop
    mov al, dl                  ; Coloca el primer carácter al final
    stosb
    pop si
    ret

rotate_string_right:
    ; Rotar los caracteres del string a la derecha
    push si
    mov si, name
    mov cx, 0                   ; Inicializa el contador de caracteres
.count_loop:
    lodsb
    cmp al, 0
    je .rotate
    inc cx
    jmp .count_loop
.rotate:
    dec cx
    mov si, name
    add si, cx                  ; Apunta al último carácter
    lodsb
    mov dl, al                  ; Guarda el último carácter
.reverse_loop:
    dec si
    lodsb
    stosb                       ; Mueve los caracteres a la derecha
    cmp si, name
    jne .reverse_loop
    mov al, dl                  ; Coloca el último carácter al principio
    stosb
    pop si
    ret

name db 'Gabriel', 0             ; Nombre a rotar
times 510-($-$$) db 0            ; Rellena hasta 512 bytes
