PC		= $0337
zp_curbank	= $f0
zp_mem_y	= $f1
zp_twist_add	= $f2
zp_texture_add	= $f3

zp_bank1	= $b0
zp_bank2	= $b1
;-------------------------------------------------------

.cpu 65dtv02
;-------------------------------------------------------


.include		i_dtv.asm

;-------------------------------------------------------


;			*=$0801
;
;			.word ss,2008
;			.null $9e,^start_demo
;ss			.word 0


;start_demo	

			*=$0400
			.binary "decrunching.sc1"


			*=$0800
			.binary "decrunching.chr"

			*=$0e00


			lda #$13
			sta $d018
			lda #$c8
			sta $d016
			lda #$1b
			sta $d011

			lda #$00
			sta $d020
			sta $d021
			ldx #0
			lda #1
-
			sta $d800,x
			sta $d900,x
			sta $da00,x
			sta $db00,x
			inx
			bne -

	
+
;			lda #$0b
;			sta $d011

			lda #$50
			sta zp_bank1
			lda #$51
			sta zp_bank2

			lda #$0f
			sta color_1
			sta color_2
			sta color_3

			lda #0
			sta $0334
			sta $0335
			sta $0336
			sta $0340
			sta $0341
			jsr new_effect


			jsr $8048

			ldx #0
-
			lda twistsin,x
			sta twistsin+256,x

			inx
			bne -

			#enable_dtvextensions
			#enable_burstmode_skipcycles

			sei
			lda #$36
			sta $1
			cli

			lda #<krista_picture
			ldx #>krista_picture
			ldy #$00
			jsr set_depacker_source
			lda #$00
			ldx #$00
			ldy #$42 ;zp_curbank
			jsr set_depacker_dest
			jsr depack

			lda #<twistmap_picture
			ldx #>twistmap_picture
			ldy #$00
			jsr set_depacker_source
			lda #$00
			ldx #$00
			ldy #$43 ;zp_curbank
			jsr set_depacker_dest
			jsr depack

;
;			lda #<vinger_picture
;			ldx #>vinger_picture
;			ldy #$00
;			jsr set_depacker_source
;			lda #$00
;			ldx #$00
;			ldy #$44 ;zp_curbank
;			jsr set_depacker_dest
;			jsr depack


			lda #<silicon_picture
			ldx #>silicon_picture
			ldy #$00
			jsr set_depacker_source
			lda #$00
			ldx #$00
			ldy #$46 ;zp_curbank
			jsr set_depacker_dest
			jsr depack

			sei
;			lda #$34
;			sta $1
;			
;
;			ldy #0
;x1
;			ldx #0
;
;-
;o1=*+2
;			lda tatchick_picture,x
;o2=*+2
;			sta krista_picture,x
;			inx
;			bne -
;			inc o1
;			inc o2
;			iny
;			cpy #$1a
;			bne x1
;
;
;			lda #$36
;			sta $1
;			cli
;
;			lda #<krista_picture
;			ldx #>krista_picture
;			ldy #$00
;			jsr set_depacker_source
;			lda #$00
;			ldx #$00
;			ldy #$49 ;zp_curbank
;			jsr set_depacker_dest
;			jsr depack
;
			lda #$0b
			sta $d011		; scherm uit

			#dma_memcopy #$42,zp_bank1
			#dma_memcopy #$42,zp_bank2
;
;			#dma_memcopy #$44,#$52 ;zp_bank1
			#dma_memcopy #$44,#$53 ;zp_bank2

			lda #$33
			sta PC
			#clearbitmap #$45
			#clearbitmap #$47

			lda #$0f
			sta PC
			#clearbitmap #$48

			lda #$0f
			sta $d020
			sta $d021

			#set_videomode8pp
;			#set_pal16gray
			#set_pal16black
			#show_bank #$46

			lda #$00
			sta $0334		; is vernietigd door statusbar in decrunch
			sta $0335

			sei
 
			lda #<irq
			ldy #>irq
			sta $fffe
			sty $ffff

			lda #<brkirq
			ldy #>brkirq
			sta $fffa
			sty $fffb

			lda #$7f
			sta $dc0d
			sta $dd0d

			lda #$00
			sta $d012
			lda #$5b
			sta $d011
			lda #$01
			sta $d019
			sta $d01a
			lda $dc0d	;ack any pending timer irq
			lda $dd0d	;at cia #2 too
			lda #$35
			sta $01
			cli
