enable_dtvextensions	.macro

			lda #$01	
			sta $D03F	;Enable extended features

.endm

;--------------------------------------------------------------------------------

enable_burstmode_skipcycles .macro
			sei
			sac #$99	;enable burstmode and skipcycles
			lda #%00000011
			sac #$00	;
			cli
.endm

;--------------------------------------------------------------------------------

disable_burstmode_skipcycles	.macro
			sei
			sac #$99	;disable burstmode and skipcycles
			lda #%00000000
			sac #$00	;
			cli
.endm

;--------------------------------------------------------------------------------

enable_burstmode	.macro
			sei
			sac #$99	;enable burstmode
			lda #%00000010
			sac #$00	;
			cli
.endm

;--------------------------------------------------------------------------------

set_videomode8pp	.macro


			lda #$55
			sta $D03C	;Enable Linear Mode
			lda #$5B
			sta $D011	
			lda #$18
			sta $D016
			lda #$08
			sta $D04C	;Stepping=8
.endm

;--------------------------------------------------------------------------------

set_pal16gray		.macro

			LDY #$00	;Define first 16 palette colors
-			TYA	
			sta $D200,Y
			INY
			CPY #$10
			BNE	-

.endm

;--------------------------------------------------------------------------------


set_pal16black		.macro

			LDY #$00	;Define first 16 palette colors
			tya
-				
			sta $D200,Y
			INY
			CPY #$10
			BNE	-
.endm

;--------------------------------------------------------------------------------
set_pal16white		.macro

			LDY #$00	;Define first 16 palette colors
			lda #$0f
-				
			sta $D200,Y
			INY
			CPY #$10
			BNE	-
.endm

;--------------------------------------------------------------------------------

show_bank		.macro
			lda #$00
			sta $D049	;Screen location LOW
			lda #$00
			sta $D04A	;Screen location MID
			lda \1
			sta $D04B	;Screen location HIGH
.endm

;--------------------------------------------------------------------------------
wait_dma		.macro

-			lda $D31F	;Wait for DMA to finish
			AND #$01
			CMP #$00
			BNE -
.endm
;--------------------------------------------------------------------------------

dma_memcopy		.macro

			lda #$00	
			sta $D300	;Set source low
			lda #$00
			sta $D301	;Set source Mid
			lda \1
			sta $D302	;Set source high
			lda #$00
			sta $D303	;Set Dest low
			lda #$00
			sta $D304	;Set Dest Mid
			lda \2
			sta $D305	;Set Dest High
			lda #$01
			sta $D306	;Set Source Step Low
			lda #$00
			sta $D307	;Set Source Step High
			lda #$01
			sta $D308	;Set Dest Step Low
			lda #$00
			sta $D309	;Set Dest Step High
			lda #<64000	
			sta $D30A	;Set Length Low
			lda #>64000
			sta $D30B	;Set Length High
			lda #$0D
			sta $D31F	;start transfer

-			lda $D31F	;Wait for DMA to finish
			AND #$01
			CMP #$00
			BNE -
.endm
;--------------------------------------------------------------------------------

clearbitmap		.macro

			lda #<PC	
			sta $D300	;Set source low
			lda #>PC
			sta $D301	;Set source Mid
			lda #$40
			sta $D302	;Set source high
			lda #$00
			sta $D303	;Set Dest low
			lda #$00
			sta $D304	;Set Dest Mid
			lda \1
			sta $D305	;Set Dest High
			lda #$00
			sta $D306	;Set Source Step Low
			lda #$00
			sta $D307	;Set Source Step High
			lda #$01
			sta $D308	;Set Dest Step Low
			lda #$00
			sta $D309	;Set Dest Step High
			lda #<$ffff	
			sta $D30A	;Set Length Low
			lda #>$ffff
			sta $D30B	;Set Length High
			lda #$0D
			sta $D31F	;start transfer

-			lda $D31F	;Wait for DMA to finish
			AND #$01
			CMP #$00
			BNE -
.endm
;--------------------------------------------------------------------------------
wait_vbl		.macro

-
			lda	$d011
			bpl	-
-
			lda	$d011
			bmi	-
.endm
;--------------------------------------------------------------------------------


push_regs		.macro
			pha
			txa
			pha
			tya
			pha

.endm
;--------------------------------------------------------------------------------

pull_regs		.macro
			pla
			tay
			pla
			tax
			pla

.endm
;--------------------------------------------------------------------------------
