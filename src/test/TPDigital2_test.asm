LIST P = 16F887
#INCLUDE <p16f887.inc>

; CONFIG1
; __config 0xFFE1
 __CONFIG _CONFIG1, _FOSC_INTRC_CLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2

; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF


; DEFINICION DE REGISTROS

AUX_K		EQU	0x20					;VARIABLE PARA ROTAR CEROS EN EL PUERTO	
PORTB_AUX	EQU	0x21					;PUERTO B AUXILIAR PARA LECTURA 
KEY		EQU	0x22					;TECLA LEIDA DEL TECLADO MATRICIAL
W_AUX		EQU	0x23					;VARIABLE PARA SALVAR EL ENTORNO
ST_AUX		EQU	0x24					;VARIABLE PARA SALVAR EL ENTORNO
CONT_T		EQU	0x25					;CONTADOR QUE CUENTA EN SEGUNDOS
CONTS_T		EQU	0x26					;TIEMPO A CONTAR EN SEGUNDOS
CONT_1		EQU	0x27					;VARIABLE PARA SUBRUTINA DE RETARDO
CONT_2		EQU	0x28					;VARIABLE PARA SUBRUTINA DE RETARDO

			ORG 0x00	
			GOTO	INICIO

			ORG 0x04
			GOTO	INTRP
				
					
INICIO
			CLRW
			CLRF		STATUS
			CLRF		AUX_K
			CLRF		PORTB_AUX
			CLRF		KEY
			CLRF		W_AUX			;LIMPIEZA INICIAL DE REGISTROS
			CLRF		ST_AUX
			CLRF		CONT_T
			CLRF		CONTS_T
			CLRF		CONT_1
			CLRF		CONT_2
			
			CALL		CONF			;LLAMAR A SUBRUTINA DE CONFIGURACION

			MOVLW		0xF7			;0   1111 0111 
			MOVWF		AUX_K
			
			MOVLW		0x0F
			MOVWF		PORTB
			
			BSF		INTCON, 7		;HABILITAR GIE



LOOP		
			CALL		LOAD_ENV
			RLF		AUX_K, 1		;ROTAR LA VARIABLES AUX_K
			CALL		SAVE_ENV
			
			MOVF		CONTS_T, 0		;MOSTRAMOS EN DISPLAY
			CALL 		DISPLAY
			MOVWF		PORTD
		
			MOVF		AUX_K, 0		;MOVER AUX_K AL PUERTO B
			
			BCF		INTCON,3		;DESHABILITAR INTERRUPCIONES POR RB
			MOVWF		PORTB
			CALL		RETARDO2
			BCF		INTCON,0		;BAJAR RBIF
			BSF		INTCON,3		;HABILITAR INTERRUPCIONES POR RB
			

			GOTO		LOOP

		

INTRP
			CALL		SAVE_ENV		;SALVAR ENTORNO
	
			BTFSC		INTCON, 0		;CHEQUEAR RBIF
			CALL		TECLA		

			BTFSC		INTCON, 2		;CHEQUEAR T0IF
			CALL 		TIMER
			
			CALL		LOAD_ENV		;CARGAR ENTORNO
			
			RETFIE


TECLA		
			CALL 		RETARDO			;LLAMAR SUBRUTINA DE RETARDO
						
			BANKSEL		PORTB			
			MOVF		PORTB,0			;MOVER EL VALOR DE PORTB A PORTB_AUX
			MOVWF		PORTB_AUX		
		
			CLRW	
			
	;FILAS							;ESTABLECER DE QUE FILA VINO LA INTERRUPCION Y ASIGNAR EL VALOR A KEY
			BTFSS		PORTB_AUX, 4
			MOVLW		0x01
			
			BTFSS		PORTB_AUX, 5
			MOVLW		0x03
			
			BTFSS		PORTB_AUX, 6
			MOVLW		0x07
			
			BTFSS		PORTB_AUX, 7		;NUNCA DEBERIA ENTRAR ACA
			MOVLW		0x00

			ADDLW		0x00			;PARA COMPROBAR QUE W ES CERO, ENTONCES RETORNAR
			BTFSC		STATUS, Z
			RETURN
	;COLUMNAS
						    		;ESTABLECER DE QUE COLUMNA VINO LA INTERRUPCION
			BTFSS		PORTB_AUX, 0
			ADDLW		0x00
			
			BTFSS		PORTB_AUX, 1
			ADDLW		0x01
			
			BTFSS		PORTB_AUX, 2
			ADDLW		0x02
						
			MOVWF		CONTS_T			;PONGO EL VALOR DE LA TECLA EN CONTS_T

			
			BCF		INTCON, 0		;BAJAR RBIF
			
			
			MOVLW		0x14
			MOVWF		CONT_T
			
			MOVLW		.62			;PRECARGAR EL TIMER 0 CON 62d
			MOVWF		TMR0
			BCF		INTCON, 2		;BAJAR T0IF
			BSF		INTCON, 5		;HABILITAR T0IE
			
			BSF		PORTA,1			;BOMB HAS BEEN PLANTED
			;CALL		RETARDO			<---------------------------- PORQUE ESTE RETARDO?

			RETURN