;----------------------------------------------------------------------
outerloop		jmp *

;----------------------------------------------------------------------

.align $0100

dothetwist

do_loop
			ldy #0
			ldx #0

			#wait_vbl

			#show_bank zp_bank1

			
			lda zp_bank2	;#$42
			sta $D305	;Set Dest High
			lda #$45	
			sta $D302	;Set source high


			lda #$01
			sta $D306	;Set Source Step Low
			sta $D308	;Set Dest Step Low

			lda #$00
			sta $D307	;Set Source Step High
			sta $D309	;Set Dest Step High

;			lda #>70	; is immers al 0
			sta $D30B	;Set Length High

			lda #<70	
			sta $D30A	;Set Length Low


			;clc
twister_loop

.rept 100

			inc *+6
			sty zp_mem_y
			lda twistsin,x
			adc twistsin,y
			tay
			lda lo_texture,y
			sta $D300	;Set source low
			lda hi_texture,y
			sta $D301	;Set source Mid
			ldy zp_mem_y
			lda lo_bitmap,y
			sta $D303	;Set Dest low
			lda hi_bitmap,y
			sta $D304	;Set Dest Mid
			lda #$0D
			sta $D31F	;start transfer
-			lda $D31F	;Wait for DMA to finish
	;		AND #$01
	;		CMP #$00
			BNE -

			inx
			iny
			iny
;			cpy #200
;			bne twister_loop
.next

			* = * - 3
			lda do_loop+1
			eor #1
			sta do_loop+1
			bne +
			ldx zp_bank1
			ldy zp_bank2
			sty zp_bank1
			stx zp_bank2
+

back_to_do_loop

			lda #$45	
			sta $D305	;Set Dest High
			lda #$43	
			sta $D302	;Set source high


			lda #$01
			sta $D306	;Set Source Step Low
			sta $D308	;Set Dest Step Low

			lda #$00
			sta $D307	;Set Source Step High
			sta $D309	;Set Dest Step High

;			lda #>70	; is immers al 0
			sta $D30B	;Set Length High

			lda #<70	
			sta $D30A	;Set Length Low
			
bla=*+1
			ldy #0
			lda lo_texture,y
			sta $D300	;Set source low
			sta $D303	;Set Dest low
			lda hi_texture,y
			sta $D301	;Set source Mid
			sta $D304	;Set Dest Mid

			lda #$0D
			sta $D31F	;start transfer
-			lda $D31F	;Wait for DMA to finish
	;		AND #$01
	;		CMP #$00
			BNE -

			inc bla
			lda bla
			beq +

			jmp do_loop

+
			lda #$4c
			sta back_to_do_loop
			lda #<do_loop
			sta back_to_do_loop+1
			lda #>do_loop
			sta back_to_do_loop+2
			jmp do_loop

;----------------------------------------------------------------------


irq

			#push_regs
			jsr democontrol
			jsr $8021
color_1=*+1
			lda #0
			sta $d020

			lda #$32
			sta $d012
			lda #<irq2
			ldy #>irq2
			sta $fffe
			sty $ffff
			lda #1
			sta $d019
			#pull_regs
			rti

irq2
			#push_regs
			ldx #46
-			dex
			bne -

color_2=*+1
			lda #$33
			sta $d020

			lda #$fa
			sta $d012
			lda #<irq3
			ldy #>irq3
			sta $fffe
			sty $ffff

			lda #$01
			sta $d019

			#pull_regs
			rti
irq3
			#push_regs
			ldx #44
			dex
			bne *-1
color_3=*+1
			lda #$00
			sta $d020
			lda #$00
			sta $d012
			lda #<irq
			ldy #>irq
			sta $fffe
			sty $ffff

			lda #$01
			sta $d019
			#pull_regs

brkirq
			rti
;-------------------------------------------------------
democontrol
			jsr fadein_logo
			jsr fadeout_logo
			jsr fadeout_colors

			lda $0335
			sec
			sbc #$2
			and #7
			sta $0335
			bcc +
			rts
+
			lda $0336
			beq do_effect
			dec $0336
			rts
do_effect
			lda fx_count
			beq effect_1
			cmp #1
			beq effect_2
			cmp #2
			beq effect_3
			cmp #3
			beq effect_4
			cmp #4
			beq effect_5
			cmp #5
			beq effect_6
			cmp #6
			beq effect_7
			rts
effect_1
			lda #$ea
			sta fadein_logo
			rts

