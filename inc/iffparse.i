	RSRESET
iff_Stream	RS.L	0	;ULONG
iff_Flags	RS.L	0	;ULONG
iff_Depth	RS.L	0	;LONG

; Bit masks for "iff_Flags" field
IFFF_READ       equ 0                     ; read mode - default
IFFF_WRITE      equ 1                     ; write mode
IFFF_RWBITS     equ IFFF_READ!IFFF_WRITE  ; read/write bits
IFFF_FSEEK      equ 1<<1                  ; forward seek only
IFFF_RSEEK      equ 1<<2                  ; random seek
IFFF_RESERVED   equ $FFFF0000             ; Don't touch these bits

; IFF return codes. Most functions return either zero for success or
; one of these codes. The exceptions are the read/write functions which
; return positive values for number of bytes or records read or written,
; or a negative error code. Some of these codes are not errors per sae,
; but valid conditions such as EOF or EOC (End of Chunk).
;
IFFERR_EOF	  equ -1      ; Reached logical end of file
IFFERR_EOC	  equ -2      ; About to leave context
IFFERR_NOSCOPE	  equ -3      ; No valid scope for property
IFFERR_NOMEM	  equ -4      ; Internal memory alloc failed
IFFERR_READ	  equ -5      ; Stream read error
IFFERR_WRITE	  equ -6      ; Stream write error
IFFERR_SEEK	  equ -7      ; Stream seek error
IFFERR_MANGLED	  equ -8      ; Data in file is corrupt
IFFERR_SYNTAX	  equ -9      ; IFF syntax error
IFFERR_NOTIFF	  equ -10     ; Not an IFF file
IFFERR_NOHOOK	  equ -11     ; No call-back hook provided
IFF_RETURN2CLIENT equ -12     ; Client handler normal return

; Universal IFF identifiers
ID_FORM	     equ 'FORM'
ID_LIST	     equ 'LIST'
ID_CAT		     equ 'CAT '
ID_PROP	     equ 'PROP'
ID_NULL	     equ '    '

; Identifier codes for universally recognized local context items.
IFFLCI_PROP	     equ 'prop'
IFFLCI_COLLECTION    equ 'coll'
IFFLCI_ENTRYHANDLER  equ 'enhd'
IFFLCI_EXITHANDLER   equ 'exhd'

;---------------------------------------------------------------------------

; Control modes for ParseIFF() function
IFFPARSE_SCAN	 equ 0
IFFPARSE_STEP	 equ 1
IFFPARSE_RAWSTEP equ 2

;---------------------------------------------------------------------------

; Control modes for StoreLocalItem() function
IFFSLI_ROOT  equ 1	; Store in default context
IFFSLI_TOP   equ 2	; Store in current context
IFFSLI_PROP  equ 3	; Store in topmost FORM or LIST

;---------------------------------------------------------------------------

; Magic value for writing functions. If you pass this value in as a size
; to PushChunk() when writing a file, the parser will figure out the
; size of the chunk for you. If you know the size, is it better to
; provide as it makes things faster.
;
IFFSIZE_UNKNOWN equ -1

;---------------------------------------------------------------------------

; Possible call-back command values
;
IFFCMD_INIT	equ 0	; Prepare your stream for a session
IFFCMD_CLEANUP	equ 1	; Terminate stream session
IFFCMD_READ	equ 2	; Read bytes from stream
IFFCMD_WRITE	equ 3	; Write bytes to stream
IFFCMD_SEEK	equ 4	; Seek on stream
IFFCMD_ENTRY	equ 5	; You just entered a new context
IFFCMD_EXIT	equ 6	; You're about to leave a context
IFFCMD_PURGELCI equ 7   ; Purge a LocalContextItem

;---------------------------------------------------------------------------
_LVOAllocIFF		= -30
_LVOOpenIFF			= -36
_LVOParseIFF		= -42
_LVOCloseIFF		= -48
_LVOFreeIFF			= -54

_LVOReadChunkBytes	= -60

_LVOPropChunk		= -114
_LVOPropChunks		= -120
_LVOStopChunk		= -126
_LVOStopChunks		= -132
_LVOCollectionChunk	= -138
_LVOCollectionChunks= -144
_LVOStopOnExit		= -150

_LVOFindProp		= -156
_LVOFindCollection	= -162
_LVOFindPropContext = -168
_LVOCurrentChunk	= -174
_LVOParentChunk		= -180

_LVOInitIFFasDOS	= -234

CALLIFF	MACRO
	MOVE.L	_IFFBase,A6
	JSR	_LVO\1(A6)
	ENDM

;Stored property
	RSRESET
SPROP_Size		rs.l	0
SPROP_Data		rs.l	0 ;Ptr
	
;ILBM structs
BMHD_sizeOf		equ		20
	RSRESET
BMHD_w			rs.w	0
BMHD_h			rs.w	0
BMHD_x			rs.w	0
BMHD_y			rs.w	0
BMHD_nPlanes	rs.b	0
BMHD_masking	rs.b	0
BMHD_compression rs.b	0
BMHD_pad1		rs.b	0
BMHD_transparentColor	rs.w	0
BMHD_xAspect	rs.b	0
BMHD_yAspect	rs.b	0
BMHD_pageWidth	rs.w	0
BMHD_pageHeight	rs.w	0