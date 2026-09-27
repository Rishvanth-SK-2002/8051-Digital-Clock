; Project Name : 8051 Digital Clock with Alarm
; Target MCU   : Nuvoton W78E052DDG (8051-compatible core)
; Clock        : 11.0592 MHz crystal (project assumes conventional 12T timing)
;
; Firmware organization
;   0000H : Reset vector -> MAIN
;   0003H : External Interrupt 0 (INT0 / MODE button) -> MODESELECT
;   000BH : Timer 0 overflow -> ISRT0
;   0030H : Main program / display refresh / alarm comparison
;   00B0H : Timer0 ISR
;   0100H : Time/alarm setting UI
;   0250H : 7-segment lookup table
;
; Design notes
;   * R0-R5 (Bank 0) hold the six display/state values used by the clock.
;   * Bank 1 is used temporarily by the alarm comparison loop.
;   * Bank 2 is used by the mode-setting routine.
;   * 00H-05H are used as the live six-byte clock field.
;   * 31H-36H are used as the six-byte alarm field.
;   * 45H-4AH hold position/reference values used by the setting UI.
;   * The lookup table entries 10-19 add 80H to the normal digit pattern;
;     in this design that extra bit is used for the separator/marker state.
;   * Timer0 reload EFDBH gives 4133 timer counts per overflow. At 11.0592 MHz
;     in 12T mode this is about 4.4846 ms. 223 overflows are used as the
;     software one-second base (nominally about 1.000064 s before accounting
;     for instruction/interrupt overhead).
;   * Display digits format -  H1 H2 : M1 M2 : S1 S2 - R5 R4 : R3 R2 : R1 R0. 

; Aliases
DIGIT       EQU P0          ; Shared 8-bit segment-data bus.
TRAN1       EQU P2.7        ; Digit-select output 1.
TRAN2       EQU P2.6        ; Digit-select output 2.
TRAN3       EQU P2.5        ; Digit-select output 3.
TRAN4       EQU P2.4        ; Digit-select output 4.
TRAN5       EQU P2.3        ; Digit-select output 5.
TRAN6       EQU P2.2        ; Digit-select output 6.

LEFT        EQU P1.0        ; UI button: move selection left.
RIGHT       EQU P1.1        ; UI button: move selection right.
UP          EQU P1.2        ; UI button: change selected value upward.
DOWN        EQU P1.3        ; UI button: change selected value downward.
BUZZER      EQU P1.4        ; Alarm buzzer output.
MODE        EQU P3.2        ; MODE button; also INT0 on the 8051.
ALARM       EQU P2.0        ; Select alarm-setting mode.
TIMESET     EQU P2.1        ; Select time-setting mode.

; LEFT, RIGHT, UP, DOWN, ALARM and TIMESET buttons are configured as active low inputs.

CLOCK_BASE          EQU 00H  ; Six-byte live clock field: 00H-05H.
ALARM_BASE          EQU 31H  ; Six-byte alarm field: 31H-36H.
DISPLAY_REF_BASE    EQU 45H  ; Six position/reference values used by SETMODE.
STACK_START         EQU 50H  ; SP is initialized here; first push uses 51H.
TIMER_RELOAD_H      EQU 0EFH ; Timer0 preload high byte.
TIMER_RELOAD_L      EQU 0DBH ; Timer0 preload low byte.
TIMER_COUNTS        EQU 4133 ; 10000H - EFDBH.
TICKS_PER_SECOND    EQU 223  ; Software count of Timer0 overflows per second.
NUM_DIGITS          EQU 6    ; Six multiplexed 7-segment digits.

; Reset and interrupt vectors
ORG 0000H
    LJMP MAIN               ; Reset enters the application at MAIN.

ORG 0003H
    CLR TR0                 ; Stop Timer0 while entering the mode-setting UI.
    LJMP MODESELECT         ; INT0 handler entry point.

ORG 000BH
    CLR TR0                 ; Stop the timer before the ISR reloads it.
    LJMP ISRT0              ; Timer0 overflow handler entry point.

