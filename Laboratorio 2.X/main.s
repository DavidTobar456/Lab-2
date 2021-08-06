; Archivo: main.s
; Compilador: pic-as (v2.32)
; Autor: David Antonio Tobar López

; Programa: Contador de 8 bits con
; Fecha de creción: 3 de agosto 2021
; Última modificación: 3 de agosto 2021
    
; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

PSECT udata_bank0   
  cont: DS  2; Separa dos bits
    
PSECT resVet, class=CODE, abs, delta=2	;Hacemos una sección de código para el vector reset
  ORG 00h
  resVect:
    PAGESEL main
    goto main
    
PSECT CODE, abs, delta=2	;Generamos otra sección de código
    ORG 100h
    ; -------MAIN-------
    main:
	CALL	config_io
	CALL	config_clock
	BANKSEL	PORTA
    
    ; ------LOOP--------------
    loop:
	btfsc	PORTB,0	; Si el push button en RB0 no da entrada se skipea
	call	inc_porta
	btfsc	PORTB,1	; Si el push button en RB1 no da entrada skipea
	call	dec_porta
	btfsc	PORTB,2	; Si el push button en RB2 no da entrada skipea
	call	inc_portc
	btfsc	PORTB,3	; Si el push button en RB3 no da entrada skipea
	call	dec_portc
	btfsc	PORTB,4	; Si el push button en RB4 no da entrada skipea
	call	confirm_suma
    goto loop
    ; ------Subrutinas Primer sistema--------
    config_io:
	BANKSEL ANSEL
	clrf	ANSEL	; Configuramos todos los I/0 de ANSEL como digitales
	clrf	ANSELH	; Configuramos todos los I/O de ANSELH como digitales
	
	BANKSEL TRISA
	clrf	TRISA	; Configuramos todos los puertos A como salidas
	clrf	TRISC	; Configuramos todos los puertos de C como salidas
	clrf	TRISD	; Configuramos todos los puertos de D como salidas
	bsf	TRISB,0
	bsf	TRISB,1	
	bsf	TRISB,2
	bsf	TRISB,3
	bsf	TRISB,4 ; Configuramos los de RB0 a RB3 como entradas
	
	BANKSEL PORTA
	clrf	PORTA	; Borramos los valores guardados en PORTA
	clrf	PORTC	; Borramos los valores guardados en PORTC
	clrf	PORTD	; Borramos los valores guardados en PORTD
    return
    
    config_clock:
	BANKSEL OSCCON
	bsf	IRCF2
	bcf	IRCF1
	bcf	IRCF0	; Se está usando una frecuencia de 1MHz
	bsf	SCS	; Se está usando el oscilador interno
    return
    
    inc_porta:
	call	delay_largo
	btfsc	PORTB,0 ; Si el push button en RB0 no da entrada skipea
	goto	$-1
	incf	PORTA	; Se incrementa el PORTA
	btfsc	PORTA,4	; Si el contador no ha llegado al cuarto bit skipea
	clrf	PORTA	; Se resetea el contador
    return
    
    dec_porta:
	call	delay_largo
	btfsc	PORTB,1
	goto	$-1
	decf	PORTA
	btfsc	PORTA,4
	call	reinicio_A
    return
    
    reinicio_A:
	clrf	PORTA
	bsf	PORTA,0
	bsf	PORTA,1
	bsf	PORTA,2
	bsf	PORTA,3
    return
    
    inc_portc:
	call	delay_largo
	btfsc	PORTB,2 ; Si el push button en RB0 no da entrada skipea
	goto	$-1
	incf	PORTC	; Se incrementa el PORTA
	btfsc	PORTC,4	; Si el contador no ha llegado al cuarto bit skipea
	clrf	PORTC	; Se resetea el contador
    return
    
    dec_portc:
	call	delay_largo
	btfsc	PORTB,3
	goto	$-1
	decf	PORTC
	btfsc	PORTC,4
	call	reinicio_c
    return
    
    reinicio_c:
	clrf	PORTC
	bsf	PORTC,0
	bsf	PORTC,1
	bsf	PORTC,2
	bsf	PORTC,3
    return
    
    suma:
	movf	PORTA, w
	addwf	PORTC, w
	movwf	PORTD
    return
    
    confirm_suma:
	call	delay_largo
	btfsc	PORTB,4
	goto	$-1
	call	suma
    return
    
    delay:
	movlw	150	; Seteamos un valor inicial para la literal
	movwf	cont	; Definimos el valor del contador
	decfsz	cont, f	;
	goto	$-1
    return
    
    delay_largo:
	movlw	7
	movwf	cont+1
	call	delay
	decfsz	cont+1,1
	goto	$-2
    return
END    
	

