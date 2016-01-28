Pro InitProjPlots,             $
      Resolution = resolution, $
      Type = type,             $
      PlotMarg = plotmarg,     $
      TBOff = tboff,           $
      TBHeight = tbheight,     $
      Text = text,             $
      PlotTB = plottb,         $
      PBOff = pboff,           $
      _EXTRA = extra
;+++
; NAME:
;	InitProjPlots
; VERSION:
;	1.0
; PURPOSE:
;	To initialize the plot region, including plot resolution, plot
;       margins and a box text container above the plot.
; CALLING SEQUENCE:
;	InitProjPlots( [Resolution], [Type], [PlotMarg], [Text], [TBOff], [TextBoxH],
;                      [PlotTB],[PBOff] )
; KEYWORDS:
;      Resolution - The desired resolution of the plot in pixels.
;                   Resolution = [Xresolution, Yresolution]
;                   Default values are [600, 600].
;        PlotMarg - The margins (left, bottom, right, top) of the plot
;                   in pixels.
;                   Margin = [X0margin, Y0margin, X1margin, Y1margin]
;                   Default values for the margin are 5 pixels.
;            Type - The type of the plot(s) to be produced. Valid types are:
;                   'eps', 'ps', 'bmp', 'jpeg', 'jpg', 'png', 'ppm', 'srf',
;                   'tiff', 'tif'.
;                   The type of the plot determines the plot device as well
;                   that is, types:'eps' and 'ps' mean that the plot device
;                   is set to 'PS' while the rest of plot types set the
;                   device to 'Z'.
;            Text - This is for the text inside the text box (below).
;                   Text = [X0offset, Y0offset, X1offset, Y1offset]
;                   Default values for the offsets are 2 pixels.
;           TBOff - This is an optional text box to be set immediately above
;                   the generated plot. You can write text in this box.
;                   TBOff = [X0offset, Y0offset, X1offset, Y1offset]
;                   Default values for the offsets are 0 pixels.
;        TBHeight - This is height of the text box to be set immediately above
;                   the generated plot.
;                   TBHeight = BoxHeight
;                   Default value is 1.1 * (!D.Y_CH_SIZE + (2 * 2 pixels)).
;          PlotTB - Explicitly set this keyword to calculate the text box
;                   area above the plot either by using the defaults or,
;                   by specifying new values using the TextBox keyword.
;           PBOff - Specify the offsets of the main plot relative to the
;                   margins.
;                   PBOff = [X0offset, Y0offset, X1offset, Y1offset]
;                   Default values for the offsets are 0 pixels.
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

COMMON PlotParams

OldDev  = !D.NAME
OldXRes = !D.X_SIZE
OldYRes = !D.Y_SIZE

; these are local defaults
def_OffSet = 2
min_Size   = 2
max_Size   = 100

;--------- BEGIN:: THE Z-BUFFER DEVICE ----------
; Do all the calculations for the Z-Buffer device and then
; transform the results to the device requested
set_plot, 'Z'

; ----------
; Get the new plot device here.
if n_elements(type) gt 0 then begin
  if ( size(type, /type) ne 7 ) then $
    message, "you need to specify a string value for <Type>."
  type = strlowcase(type)
endif
case n_elements(type) of
     1: begin
         PS_DEVS = ['eps', 'ps']
         Z_DEVS  = ['bmp', 'jpeg', 'jpg', 'png', 'ppm', 'srf', 'tiff', 'tif']
         myPlotDevice = 'Z'
         myPlotType   = 'png'
         idx = where(PS_DEVS eq type, icount)
         if (icount gt 0) then begin
           myPlotDevice = 'PS'
           myPlotType   = type
         endif
         idx = where(Z_DEVS eq type, icount)
         if (icount gt 0) then begin
           myPlotDevice = 'Z'
           myPlotType   = type
         endif
        end
  else: begin
         myPlotDevice = 'Z'
         myPlotType  = 'png'
        end
endcase