; Main initialization and normal operation
ORG 30H
MAIN:
    MOV SP, #STACK_START    ; Move stack away from the default register area.

    ; Initial state/reference values used by the mode-setting UI.
    ; Values 10-19 correspond to the second group of lookup-table patterns.
    MOV 45H, #19
    MOV 46H, #15
    MOV 47H, #19
    MOV 48H, #15
    MOV 49H, #13
    MOV 4AH, #12

    CLR BUZZER              ; Ensure buzzer starts OFF.

    MOV TMOD, #01H          ; Timer0: Mode 1 (16-bit timer), timer operation.
    MOV IE, #83H            ; EA=1, ET0=1, EX0=1: enable global, T0 and INT0.
    MOV DPTR, #BITPATTERN   ; Base address for 7-segment code lookup.

    ; Six live clock/display state bytes held in Register Bank 0 (R0-R5).
    ; The special values 10-19 select the marker/separator form of the digit.
    MOV R0, #2              ; Default starting time of the clock when reset.
    MOV R1, #5
    MOV R2, #19
    MOV R3, #5
    MOV R4, #13
    MOV R5, #2

    ; Timer0 starts from EFDBH and counts to FFFFH before overflow.
    MOV TH0, #TIMER_RELOAD_H
    MOV TL0, #TIMER_RELOAD_L
    SETB TR0                ; Start Timer0.

; ENDLESS: display multiplexing + alarm check
ENDLESS:
    ; Each digit shares P0. The software loads its segment pattern, enables
    ; one digit-select transistor, then disables it before moving on.
    ; This is done in rapid succession to create the illusion of all the
    ; digits being visible at the same time to a human's naked eye.

    ; Refresh Digit 1
    MOV A, R0
    MOVC A, @A+DPTR         ; A = BITPATTERN[R0] from code memory.
    MOV DIGIT, A            ; Put segment pattern on P0.
    SETB TRAN1              ; Enable digit 1.
    CLR TRAN1               ; Disable digit 1.

    ; Refresh Digit 2
    MOV A, R1
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN2
    CLR TRAN2

    ; Refresh Digit 3
    MOV A, R2
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN3
    CLR TRAN3

    ; Refresh Digit 4
    MOV A, R3
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN4
    CLR TRAN4

    ; Refresh Digit 5
    MOV A, R4
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN5
    CLR TRAN5

    ; Refresh Digit 6
    MOV A, R5
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN6
    CLR TRAN6

    ; Alarm comparison.
    ; Switch to Register Bank 1 so R0/R1/R5 can be used as pointers/loop
    ; control without overwriting the six live display values in Bank 0.
    SETB PSW.3              ; RS1=0, RS0=1 -> Register Bank 1.
    MOV R5, #NUM_DIGITS
    MOV R0, #CLOCK_BASE     ; Pointer to live time: 00H-05H.
    MOV R1, #ALARM_BASE     ; Pointer to alarm: 31H-36H.

CONTINUE:
    MOV A, @R0              ; Load current-time byte.
    MOV B, @R1              ; Load corresponding alarm byte.
    CJNE A, B, EXITCHECK    ; Any mismatch -> no alarm.
    INC R0
    INC R1
    DJNZ R5, CONTINUE       ; Repeat for all six bytes.

    ; All six values matched: sound the alarm for a software delay interval.
    SETB BUZZER
    MOV R4, #70 ; Buzzers is ON for about 5 seconds.
LOOP3:
    MOV R3, #255
LOOP2:
    MOV R2, #255
LOOP1:
    DJNZ R2, LOOP1
    DJNZ R3, LOOP2
    DJNZ R4, LOOP3
    CLR BUZZER

EXITCHECK:
    CLR PSW.3               ; Return to Register Bank 0.
    LJMP ENDLESS            ; Continue normal display refreshing.

