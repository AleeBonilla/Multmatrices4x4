
includelib \Windows\System32\kernel32.lib 

ExitProcess proto   ; Finalización de proceso
GetStdHandle proto  ; Manejo de consola (API de Windows)
WriteConsoleA proto ;

.data

;    matriz1 dd 1.0,    2.0,    3.0,    4.0,
;               5.0,    6.0,    7.0,    8.0,
;               9.0,    10.0,   11.0,   12.0,
;               13.0,   14.0,   15.0,   16.0

    matriz1 dd  45.0,   6.0,    4.7,    22.0,
               -32.0,   0.0,    121.0,  2.0,
               -0.34,  -132.0,  1.0,    77.0,
                89.0,   0.69,   27.0,   99.0

    matriz2 dd  17.0,   18.0,   19.0,   20.0,
                21.0,   22.0,   23.0,   24.0,
                25.0,   26.0,   27.0,   28.0,
                29.0,   30.0,   31.0,   32.0

    matrizRes dd 16 dup(0.0)

.code

; -> Uso de los registros
; 
; XMM0 = matriz2_fila0
; XMM1 = matriz2_fila1
; XMM2 = matriz2_fila2
; XMM3 = matriz2_fila3
;
; RCX = puntero al resultado
; RDX = puntero a matriz1
; R8  = puntero a matriz2
; R10 = registro contador de filasXcolumnas completadas
; R11 = registro para desplazamiento entre filas 
;
; xmm4 - xmm7 = registros para resultados intermedios

main PROC

    LEA RDX, matriz1        ; Creamos los punteros a las tres matrices
    LEA R8,  matriz2        ;
    LEA RCX, matrizRes      ;

    VMOVAPS XMM0, [R8]      ; Cargamos matriz2 en los registros correspondientes
    VMOVAPS XMM1, [R8 + 16] ;
    VMOVAPS XMM2, [R8 + 32] ; 
    VMOVAPS XMM3, [R8 + 48] ;
                             
    ; Ejemplo de cargado con los números 1-16
    ;
    ;  XMM0   =   4.0    3.0    2.0    1.0  
    ;  XMM1   =   8.0    7.0    6.0    5.0
    ;  XMM2   =   12.0   11.0   10.0   9.0
    ;  XMM3   =   16.0   15.0   14.0   13.0
    ;
    ; Se cargan al revés

    XOR R10, R10 ; Limpiamos el registro índice por precaución

    _loop:

        MOV R11, R10 ; Movemos el contenido de R10 para volver a calcula el offset
        SHL R11, 4   ; Equivalente a multiplicar R11 x 16 

        ; Direccionamiento mediante escala + desplazamiento

        VBROADCASTSS XMM4, REAL4 PTR [RDX + R11]      ; Distribuyendo la fila R10 (0-3) de matriz1 de XMM4 a XMM7
        VBROADCASTSS XMM5, REAL4 PTR [RDX + R11 + 4]  ;
        VBROADCASTSS XMM6, REAL4 PTR [RDX + R11 + 8]  ;
        VBROADCASTSS XMM7, REAL4 PTR [RDX + R11 + 12] ; 

        VMULPS XMM4, XMM4, XMM0 ; matriz1[R10][0] * matriz2.fila0
        VMULPS XMM5, XMM5, XMM1 ; matriz1[R10][1] * matriz2.fila1
        VMULPS XMM6, XMM6, XMM2 ; matriz1[R10][2] * matriz2.fila2
        VMULPS XMM7, XMM7, XMM3 ; matriz1[R10][3] * matriz2.fila3

        VADDPS XMM4, XMM4, XMM5 ; Suma elemento a elemento: (matriz1[R10][0]*matriz2.fila0) + (matriz1[R10][1]*matriz2.fila1)
        VADDPS XMM6, XMM6, XMM7 ; Suma elemento a elemento: (matriz1[R10][2]*matriz2.fila2) + (matriz1[R10][3]*matriz2.fila3)
        VADDPS XMM4, XMM4, XMM6 ; Suma elemento a elemento los resultados parciales para obtener la fila resultado final

        VMOVAPS [RCX + R11], XMM4 ; Movemos la fila resultante a la fila R10 (0-3)

        INC R10    ; Incrementamos R10 para saber si completamos las 4 filas
        CMP R10, 4 ;
        JNE _loop  

    call ExitProcess

main ENDP
END
