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
	color_state, color_change, color_pattern
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
    ; TMR0 prescaler - 16
    movlw   b'11000011'
    option
    ; Setup GPIO, GP0..2 - outputs, GP3 - input
    clrf    GPIO
    movlw   b'00001000'
    tris    GPIO
    
    clrf   color_pattern
    
    clrf    TMR0
    
    call    StartColorsRG
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
    call    CheckButton
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
    
UpdateBAMValues
    movlw   1
    movwf   act_tmr
    
    movf    g_cntr, W
    movwf   g_val
    movf    r_cntr, W
    movwf   r_val
    movf    b_cntr, W
    movwf   b_val
    
    incf    color_change, F
    btfss   color_change, 0x00
    retlw   0
    
    movlw   0
    subwf   color_pattern, W
    btfsc   STATUS, Z
    call    CalcNewColorsRG
    
    movlw   1
    subwf   color_pattern, W
    btfsc   STATUS, Z
    call    CalcNewColorsRB   
    
    retlw   0

; Test button input - GPIO3, if pressed (pulled to GND) inrement color_pattern.
; Initialize colors for selected pattern
CheckButton
    btfsc   GPIO, 0x03
    retlw   0
    incf    color_pattern, F
    movlw   2 ; (Max value + 1) for color_pattern
    subwf   color_pattern, W
    btfsc   STATUS, Z   
    clrf    color_pattern
    
    movlw   0
    subwf   color_pattern, W
    btfsc   STATUS, Z
    call    StartColorsRG
    
    movlw   1
    subwf   color_pattern, W
    btfsc   STATUS, Z
    call    StartColorsRB   
    
    retlw   0

StartColorsRG
    movlw   0x00
    movwf   g_cntr
    movlw   0x00
    movwf   r_cntr
    movlw   0xFF
    movwf   b_cntr
    movlw   b'00000001'
    movwf   color_state
    retlw   0
    
StartColorsRB
    movlw   0xFF
    movwf   g_cntr
    movlw   0x00
    movwf   r_cntr
    movlw   0x00
    movwf   b_cntr
    movlw   b'00000001'
    movwf   color_state
    retlw   0

; Blue always on, red and green goes up and down
CalcNewColorsRG
    btfsc   color_state, 0x00
    goto    RG_R_UP
    btfsc   color_state, 0x01
    goto    RG_R_DOWN
    btfsc   color_state, 0x02
    goto    RG_G_UP
    btfsc   color_state, 0x03
    goto    RG_G_DOWN
RG_R_UP
    incfsz  r_cntr, F
    goto    CalcNewColorsRGEnd
    movlw   0xFF
    movwf   r_cntr
    movlw   b'00000010'
    movwf   color_state
RG_R_DOWN
    decfsz  r_cntr, F
    goto    CalcNewColorsRGEnd
    movlw   b'00000100'
    movwf   color_state
RG_G_UP
    incfsz  g_cntr, F
    goto    CalcNewColorsRGEnd
    movlw   0xFF
    movwf   g_cntr
    movlw   b'00001000'
    movwf   color_state
RG_G_DOWN
    decfsz  g_cntr, F
    goto    CalcNewColorsRGEnd
    movlw   b'00000001'
    movwf   color_state
CalcNewColorsRGEnd
    retlw   0
    
; Green always on, red and blue goes up and down
CalcNewColorsRB
    btfsc   color_state, 0x00
    goto    RB_R_UP
    btfsc   color_state, 0x01
    goto    RB_R_DOWN
    btfsc   color_state, 0x02
    goto    RB_B_UP
    btfsc   color_state, 0x03
    goto    RB_B_DOWN
RB_R_UP
    incfsz  r_cntr, F
    goto    CalcNewColorsRBEnd
    movlw   0xFF
    movwf   r_cntr
    movlw   b'00000010'
    movwf   color_state
RB_R_DOWN
    decfsz  r_cntr, F
    goto    CalcNewColorsRBEnd
    movlw   b'00000100'
    movwf   color_state
RB_B_UP
    incfsz  b_cntr, F
    goto    CalcNewColorsRBEnd
    movlw   0xFF
    movwf   b_cntr
    movlw   b'00001000'
    movwf   color_state
RB_B_DOWN
    decfsz  b_cntr, F
    goto    CalcNewColorsRBEnd
    movlw   b'00000001'
    movwf   color_state
CalcNewColorsRBEnd
    retlw   0
    
    end
