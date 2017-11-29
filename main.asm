;-----------------------------------------
; RGB LED control project
;-----------------------------------------

    #include <p10f206.inc>
    
    __CONFIG _CP_OFF & _MCLRE_OFF & _WDT_OFF
    
    ; --- Variable definitions ---
    cblock 0x10
        r_val, g_val, b_val
	act_tmr, act_gpio
	r_cntr, g_cntr, b_cntr
	color_state
    endc
   
    ; --- Code section ---
    code
    
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
    
    clrf    TMR0
    
    call    StartColors
    call    UpdateBAMValues
    
Main
    movf    act_tmr, W
    subwf   TMR0, W
    btfss   STATUS, Z
    goto    Main
    call    LoadGPIO
    bcf	    STATUS, C
    rlf	    act_tmr, F
    btfss   STATUS, C
    goto    Main
    call    UpdateBAMValues
    goto    Main
    
LoadGPIO    ; 14 cycles
    clrf    act_gpio
    
    rrf	    g_val, F
    btfsc   STATUS, C
    bsf	    act_gpio, 0
    
    rrf	    r_val, F
    btfsc   STATUS, C
    bsf	    act_gpio, 1
    
    rrf	    b_val, F
    btfsc   STATUS, C
    bsf	    act_gpio, 2
    
    movf    act_gpio, W
    movwf   GPIO
    
    retlw   0
    
UpdateBAMValues	; 10 cycles
    movlw   1
    movwf   act_tmr
    
    movf    g_cntr, W
    movwf   g_val
    movf    r_cntr, W
    movwf   r_val
    movf    b_cntr, W
    movwf   b_val
    
    call    CalcNewColors
    
    retlw   0

StartColors
    movlw   0x00
    movwf   g_cntr
    movlw   0x00
    movwf   r_cntr
    movlw   0xFF
    movwf   b_cntr
    movlw   b'00000001'
    movwf   color_state

CalcNewColors
    btfsc   color_state, 0x00
    goto    R_UP
    btfsc   color_state, 0x01
    goto    R_DOWN
    btfsc   color_state, 0x02
    goto    G_UP
    btfsc   color_state, 0x03
    goto    G_DOWN
R_UP
    incfsz  r_cntr, F
    goto    CalcNewColorsEnd
    movlw   0xFF
    movwf   r_cntr
    movlw   b'00000010'
    movwf   color_state
R_DOWN
    decfsz  r_cntr, F
    goto    CalcNewColorsEnd
    movlw   b'00000100'
    movwf   color_state
G_UP
    incfsz  g_cntr, F
    goto    CalcNewColorsEnd
    movlw   0xFF
    movwf   g_cntr
    movlw   b'00001000'
    movwf   color_state
G_DOWN
    decfsz  g_cntr, F
    goto    CalcNewColorsEnd
    movlw   b'00000001'
    movwf   color_state
CalcNewColorsEnd
    retlw   0
    
    end
