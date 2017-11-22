;-----------------------------------------
; RGB LED control project
;-----------------------------------------

    #include <p10f206.inc>
    
    __CONFIG _CP_OFF & _MCLRE_OFF & _WDT_OFF
    
    org	    0x00
    movlw   0x40
    movwf   OSCCAL
    
Init
    ; Disable comparator; Disable comparator
    movlw   b'01010001'
    movwf   CMCON0
    ; Disable wake-up on pin change bit, disable weak pull-ups
    ; TMR0 prescaler - 32
    movlw   b'11000100'
    option
    ; Setup GPIO, GP0..2 - outputs, GP3 - input
    clrf    GPIO
    movlw   b'00001000'
    tris    GPIO
    
    movlw   2
    movwf   TMR0
    
Main
    movf    TMR0, W
    btfss   STATUS, Z
    goto    Main
    movlw   2
    movwf   TMR0
    movlw   b'00000111'
    xorwf   GPIO, F
    goto    Main
    
    end