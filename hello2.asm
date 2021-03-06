	JUMPPTR	init

	include inc/macros.i
	include inc/iffparse.i
	include inc/hwequates.i
	include inc/packbits.i

	incdir	INCLUDES:
	include exec/memory.i
	include exec/exec_lib.i
	include libraries/dos.i
	include libraries/dos_lib.i
	include	graphics/graphics_lib.i
	include	hardware/dmabits.i

	SECTION	Initialize,CODE

init:
	;set up the graphics library and the dos library
	M_OpenLibrary	#grafname,_GfxBase
	M_OpenLibrary	#dosname,_DOSBase
	M_OpenLibrary	#iffname,_IFFBase

	M_AllocMem	#16384, #MEMF_FAST
	move.l		d0,skullImagePtr
	M_AllocMem	#32768, #MEMF_CHIP
	move.l		d0,skullFrame1Ptr
	M_AllocMem	#32768, #MEMF_CHIP
	move.l		d0,skullFrame2Ptr
	M_AllocMem	#32768, #MEMF_CHIP
	move.l		d0,skullFrame3Ptr
	M_AllocMem	#32768, #MEMF_CHIP
	move.l		d0,skullFrame4Ptr
	M_AllocMem	#32768, #MEMF_CHIP
	move.l		d0,skullFrame5Ptr

getOldCopper:
	move.l	_GfxBase,a1	;ptr to open graphics library
	move.l	38(a1),oldcopper

openSkullImage:
	JSR	openFrame
;M_OpenFrame skullIFFHandlePtr,skullFileHandle,skullFrame1Ptr,#skullFrame1
	jmp	takeover

.initializeSkullIFF:
	CALLIFF	AllocIFF
	move.l	d0,skullIFFHandlePtr

	move.l	skullIFFHandlePtr,a0
	CALLIFF	InitIFFasDOS	

	move.l	skullFileHandle,iff_Stream(a0)

	move.l	skullIFFHandlePtr,a0
	move.l	IFFF_READ,d0
	CALLIFF	OpenIFF

	move.l	skullFrame1Ptr,a1
	JSR	ProcessIFF

.cleanUpIFF:
	;Close and deallocate the IFF
	move.l	skullIFFHandlePtr,a0
	CALLIFF	CloseIFF
	move.l	skullIFFHandlePtr,a0
	CALLIFF	FreeIFF

	;Close the file handle
	move.l	skullFileHandle,d1
	CALLDOS	Close

takeover:
	move	INTENAR,oldINTENA ;save old INTENA
	move.w	#$7FFF,INTENA	;disable interrupts
	move.l	#CopperList,COP1LCH

	;allocate the bitmap for display
	move.l	#224,d0
	move.l	#190,d1
	move.l	#5,d2
	move.l	#BMF_CLEAR,d3
	add.l	#BMF_DISPLAYABLE,d3
	move.l	#0,a0
	CALLGRAF AllocBitMap
	move.l	d0,skullBitmapPtr

	;Set up the palette
	JSR	ProcessColorChunk

	move.l	skullFrame1Ptr,currentFramePtr

	JSR	SetBitplaneRegisters

SetupAudio:
;	lea	trumpetPtr,a1

;	move.l	a1,$dff0a0	;AUD0LCH
;	move.w	#4000,$dff0a4	;AUD0LEN
;	move.w	#32,$dff0a8	;AUD0VOL
;	move.w	#447,$dff0a6	;AUD0PER

	;Start playback
;	move.w	#(DMAF_SETCLR!DMAF_AUD0!DMAF_MASTER),$dff096

;---frame loop
Demoloop:
	btst	#6,$BFE001	;is the left mouse button clicked?
	bne	Demoloop	;loop forever if not

;---end frame loop

cleanup:
	;Reset the copper
	move.l	oldcopper,COP1LCH
	;Turn on interrupts
	move	oldINTENA,d5
	or	#$8000,d5
	move	d5,INTENA

	;Free memory
	M_FreeMem	skullImagePtr, #16384
;	M_FreeMem	trumpetPtr, #15000

	M_FreeMem	skullFrame1Ptr, #32768
	M_FreeMem	skullFrame2Ptr, #32768
	M_FreeMem	skullFrame3Ptr, #32768
	M_FreeMem	skullFrame4Ptr, #32768
	M_FreeMem	skullFrame5Ptr, #32768

	;Close the libraries
	M_CloseLibrary	_IFFBase
	M_CloseLibrary	_DOSBase
	M_CloseLibrary	_GfxBase

exit:
	rts

SetBitplaneRegisters:
	;Set the copper image data pointers
	move.l	currentFramePtr,skullFrame1Ptr

BPL1:
	move.l	currentFramePtr,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	and	#$FFFF,d0
	move.w	d0,bpl1Ptr

	move.l	currentFramePtr,d0
	and	#$FFFF,d0
	move.w	d0,bpl1Ptr+2