TIMER
			BCF		INTCON,2		;BAJAR BANDERA DE INTERRUPCIONES DE TMR0
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			MOVF		CONT_T, 0
			BTFSC		STATUS, Z
			MOVLW		0x14
			MOVWF		CONT_T
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			MOVLW		.62			;VALOR A ASIGNAR DEL TMR0 PARA 50MS
			MOVWF		TMR0			;MOVER AL REG TMR0
			DECFSZ		CONT_T,1		;DECREMENTAR EL VALOR DE CONT_T, SI ES CERO, PASO UN SEGUNDO, SALTEAR EL RETURN
			RETURN
		
			BSF		PORTA,0			;SACAR UN 1 POR EL PORTA PARA BEEP DE BOMBA
			CALL		RETARDO
			CALL		RETARDO
			BCF		PORTA,0
			
			MOVLW		0x14			;PONER CONT EN 20
			MOVWF		CONT_T
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			MOVF		CONTS_T, 1
			BTFSC		STATUS, Z
			RETURN
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			DECFSZ		CONTS_T,1		;DECREMENTAR EL VALOR DE CONTS_T, SI ES CERO, SALTEAR PORQUE YA TERMINO LA CUENTA REGRESIVA
			RETURN
			
			BCF		INTCON,5		;BAJAR T0IE
			
			BCF		PORTA, 1		;REPRODUCIR TERRORISTS WIN
			RETURN

SAVE_ENV								;SALVAR EL ENTORNO
			MOVWF		W_AUX
			SWAPF		STATUS, 0
			MOVWF		ST_AUX
	
			RETURN
	

LOAD_ENV								;CARGAR EL ENTORNO
			SWAPF		ST_AUX, 0
			MOVWF		STATUS
			SWAPF		W_AUX, 1
			SWAPF		W_AUX, 0
		
			RETURN
		
		
DISPLAY									;TABLA PARA MOSTRAR NÚMERO EN DISPLAY
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			SUBLW		0x0A			;RESTO 10
			BTFSC		STATUS, C
			CLRF		CONTS_T			;SI ES MAYOR A 9, LO PONGO EN CERO
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			MOVF		CONTS_T, 0		;CARGO EL NUMERO DE VUELTA
			
			ADDWF		PCL,1
			RETLW		0x7E			;0111 1110 CERO
			RETLW		0x30			;0011 0000 UNO
			RETLW		0x6D			;0110 1101 DOS	
			RETLW		0x79			;0111 1001 TRES	
			RETLW		0x33			;0011 0011 CUATRO
			RETLW		0x5B			;0101 1011 CINCO
			RETLW		0x5F			;0101 1111 SEIS	
			RETLW		0x70			;0111 0000 SIETE
			RETLW		0x7F			;0111 1111 OCHO
			RETLW		0x7B			;0111 1011 NUEVE


CONF									;SUBRUTINA DE CONFIGURACIÓN DE PUERTOS Y REGISTROS
	BANKSEL		OPTION_REG
	MOVLW		0x07
	MOVWF		OPTION_REG
	
	BANKSEL		WPUB					;PULLUP PARA EL PUERTO B
	MOVLW		0xF0
	MOVWF		WPUB
	
	BANKSEL		INTCON;		
	MOVLW		0x08
	MOVWF		INTCON
	
	BANKSEL		IOCB
	MOVLW		0xF0
	MOVWF		IOCB
	
	BANKSEL		ANSEL					;ANALOG OFF
	CLRF		ANSEL
	CLRF		ANSELH
	
	BANKSEL		PORTB					;LIMPIEZA DEL PUERTO B
	CLRF		PORTB
	
	BANKSEL		TRISB					;RB4-RB7 ENTRADAS, RB3-RB0 SALIDAS (TECLADO)
	MOVLW		0xF0
	MOVWF		TRISB

	BANKSEL		PORTD					;LIMPIEZA DEL PUERTO D
	CLRF		PORTD
	
	BANKSEL		TRISD					;PUERTO D COMO SALIDA (DISPLAY)
	CLRF		TRISD
	
	BANKSEL		PORTA					;LIMPIEZA DEL PUERTO A
	CLRF		PORTA
	
	BANKSEL 	TRISA					;DOS SALIDAS PARA RBPI
	BCF			TRISA, 1
	BCF			TRISA, 0				
	
	BCF			STATUS, RP1				;VOLVEMOS AL BANK0
	BCF			STATUS, RP0
	
	RETURN


RETARDO									;RETARDO PARA TECLADO
	
	MOVLW		0x1F
	MOVWF		CONT_2
LOOP2	
	MOVLW		0xFF
	MOVWF		CONT_1
LOOP1	
	DECFSZ		CONT_1, 1
	GOTO		LOOP1
	DECFSZ		CONT_2, 1
	GOTO		LOOP2
	RETURN

RETARDO2								;RETARDO AUXILIAR PARA ESTABLECIMIENTO
	
	MOVLW		0x04
	MOVWF		CONT_2
LOOP3	
	MOVLW		0xFF
	MOVWF		CONT_1
LOOP4
	DECFSZ		CONT_1, 1
	GOTO		LOOP4
	DECFSZ		CONT_2, 1
	GOTO		LOOP3
	RETURN



	END