; ----------
; Get the overall plot X and Y margins here.
; Default is X margin = Y margin = min_Size pixels.
; Minimum is also X margin = Y margin = min_Size pixels.
myMargin = make_array(4, /integer, value = min_Size)
if n_elements(plotmarg) gt 0 then begin
  idx = where([2, 3, 4, 5, 12, 13] eq size(plotmarg, /type), icount)
  if ( icount eq 0 ) then $
    message, "you need to specify an integer or float value(s) for <Margin>."

  tmparr = ceil(abs(plotmarg))
  sz = min([n_elements(myMargin) -1, n_elements(tmparr) -1])
  idx = where(tmparr[0:sz] le max_Size, icount)
  if (icount gt 0) then myMargin[idx] = tmparr[idx] > min_Size
endif

; ----------
; Get the offsets of the text inside the textbox.
; Default is Text X OffSet = Text Y OffSet = 2 pixels
myText = make_array(4, /integer, value = def_OffSet)
if n_elements(text) gt 0 then begin
  idx = where([2, 3, 4, 5, 12, 13] eq size(text, /type), icount)
  if ( icount eq 0 ) then $
    message, "you need to specify an integer or float value(s) for <Text>."

  tmparr = ceil(abs(text))
  sz = min([n_elements(myText) -1, n_elements(tmparr) -1])
  idx = where(tmparr[0:sz] le max_Size, icount)
  if (icount gt 0) then myText[idx] = tmparr[idx]
endif

; ----------
; Get the offsets of the text box above the plot.
; Default is Text X OffSet = Text Y OffSet = 0 pixels
myTBOff = make_array(4, /integer, value = 0)
if n_elements(tboff) gt 0 then begin
  idx = where([2, 3, 4, 5, 12, 13] eq size(tboff, /type), icount)
  if ( icount eq 0 ) then $
    message, "you need to specify an integer or float value(s) for <TBOff>."

  tmparr = ceil(abs(tboff))
  sz = min([n_elements(tboff) -1, n_elements(tmparr) -1])
  idx = where(tmparr[0:sz] le max_Size, icount)
  if (icount gt 0) then myTBOff[idx] = tmparr[idx]
endif

; ----------
; Get the height of the text box above the plot.
; Default is Text Box Height = 1.1 * (!D.Y_CH_SIZE + (2 * def_OffSet))
myTBHeight = ceil(1.1 * (!D.Y_CH_SIZE + (2 * def_OffSet)))
if (n_elements(tbheight) eq 1) then begin
  idx = where([2, 3, 4, 5, 12, 13] eq size(tbheight, /type), icount)
  if ( icount eq 0 ) then $
    message, "you need to specify an integer or float value for <TBHeight>."

  myTBHeight = ceil(abs(tbheight))
endif
if (myTBHeight eq 0.0) then plottb = 0

; ----------
; Get the offsets of the plot box.
; Default is Plot Box X OffSet = Plot Box Y OffSet = 0 pixels
myPBOff = make_array(4, /integer, value = 0)
if n_elements(pboff) gt 0 then begin
  idx = where([2, 3, 4, 5, 12, 13] eq size(pboff, /type), icount)
  if ( icount eq 0 ) then $
    message, "you need to specify an integer or float value(s) for <PBOff>."

  tmparr = ceil(abs(pboff))
  sz = min([n_elements(myPBOff) -1, n_elements(tmparr) -1])
  idx = where(tmparr[0:sz] le max_Size, icount)
  if (icount gt 0) then myPBOff[idx] = tmparr[idx]
endif

; ----------
; Get the resolution of the image in pixels here.
; Default is 600x600 pixel resolution.
myResolution = make_array(2, /integer, value = 600)
if n_elements(resolution) gt 0 then begin
  idx = where([2, 3, 4, 5, 12, 13] eq size(resolution, /type), icount)
  if ( icount eq 0 ) then $
    message, "you need to specify an integer or float value(s) for <Resolution>."

  tmparr = ceil(abs(resolution))
  sz = min([n_elements(myResolution) -1, n_elements(tmparr) -1])
  myResolution[0:sz] = tmparr[0:sz]
endif
myResolution[1] = myResolution[1] + myTBHeight

; Calculate the plot parameters
device, set_resolution = [myResolution[0], myResolution[1]]