; Timer0 interrupt service routine: timekeeping
ISRT0:
    ; Reload immediately so the next timer interval starts from the same base.
    MOV TH0, #TIMER_RELOAD_H
    MOV TL0, #TIMER_RELOAD_L
    SETB TR0

    ; Save the interrupted program's PSW, including register-bank selection.
    MOV 0FH, PSW

    ; Force Register Bank 0 for the clock counters.
    CLR PSW.3
    CLR PSW.4

    ; R6 counts Timer0 overflows. 223 overflows form the software one-second
    ; base. Until then, return through the common interrupt-exit code.
    INC R6
    CJNE R6, #TICKS_PER_SECOND, ENDISR1
    MOV R6, #0

    ; Seconds units: R0 = 0..9
    INC R0
    CJNE R0, #10, ENDISR1 ; Reload Digit 1 to 0 if it is 9 currently, or else increase the time by 1 second.
    MOV R0, #0

    ; Seconds tens: R1 = 0..5
    INC R1
    CJNE R1, #6, ENDISR1 ; Reload Digit 2 to 0 if it is 5 currently, or else increase the time by 10 seconds.
    MOV R1, #0

    ; Minutes units: R2 uses the 10..19 lookup-table range so the marker/
    ; separator state is preserved on this position.
    INC R2
    CJNE R2, #20, ENDISR1 ; Reload Digit 3 to 0 if it is 9 currently, or else increase the time by 1 minutes.
    MOV R2, #10

    ; Minutes tens: R3 = 0..5
    INC R3
    CJNE R3, #6, ENDISR1 ; Reload Digit 4 to 0 if it is 5 currently, or else increase the time by 10 minutes.
    MOV R3, #0

    ;--------------------------------------------------------------------------
    ; Hours: R5 = tens, R4 = units.
    ; For 00..19, units run through encoded values 10..19.
    ; For 20..23, the valid unit values are only 10..13.
    ;--------------------------------------------------------------------------
    CJNE R5, #2, NH24

    ; 20..23 -> next value; 24 would be invalid, so wrap to 00.
    INC R4
    CJNE R4, #14, ENDISR1
    MOV R4, #0
    MOV R5, #0
    SJMP ENDISR1

NH24:
    ; 00..19 path.
    INC R4
    CJNE R4, #20, ENDISR1
    MOV R4, #10
    INC R5

; Common path for all Timer0 exits.
ENDISR1:
    MOV R7, 0FH             ; Recover saved PSW value into temporary R7.

ENDISR:
    ; Restore only the register-bank bits needed to return to the interrupted
    ; context. Other PSW bits were intentionally allowed to change in the ISR.
    MOV A, R7
    ANL A, #00011000B       ; Isolate RS1:RS0.
    CJNE A, #0H, NOT0
    SJMP ENDGAME            ; 00 -> Bank 0.

NOT0:
    CJNE A, #08H, NPSW3
    SETB PSW.3              ; 08H -> Bank 1.
    SJMP ENDGAME

NPSW3:
    SETB PSW.4              ; 10H/18H -> select an upper register bank.

ENDGAME:
    RETI                    ; Return from interrupt.

; MODESELECT: choose between time-setting and alarm-setting
ORG 100H
MODESELECT:
    ; Save the interrupted PSW. This routine uses Register Bank 2.
    MOV 17H, PSW
    CLR PSW.3
    CLR PSW.4
    SETB PSW.4              ; RS1=1, RS0=0 -> Register Bank 2.

    LCALL DEBOUNCE

    ; Prepare P2.0/P2.1 as idle-high input-style signals for ALARM/TIMESET.
    MOV P2, #0
    SETB P2.1
    SETB P2.0

AGAIN:
    ; ALARM is active low.
    JB ALARM, NEXT4 ; Check if ALARM button is pressed
    LCALL DEBOUNCE

    ; Copy the six live clock bytes into the alarm edit buffer.
    MOV R6, #NUM_DIGITS
    MOV R0, #CLOCK_BASE
    MOV R1, #ALARM_BASE
TRANSFER:
    MOV A, @R0
    MOV @R1, A
    INC R0
    INC R1
    DJNZ R6, TRANSFER

    ; The alarm edit buffer becomes the working six-digit field.
    MOV R0, #ALARM_BASE
    MOV R1, #ALARM_BASE
    LJMP SETMODE

