List p = 16f877a
Include <p16f877a.inc>

EQU		TECLA		0x20
EQU		CONTS		0x21;		CONTADOR EN SEGUNDOS
EQU		CONT		0x22;		EL OTRO
		.ORG 		0x00
		GOTO		MAIN
		.ORG 		0x04; 	<- REGISTRO DE INTERRUPCION
		GOTO 		INTRP
		.ORG 		0x10

MAIN
		CALL 		CONFIGURA;	<- CONFIGURAR REGISTROS
		SLEEP
LOOP		


		MOVF		CONTS,0;
BTFSS		STATUS,Z
GOTO LOOP
BCF		INTCON,7;	PARAR LAS INTERRUPCIONES
			;	ACA PASAS ALGO (PIC -> ALGO)
		
		
CONFIGURA;				<- [!]PONER B COMO DIGITAL
		BSF 	 	STATUS,RP0;	MOVER AL BANCO 1
		MOVLW 		0xF0;		MOVER 0xF0 AL REG W			
		MOVWF		TRISB;		HABILITAR EL PUERTO B (4-7) COMO ENTRADA
		BCF		STATUS,RP0;	MOVER AL BANCO 0	
		MOVLW		0xD7;		SETEO DE OPTION_REG
		MOVWF		OPTION_REG;
MOVLW		0x88;		HABILITO GIE, Y RBIE
		MOVWF		INTCON
		
		
INTRP
		BTFSC		INTCON,0;	CHEQUEAR FLAG DE INTRP POR EL PORT B (4-7)
		CALL 		TECLADO;	LLAMAR SUBRUTINA DE CUENTA REGRESIVA
		BTFSC		INTCON,2;	CHEQUEAR FLAG DE TMR0
		CALL		TIMER;		LLAMAR SUBRUTINA DE TIMER
RETFIE

TECLADO
BCF		INTCON,0;	BAJAR FLAG DE INTERRUPCION POR RBIF
....	
BSF		INTCON,5;	HABILITAR INTERRUPCIONES DEL TMR0
RETURN			;	CREO QUE ACA DEBERIA IR RETURN Y
			;	RETFIE AL FINAL DE INTRP
TIMER
		BCF		INTCON,0;	BAJAR BANDERA DE INTERRUPCIONES DE TMR0
		MOVLW		0x14;		PONER CONT EN 20
		MOVWF		CONT;
		MOVLW		.62;		VALOR A ASIGNAR DEL TMR0 PARA 50MS
MOVWF		TMR0;		MOVER AL REG TMR0
		DECFSZ		CONT,1;
		RETURN
DECFSZ		CONTS,1;
		RETURN

		


-ARREGLAR TEMA DE CONFIGURACIONES
-ARMAR LA RUTINA DEL TECLADO DE MIERDA
-PIC-> ALGO (?)


CONFIGURACIONES:

OPTION_REG(BANK 1 Y 3): 	PONER PULL-UP A PORTB
FUENTE DEL TIMER0
ASIGNACIÓN DEL PRESCALER

WPUB (BANK 1):		ELEGIR LOS PINES DE PORTB CON PULL-UP


INTCON(TODOS LOS BANCOS):	GIE
T0IE (INICIALIZARLO ANTES DE BAJAR FLAG)
RBIE (HABILITAR IOCB TAMBIEN)

IOCB (BANK 1):		PINES DE B QUE INTERRUMPEN AL CAMBIAR

ANSELH (BANK 4):		PONER PORTB COMO DIGITAL

TRISB (BANK 1):		I/O PORTB
TRISX (BANK 1):		I/O DE ALGUN OTRO PUERTO

PORTX (BANK 0)




*BANKSEL -> PARA ELEGIR LOS BANCOS

    List p = 16f887
    Include <p16f887.inc>
	