BPL2:
	move.l	currentFramePtr,d0
	add.l	#28,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	and	#$FFFF,d0
	move.w	d0,bpl2Ptr

	move.l	currentFramePtr,d0
	add.l	#28,d0
	and	#$FFFF,d0
	move.w	d0,bpl2Ptr+2

BPL3:
	move.l	currentFramePtr,d0
	add.l	#28,d0
	add.l	#28,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	and	#$FFFF,d0
	move.w	d0,bpl3Ptr

	move.l	currentFramePtr,d0
	add.l	#28,d0
	add.l	#28,d0
	and	#$FFFF,d0
	move.w	d0,bpl3Ptr+2

BPL4:
	move.l	currentFramePtr,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	and	#$FFFF,d0
	move.w	d0,bpl4Ptr

	move.l	currentFramePtr,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	and	#$FFFF,d0
	move.w	d0,bpl4Ptr+2

BPL5:
	move.l	currentFramePtr,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	and	#$FFFF,d0
	move.w	d0,bpl5Ptr

	move.l	currentFramePtr,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	and	#$FFFF,d0
	move.w	d0,bpl5Ptr+2

BPL6:
	move.l	currentFramePtr,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	and	#$FFFF,d0
	move.w	d0,bpl6Ptr

	move.l	currentFramePtr,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	add.l	#28,d0
	and	#$FFFF,d0
	move.w	d0,bpl6Ptr+2

	move.w	bpl1Ptr,CopperImageData+2
	move.w	bpl1Ptr+2,CopperImageData+6
	move.w	bpl2Ptr,CopperImageData+10
	move.w	bpl2Ptr+2,CopperImageData+14
	move.w	bpl3Ptr,CopperImageData+18
	move.w	bpl3Ptr+2,CopperImageData+22
	move.w	bpl4Ptr,CopperImageData+26
	move.w	bpl4Ptr+2,CopperImageData+30
	move.w	bpl5Ptr,CopperImageData+34
	move.w	bpl5Ptr+2,CopperImageData+38
	move.w	bpl6Ptr,CopperImageData+42
	move.w	bpl6Ptr+2,CopperImageData+46

	RTS
	
ProcessIFF:
	PUSHL	a1

	;Set up our stop chunks
	M_DeclareStopChunk	skullIFFHandlePtr, #TYPE_ILBM, #CHNK_BMHD
	M_DeclareStopChunk	skullIFFHandlePtr, #TYPE_ILBM, #CHNK_CMAP
	M_DeclareStopChunk	skullIFFHandlePtr, #TYPE_ILBM, #CHNK_BODY

	;Parse to BMHD
	M_ParseIFF		skullIFFHandlePtr, IFFPARSE_SCAN

	;Read the BMHD chunk
	M_ReadChunkBytes	#BMHD_sizeOf, skullIFFHandlePtr, #skullBMHD

	;Parse to CMAP
	M_ParseIFF		skullIFFHandlePtr, IFFPARSE_SCAN

	;Do something with CMAP
	M_ReadChunkBytes 	#96, skullIFFHandlePtr, skullColors

	;Parse to BODY
	M_ParseIFF		skullIFFHandlePtr, IFFPARSE_SCAN

	;Now we should be at the BODY chunk
	M_ReadChunkBytes	#65535, skullIFFHandlePtr, skullImagePtr
	move.l			d2,compressedLength

	;Decompress the frame into the ptr passed in a6.
	move.l	d0,compressedLength
	POPL	a1 ;destination
	JSR	DecompressSkullImage

	RTS

ProcessColorChunk:
	move.l	#skullColors,a0
	move.l	#$DFF180,a1
	move.b	#31,d7	;32 color entries

.colorLoop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a0)+,d0 ;R
	move.b	(a0)+,d1 ;G
	move.b	(a0)+,d2 ;B

	;4bpp color = shift out the low nybble
	lsr.b	#4,d0
	lsr.b	#4,d1
	lsr.b	#4,d2

	;xxxxRRRRGGGGBBBB
	lsl.w	#8,d0
	lsl.w	#4,d1
	or.w	d1,d0
	or.w	d2,d0

	move.w	d0,(a1)+
	dbra	d7,.colorLoop

	RTS

DecompressSkullImage:
	;Packbits data.
	move.l	skullImagePtr,a0
	;a1 will be the destination
	move.l	compressedLength,d2
	clr.l	d0
	JSR	UnpackBits
	RTS