if keyword_set(plottb) then begin
; a) the text box dimensions
  tbX0 = myMargin[0] + myTBOff[0]
  tbX1 = myResolution[0] - (myMargin[2] + myTBOff[2])
  tbY1 = myResolution[1] - (myMargin[3] + myTBOff[3])
  tbY0 = tbY1 - myTBHeight

; b) the text dimensions inside the text box
  tX0  = tbX0 + myText[0]
  tX1  = tbX1 - myText[2]
  tY0  = tbY0 + myText[1] + 0.05 * !D.Y_CH_SIZE
  tY1  = tbY1 - myText[3] - 0.05 * !D.Y_CH_SIZE

; c) the plot box dimensions
  pbX0 = myMargin[0] + myPBOff[0]
  pbX1 = myResolution[0] - (myMargin[2] + myPBOff[2])
  pbY0 = myMargin[1] + myPBOff[1]
  pbY1 = tbY0 - (myTBOff[1] + myPBOff[3])

; d) the whole plot area dimensions
  paX0 = myMargin[0]
  paX1 = myResolution[0] - myMargin[2]
  paY0 = myMargin[1]
  paY1 = myResolution[1] - myMargin[3]
endif else begin
; a) the text box dimensions
  tbX0 = 0
  tbX1 = 0
  tbY1 = 0
  tbY0 = 0

; b) the text dimensions inside the text box
  tX0  = 0
  tX1  = 0
  tY0  = 0
  tY1  = 0

; c) the plot box dimensions
  pbX0 = myMargin[0] + myPBOff[0]
  pbX1 = myResolution[0] - (myMargin[2] + myPBOff[2])
  pbY0 = myMargin[1] + myPBOff[1]
  pbY1 = myResolution[1] - (myMargin[3] + myPBOff[3])

; d) the whole plot area dimensions
  paX0 = myMargin[0]
  paX1 = myResolution[0] - myMargin[2]
  paY0 = myMargin[1]
  paY1 = myResolution[1] - myMargin[3]
endelse

; transform the plot dimensions to normal coordinates
conv_tb = convert_coord([tbX0, tbX1, 0, 0], [0, 0, tbY0, tbY1], /device, /to_normal)
conv_t  = convert_coord([tX0, tX1, 0, 0], [0, 0, tY0, tY1], /device, /to_normal)
conv_pb = convert_coord([pbX0, pbX1, 0, 0], [0, 0, pbY0, pbY1], /device, /to_normal)
conv_pa = convert_coord([paX0, paX1, 0, 0], [0, 0, paY0, paY1], /device, /to_normal)

PlotTitleBox  = [conv_tb[0,0], conv_tb[1,2], conv_tb[0,1], conv_tb[1,3]]
PlotTitleText = [conv_t[0,0],  conv_t[1,2],  conv_t[0,1],  conv_t[1,3]]
PlotBox       = [conv_pb[0,0], conv_pb[1,2], conv_pb[0,1], conv_pb[1,3]]
PlotAreaBox   = [conv_pa[0,0], conv_pa[1,2], conv_pa[0,1], conv_pa[1,3]]

if (myPlotDevice eq 'PS') then begin
  pageInfo = pswindow(_STRICT_EXTRA = extra)
endif

device, set_resolution = [OldXRes, OldYRes]
device, /close
;---------- END:: THE Z-BUFFER DEVICE -----------

; Set the plotting device values
OldPlotDev = OldDev
PlotDev = myPlotDevice
DevResolution = myResolution
DevStatus = 0
DevPlotType = myPlotType

case strupcase(PlotDev) of
   'PS': begin
           defCharsize = 0.8
           defColor    = 1
           defFontSize = 12
           defThick    = 1.0
           TextSize    = defCharsize
           RebinFactor = 1.0
         end
    'Z': begin
           defCharsize = 0.8
           defColor    = 1
           defFontSize = 10
           defThick    = 1.0
           TextSize    = defCharsize
           RebinFactor = 4.0
         end
  else: begin
          defCharsize = 0.8
          defColor    = 1
          defFontSize = 12
          defThick    = 1.0
          TextSize    = defCharsize
          RebinFactor = 1.0
        end
endcase

set_plot, OldDev

end