effect_2
			lda #$ea
			sta fadeout_logo
			rts
effect_3
			lda #$ea
			sta fadeout_colors
			rts
effect_4
			#show_bank #$42
			lda #$0f
			sta $d20f
			inc fx_count
			jsr new_effect

			rts
effect_5
			lda #<dothetwist
			ldy #>dothetwist+1
			sta outerloop+1
			sty outerloop+2

			inc fx_count
			jsr new_effect

			rts

effect_6
			lda #$04
			sta $d04c

			inc fx_count
			jsr new_effect

			rts

effect_7
;			lda #$52
;			sta zp_bank1
;			lda #$53
;			sta zp_bank2		; aanpassen voor die twister loop ipv bug

			lda #$08
			sta $d04c

;			lda #<outerloop
;			ldy #>outerloop+1
;			sta outerloop+1
;			sty outerloop+2
;			sta do_loop+1
;			sty do_loop+2
;			lda #$4c
;			sta do_loop
;
;			lda #$0f
;			sta color_2
;			#show_bank #$44		; vinger pic

			
			lda fx_count
			sec
			sbc #2
			sta fx_count

			jsr new_effect

			rts


new_effect
			ldx fx_count
			lda fx_delay,x
			sta $0336
			rts

fx_count		.byte 0
fx_delay		.byte 75
			.byte 52
			.byte 5
			.byte 10
			.byte 40
			.byte 255	; twister
			.byte 128	; twister + stepping
			.byte 80
			.byte 255,255,255,255,255,255,255
;-------------------------------------------------------

fadein_logo
			rts
			lda $0334
			sec
			sbc #2
			and #7
			sta $0334
			bcc +
			rts
+
fadecount=*+1
			ldy #0
			tya
-
			
			sta $d200,y
			iny
			cpy #16
			bne -
			lda fadecount
			cmp #15
			beq quitfadein
			inc fadecount
			rts
quitfadein
			lda #$60
			sta fadein_logo
			inc fx_count
			jsr new_effect
			rts

;-------------------------------------------------------
fadeout_logo
			rts
			lda $0334
			sec
			sbc #2
			and #7
			sta $0334
			bcc +
			rts
+
fadecount1=*+1
			ldx #$0f
-
			
			lda fadetab,x
			sta $d200,x
			inc fadetab,x
			dex
			bpl -

			lda fadecount1
			beq quitfadeout
			dec fadecount1

			rts
quitfadeout
			lda #$60
			sta fadeout_logo
			inc fx_count
			jsr new_effect
			#show_bank #$48
			#set_pal16gray
			rts

fadetab			.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

;-------------------------------------------------------
fadeout_colors
			rts
			lda $0334
			sec
			sbc #2
			and #7
			sta $0334
			bcc +
			rts
+
fadecount2=*+1
			ldx #19
			lda fadecol1,x
			sta color_1
			sta color_3
			lda fadecol3,x
			sta color_2
			sta $d20f

			lda fadecount2
			beq +
			dec fadecount2
			rts
+
			lda #$60
			sta fadeout_colors
			inc fx_count
			jsr new_effect
			rts

fadecol1		.byte 0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
fadecol3		.byte $33,$32,$31,$30,$00,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
;-------------------------------------------------------
;-------------------------------------------------------

.include		exomizer_depacker.asm
;-------------------------------------------------------


.align 256
lo_texture

		    	.for ue=0,ue<256,ue=ue+1
    			.byte <ue*256
    			.next


.align 256
hi_texture
		    	.for ue=0,ue<256,ue=ue+1
    			.byte >ue*256
    			.next

;-------------------------------------------------------
.align 256
lo_bitmap

		    	.for ue=0,ue<256,ue=ue+1
    			.byte <ue*320+40
    			.next


.align 256
hi_bitmap
		    	.for ue=0,ue<256,ue=ue+1
    			.byte >ue*320+40
    			.next

.align 256
twistsin

.include		twistsin.asm
			.rept	256
				.byte 0
			.next

krista_picture
.binary			"krista.exo"


silicon_picture
.binary			"silicon.exo"




;-------------------------------------------------------

*=$8000

.binary			"music\saturday.prg",2

;-------------------------------------------------------

twistmap_picture
.binary			"twistmap.exo"

;vinger_picture
;.binary			"vinger.exo"

;*=$d000
;tatchick_picture
;.binary			"tatchchick.exo"