NEXT4:
    ; TIMESET is active low.
    JB TIMESET, AGAIN ; Check if TIMESET button is pressed
    LCALL DEBOUNCE
    MOV R0, #CLOCK_BASE
    MOV R1, #CLOCK_BASE
    LJMP SETMODE

; SETMODE: six-digit editor

; R0 = currently selected/editing RAM location.
; R1 = base pointer used for display refresh and position tracking.

; LEFT/RIGHT move the selection circularly through six digit positions.
; UP/DOWN alter the selected digit's value while preserving the design's encoded
; separator/marker conventions.
; MODE exits the editor.
SETMODE:
    ; Normalize the working representation around the initially selected digit,
    ; that is, remove the separator dots used in H2 and M2 displays in the
    ; running time display and instead use the dot as a cursor / marker.
    MOV R5, #-10 ; Remove M2 digit's dot
    MOV R4, #2
    LCALL RADDX              ; R0 += R4
    LCALL ADDX               ; @R0 += R5

    MOV R4, #2 ; Remove H2 digit's dot
    LCALL RADDX              ; R0 += 2
    LCALL ADDX               ; @R0 -= 10

    MOV R5, #10 ; Add dot to the original digit position (S2 digit)
    MOV R4, #-4
    LCALL RADDX              ; R0 -= 4
    LCALL ADDX               ; @R0 += 10

CHECK:
    ; LEFT: move selected position rightward in this memory ordering. The
    ; original UI treats the six positions as a circular list and moves the
    ; separator/marker state together with the selection.
    JB LEFT, NEXT0 ; Check if LEFT button is pressed
    LCALL DEBOUNCE

    MOV A, R1
    ADD A, #5
    MOV B, A
    MOV A, R0
    CJNE A, B, NORM0 ; Check if current digit is H1

    ; If current digit is H1, then move the cursor to S2.
    MOV R5, #-10
    LCALL ADDX
    MOV R4, #-5
    LCALL RADDX
    MOV R5, #10
    LCALL ADDX
    SJMP NEXT0

NORM0:
    MOV R5, #-10
    LCALL ADDX
    INC R0
    MOV R5, #10
    LCALL ADDX

NEXT0:
    ; RIGHT: move selection in the opposite direction, with circular wrap.
    JB RIGHT, NEXT1 ; Check if RIGHT button is pressed
    LCALL DEBOUNCE

    MOV B, R1
    MOV A, R0
    CJNE A, B, NORM1 ; Check if current digit is S2

    ; If current digit is S2, then move the cursor to H1 digit.
    MOV R5, #-10
    LCALL ADDX
    MOV R4, #5
    LCALL RADDX
    MOV R5, #10
    LCALL ADDX
    SJMP NEXT1

NORM1:
    MOV R5, #-10
    LCALL ADDX
    DEC R0
    MOV R5, #10
    LCALL ADDX

NEXT1:
    ; UP: normally subtract one from the encoded value. The special value 10
    ; triggers a search through the 45H-4AH reference table to obtain the
    ; position-appropriate encoded state.
    JB UP, NEXT2 ; Check if UP button is pressed
    LCALL DEBOUNCE
    CJNE @R0, #10, NORM2 ; Check if current digit's value is a dotted 0.

    MOV B, R1
    PUSH B                  ; Save current display/base pointer.
    MOV A, R0
    MOV R6, #NUM_DIGITS
    MOV R1, #DISPLAY_REF_BASE

SOMENAME:
    CJNE A, B, NDIGIT ; Check which digit the cursor points to currently.
    MOV A, @R1 ; Transfer the digit's appropriate last value to the display
    MOV @R0, A
    POP B
    MOV R1, B
    SJMP NEXT2

NDIGIT:
    INC B
    INC R1
    DJNZ R6, SOMENAME

NORM2:
    MOV R5, #-1
    LCALL ADDX

NEXT2:
    ; DOWN: search for the position's reference value. If found, set the
    ; selected location to the special zero/marker state (10). Otherwise,
    ; increment the value by one.
    JB DOWN, NEXT3 ; Check if DOWN button is pressed
    LCALL DEBOUNCE

    MOV B, R1
    PUSH B
    MOV R1, #DISPLAY_REF_BASE
    MOV R6, #NUM_DIGITS
    MOV B, @R0