AUX_K	EQU	0x26	
CONT_K	EQU	0x21
KEY	EQU	0x22
AUX_INT	EQU	0x23
W_AUX	EQU	0x24
ST_AUX	EQU	0x25
	
	ORG	0x00
	GOTO	INICIO
	
	ORG	0x04
	GOTO	INTRP
	
	
INICIO
	CALL	CONF
	
	MOVLW	0xF7			;0   1111 0111 -> COSAS RARAS PASAN,
	MOVWF	AUX_K			;DEBERIA ANDAR PERO COMO NO COMENTE NO
					;VOY A ENTENDER NADA DESPUES

LOOP	
	MOVF	AUX_K, 0		;YA NO SE “”””DEBERIA”””” ROMPER
	MOVWF	PORTB
	BCF	INTCON, 0		;GUALICHO.START()
	BSF	INTCON, 3
	
	INCF	CONT_K, 0		;MAGIA NEGRA
	ANDLW	0x03
	
	BCF	INTCON, 3		;GUALICHO.END()
	MOVWF	CONT_K
	
	RLF	AUX_K, 1
	
	GOTO	LOOP

;LOOP	
;	MOVF	AUX_K, 0		;SE PODRIA LLEGAR A ROMPER 
;	MOVWF	PORTB	
;	
;	INCF	CONT_K, 0		;MAGIA NEGRA
;	ANDLW	0x03
;	MOVWF	CONT_K
;	
;	RLF	AUX_K, 1
;	
;	GOTO	LOOP
	

INTRP
	CALL	SAVE_ENV
	BTFSC	INTCON, 0
	CALL	TECLA
	
	CALL	LOAD_ENV
	
	RETFIE
	

TECLA
	BANKSEL	PORTB
	MOVF	CONT_K, 0
	
	BTFSS	PORTB, 4
	MOVWF	KEY
	
	ADDLW	0x03
	BTFSS	PORTB, 5
	MOVWF	KEY
	
	ADDLW	0x03
	BTFSS	PORTB, 6
	MOVWF	KEY
	
	ADDLW	0x03
	BTFSS	PORTB, 7
	MOVWF	KEY
	
	BCF	INTCON, RBIF

	MOVLW	.62
	MOVWF	TMR0
	BSF	INTCON, 5
	
	RETURN
	
	
SAVE_ENV
	MOVWF	W_AUX
	SWAPF	STATUS, 0
	MOVWF	ST_AUX
	
	RETURN
	

LOAD_ENV
	SWAPF	ST_AUX, 0
	MOVWF	STATUS
	SWAPF	W_AUX, 1
	SWAPF	W_AUX, 0
	
	RETURN


TIMER
		BCF		INTCON,0;	BAJAR BANDERA DE INTERRUPCIONES DE TMR0
		MOVLW		0x14;		PONER CONT EN 20
		MOVWF		CONT;
		MOVLW		.62;		VALOR A ASIGNAR DEL TMR0 PARA 50MS
MOVWF		TMR0;		MOVER AL REG TMR0
		DECFSZ		CONT,1;
		RETURN
DECFSZ		CONTS,1;
		RETURN

	
	
CONF
	BANKSEL	OPTION_REG
	MOVLW	0x07
	MOVWF	OPTION_REG
	
	BANKSEL	WPUB
	MOVLW	0xF0
	MOVWF	WPUB
	
	BANKSEL	INTCON			;CAMBIAR ESTO PARA TMR0
	MOVLW	0x08
	MOVWF	INTCON
	
	BANKSEL	IOCB
	MOVLW	0xF0
	MOVWF	IOCB
	
	BANKSEL	ANSEL
	CLRF	ANSEL
	CLRF	ANSELH
	
	BANKSEL	PORTB
	CLRF	PORTB
	
	BANKSEL	TRISB
	MOVLW	0xF0
	MOVWF	TRISB
	
	BCF	STATUS, RP1
	BCF	STATUS, RP0
	
	RETURN
	
	
	END