openFrame:
	move.l	#skullFrame1,d1
	move	#MODE_OLDFILE,d2
	CALLDOS	Open
	move.l	d0,skullFileHandle

	CALLIFF	AllocIFF
	move.l	d0,skullIFFHandlePtr

	move.l	skullIFFHandlePtr,a0
	CALLIFF	InitIFFasDOS
	move.l	skullFileHandle,iff_Stream(a0)

	move.l	skullIFFHandlePtr,a0
	move.l	#IFFF_READ,d0
	CALLIFF	OpenIFF

	move.l	skullFrame1Ptr,a1
	JSR	ProcessIFF

	move.l	skullIFFHandlePtr,a0
	CALLIFF	CloseIFF
	move.l	skullIFFHandlePtr,a0
	CALLIFF	FreeIFF

	move.l	skullFileHandle,d1
	CALLDOS	Close

	RTS

	SECTION	Vars,DATA
	even
skullFileHandle	dc.l	0
	align 0,4
skullFIB	ds.b	512
skullFileSize	dc.l	0
skullIFFHandlePtr	dc.l	0

oldcopper:	dc.l	0

;Library base ptrs
_GfxBase	dc.l	0	;ptr to an open graphics library
_DOSBase	dc.l	0	;ptr to an open dos library
_IFFBase	dc.l	0	;iffparse

;Skull bitmap header
skullBMHD	dc.b	BMHD_sizeOf
;skullColors	ds.b	128	;color palette

	Section	Strings,DATA
dosname:	DOSNAME
grafname:	GRAFNAME
iffname:	dc.b	"iffparse.library",0
loadSkullError	dc.b	"Failed to load SKULL.IFF",13,0
errorGraflib	dc.b	"Failed to open graphics.library",13,0
errorDoslib	dc.b	"Failed to open dos.library",13,0

skullFrame1	dc.b	"SKULL1.IFF",0
skullFrame2	dc.b	"SKULL2.IFF",0
skullFrame3	dc.b	"SKULL3.IFF",0

trumpet		dc.b	"heavy.Trumpet",0

	SECTION ImageBuffers,BSS
skullImagePtr:		ds.l	1
compressedLength:	ds.l	1

	SECTION Palette,DATA_C
skullColors:	dc.b	$02,$02,$34,$32,$02,$11,$32,$02,$0C,$02,$32,$11,$02,$32,$0F,$32
		dc.b	$32,$04,$32,$32,$34,$32,$32,$64,$66,$32,$16,$32,$66,$30,$66,$66
		dc.b	$21,$66,$66,$64,$9A,$66,$24,$9A,$74,$09,$9A,$66,$64,$66,$9A,$57
		dc.b	$9A,$9A,$08,$9A,$92,$6A,$9A,$9A,$6A,$CE,$9A,$61,$CF,$99,$5C,$CE
		dc.b	$9A,$7B,$D8,$C7,$83,$D2,$D6,$92,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	

	SECTION ImageData,BSS_C ;chip memory for copper
oldINTENA	ds.w	1

currentFramePtr ds.l	1
skullFrame1Ptr	ds.l	1
skullFrame2Ptr	ds.l	1
skullFrame3Ptr	ds.l	1
skullFrame4Ptr	ds.l	1
skullFrame5Ptr	ds.l	1

skullBitmapPtr	ds.l	1

bpl1Ptr	ds.l	1
bpl2Ptr	ds.l	1
bpl3Ptr	ds.l	1
bpl4Ptr	ds.l	1
bpl5Ptr	ds.l	1
bpl6Ptr	ds.l	1

	SECTION Audio,DATA_C
	even
trumpetHandle	ds.l	1
sine:		dc.b	0,90,127,90,0,-90,-127,90
trumpetPtr	ds.l	1

	SECTION Copper,DATA_C
frameCounter	dc.w	0

CopperList:
.init:
	dc.w	$1FC,0		;AGA compatibility
	dc.w	$100,$0200	;disable bitplanes while setting up

				;The image is 224x190
	dc.w	$8e,$4e33	;DIWSTRT
	dc.w	$90,$0cA3	;DIWSTOP

	dc.w	$92,$53		;DDFSTRT
	dc.w	$94,$BB		;DDFSTOP

	;dc.w	$108,$80	;bpl odd modulo
	;dc.w	$10a,$80	;bpl even modulo

	dc.w	$108,$70	;28 bytes = 224 bits per bitplane
	dc.w	$10a,$70	;224 bits * 4 bpl = 70 bytes per scanline

CopperImageData:
	dc.w	$e0,$0		;image data ptr, bpl 1
	dc.w	$e2,$0		;image data ptr, bpl 1
	dc.w	$e4,$0		;bpl 2
	dc.w	$e6,$0		;bpl 2
	dc.w	$e8,$0		;bpl 3
	dc.w	$ea,$0		;bpl 3
	dc.w	$ec,$0		;bpl 4
	dc.w	$ee,$0		;bpl 4
	dc.w	$f0,$0		;bpl 5
	dc.w	$f2,$0		;bpl 5
	dc.w	$f4,$0		;bpl 6
	dc.w	$f6,$0		;bpl 6

	dc.w	$2c07,$fffe	;wait for screen
	dc.w	$100,$5200	;enable bpls

	;move data to bitplane ptr

	dc.w	$FFFF,$FFFE