SOMENAME2:
    MOV A, @R1
    CJNE A, B, NDIGIT2 ; Check if the digit is in its last value
    MOV @R0, #10 ; Move the first value if the digit appropriate last value is met.
    POP B
    MOV R1, B
    SJMP NEXT3

NDIGIT2:
    INC R1
    DJNZ R6, SOMENAME2

    POP B
    MOV R1, B
    MOV R5, #1
    LCALL ADDX

NEXT3:
    ; MODE exits the editor. Otherwise refresh all six digits and continue.
    JB MODE, STOPC ; Check if MODE button is pressed
    LCALL DEBOUNCE
    LJMP TERMINATE

STOPC:
    ; While SETMODE owns the CPU, it must perform display refresh itself.
    ; Sweep six positions exactly as ENDLESS does in normal operation.
    MOV A, @R1 ; R1 is for now the display pointer
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN1
    CLR TRAN1

    INC R1
    MOV A, @R1
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN2
    CLR TRAN2

    INC R1
    MOV A, @R1
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN3
    CLR TRAN3

    INC R1
    MOV A, @R1
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN4
    CLR TRAN4

    INC R1
    MOV A, @R1
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN5
    CLR TRAN5

    INC R1
    MOV A, @R1
    MOVC A, @A+DPTR
    MOV DIGIT, A
    SETB TRAN6
    CLR TRAN6

    ; Return R1 to the first position before checking buttons again.
    MOV A, R1
    ADD A, #-5
    MOV R1, A
    LJMP CHECK

; TERMINATE: finish editing and restore normal clock operation
TERMINATE:
    ; Remove the special separator/marker offset from the selected value.
    MOV R5, #-10
    LCALL ADDX

    ; Keep R0 within the valid six-byte field.
    ; CJNE also sets carry for the unsigned comparison when values differ.
    CJNE R0, #30H, COMPARE
COMPARE:
    JC LESSER               ; R0 < 30H -> use the live clock field.
    MOV R0, #ALARM_BASE            ; Otherwise use the alarm field.
    SJMP ENDIT

LESSER:
    MOV R0, #CLOCK_BASE

ENDIT:
    ; Restore the display/selection encoding before leaving SETMODE.
    MOV R5, #10
    MOV R4, #2
    LCALL RADDX
    LCALL ADDX

    MOV R4, #2
    LCALL RADDX
    LCALL ADDX

    ; Return to the saved interrupt context.
    CLR PSW.4
    MOV R7, 17H

    ; Restart Timer0 with the standard preload and return through the common
    ; PSW restoration path before RETI.
    MOV TH0, #TIMER_RELOAD_H
    MOV TL0, #TIMER_RELOAD_L
    SETB TR0
    LJMP ENDISR

; Helper: RADDX - Used during the mode setting ISR to change the digit position
; R0 <- R0 + R4
RADDX:
    MOV A, R0
    ADD A, R4
    MOV R0, A
    RET

; Helper: ADDX - Used during the mode settig ISR to change a digit's value
; @R0 <- @R0 + R5
; Negative values are used as two's-complement immediates to perform subtraction
; using the 8051 ADD instruction.
ADDX:
    MOV A, @R0
    ADD A, R5
    MOV @R0, A
    RET

; Helper: DEBOUNCE
; Software delay used after button events so mechanical contacts have
; time to settle before the next input check.
DEBOUNCE: ; kills about 70 ms of time
    MOV R2, #255
LOOP5:
    MOV R3, #255
LOOP4:
    DJNZ R3, LOOP4
    DJNZ R2, LOOP5
    RET

; Seven-segment lookup table
;
; 0-9  : standard digit patterns
; 10-19: same digit patterns with bit 7 asserted (80H offset), used by the
;        original design for the separator/marker state.
ORG 250H
BITPATTERN:
    DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH
    DB 0BFH,86H, 0DBH,0CFH,0E6H,0EDH,0FDH,087H,0FFH,0EFH

END
