Function NAVD88toIGLD85, HT_atLOC, GR_atLOC, HC_atLOC
;+++
; NAME:
;	NAVD88toIGLD85
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the IGLD85 height given the NAVD88 height, the Gravity
;       and the Hydraulic correction
; CALLING SEQUENCE:
;	NAVD88toIGLD85(HT_atLOC, GR_atLOC, HC_atLOC)
;	 HT_atLOC - The water elevation (m) referenced to NAVD88 at a location
;	 GR_atLOC - The gravity at the free surface (gals) at a location
;        HC_atLOC - The hydraulic correction (m) at a location
;
; RETURNS:
;               0 - If no entries found with values equal to "mask"
;               1 - If entries found with values equal to "mask"
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

; constants
  AA = 0.0000425D
  GG = 980.6199D ; gals

; input
  NAVD = Double(HT_atLOC)
  GRAV = Double(GR_atLOC)
  HCOR = Double(HC_atLOC)

  DH = NAVD * GRAV + AA * NAVD * NAVD
  DH = DH / GG

  IGLD = DH + HCOR

  return, IGLD

end
