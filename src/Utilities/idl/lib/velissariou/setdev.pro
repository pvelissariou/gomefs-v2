PRO SetDev,               $
      OpenDev = opendev,  $
      CloseDev = closedev
;+++
; NAME:
;	SetDev
; VERSION:
;	1.0
; PURPOSE:
;	To open or, close the plotting device. The requested device
;       has to be initialized first by calling InitProjPlots
; CALLING SEQUENCE:
;	SetDev( [/opendev], [/closedev] )
; KEYWORDS:
;         OpenDev - Use this keyword to open the device.
;        CloseDev - Use this keyword to close the device.
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created February 16 2006 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

COMMON PlotParams

if(n_elements(DevStatus) eq 0) then begin
  message, 'the requested device has not been initialized', /continue
  message, 'call first "InitProjPlots" to initialize the device'
endif

; Check for the supplied keywords
opendev  = keyword_set(opendev)
closedev = keyword_set(closedev)

if opendev + closedev eq 0 then $
  message, 'set one of /OPENDEV, /CLOSEDEV'

if opendev + closedev gt 1 then $
  message, 'set only one of /OPENDEV, /CLOSEDEV'

if(opendev and DevStatus) then $
  message, 'the requested device is already open'

if(closedev and ~DevStatus) then $
  message, 'the requested device is already closed'

if(opendev) then begin
  OldPlotDev = !D.NAME

  set_plot, PlotDev

  if (PlotDev eq 'PS') then begin
    device, _Extra = pageInfo
    device, /color, bits_per_pixel = 8
    device, /helvetica, font_size = defFontSize
    !P.CHARSIZE   = defCharsize
    !P.BACKGROUND = 0
    !P.COLOR      = defColor
    !P.FONT       = 0
    !P.MULTI      = 0
    !P.THICK      = defThick
    TextSize      = defCharsize
    if (strlowcase(DevPlotType) eq 'eps') then begin
      device, /encapsulated, preview = 1
    endif
  endif else begin
; The next keyword enables and disables the Z-buffering. If this keyword is specified
; with a zero value, the driver operates as a standard 2-D device, the Z-buffering is
; disabled, and the Z-buffer (if any) is deallocated. Setting this keyword to one
; (the default value), enables the Z-buffering. 
; To disable Z-buffering enter:
    device, z_buffering = 0
    device, set_resolution = RebinFactor * DevResolution
    device, set_font = 'Helvetica', /tt_font, $
            set_character_size = [RebinFactor * defFontSize, RebinFactor * defFontSize]
    !P.CHARSIZE   = defCharsize
    !P.BACKGROUND = 0
    !P.COLOR      = defColor
    !P.FONT       = 1
    !P.MULTI      = 0
    !P.THICK      = defThick
    TextSize      = defCharsize 
  endelse

  !P.POSITION = PlotBox
  DevStatus = 1
endif

if(closedev) then begin
  device, /close
  DevStatus = 0
  set_plot, OldPlotDev
endif

end
