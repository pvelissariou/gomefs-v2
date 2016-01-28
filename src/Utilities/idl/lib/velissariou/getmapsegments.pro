FUNCTION GetMapIndex,indx, error
;
; Used to read in the index file for
; each map data file.  On successful completion, error is set to 0.
;
COMPILE_OPT HIDDEN, IDL2

openr, lun, indx, /xdr, /get_lun, error = error
if error ne 0 then return, 0		;File not there or unreadable
segments=0L & readu, lun, segments
dx_map=replicate({ fptr:0L, npts:0L,latmax:0.,latmin:0.,$
                   lonmax:0.,lonmin:0. }, segments )
readu, lun, dx_map & free_lun, lun
free_lun,lun
return, dx_map
END

; -----------------------------------------------------------------------------
FUNCTION GetMapSegments, fnames, name, hires, bounds
; Output a segment file:
; fnames = [lowresname, hiresname]
; name = description for error message (boundaries, rivers, etc.
; hires = 0 for low res, 1 for hires
; bounds = lat/lon bound.

; Hires = 1 to do hires, 0 for low

Compile_Opt IDL2

lun = -1
sub = (['low', 'high'])[hires]
fndx = FILEPATH(fnames[hires]+'.ndx', SUBDIR=['resource','maps',sub])
dat =  FILEPATH(fnames[hires]+'.dat', SUBDIR=['resource','maps',sub])
ndx = GetMapIndex(fndx, error)		;OPEN it
if error eq 0 then openr, lun, dat,/xdr,/stream, /get, error = error
if (error ne 0) and hires then begin 	;Try low res as a fallback
    message, 'High Res Map File: '+name+' not found, trying low res.', /INFO
    fndx = FILEPATH(fnames[0]+'.ndx', SUBDIR=['resource','maps','low'])
    dat =  FILEPATH(fnames[0]+'.dat', SUBDIR=['resource','maps','low'])
    ndx = GetMapIndex(fndx, error)		;OPEN it
    endif			;Hires
if lun lt 0 then openr, lun, dat,/xdr,/stream, /get, error = error
if error ne 0 then message, 'Map file:'+fnames[hires]+' not found'

; Output a bunch of segments from a standard format file.
lonmin = bounds[0]
lonmax = bounds[2]
latmin = bounds[1]
latmax = bounds[3]

;This shouldn't be necessary, but people do sometimes provide screwey inputs:
while lonmin gt 180 do lonmin = lonmin - 360.
while lonmin lt -180 do lonmin = lonmin + 360.
while lonmax gt 180 do lonmax = lonmax - 360.
while lonmax lt lonmin do lonmax = lonmax + 360.

test_lon = ((lonmax-lonmin) mod 360.) ne 0.0
test_lat = (latmin gt -90. or latmax lt 90.) and (latmin ne latmax)

; Prune segments if bounds are set.
if test_lon then begin          ;Longitude ranges are tricky.
                                ; This relies on the following:
                                ;   -180 le lonmin le 180  and
                                ;   -180 le ndx.lonmin le 180 and
                                ;   ndx.lonmax  > ndx.lonmin  and
                                ;   lonmax > lonmin
    x0 = ndx.lonmax - lonmin    ;nmax > lonmin
    good = where(x0 lt 0.0, count)
    if count ne 0 then x0[good] = x0[good] + 360.
    x1 = lonmax - ndx.lonmin    ;nmin < lonmax
    if count ne 0 then x1[good] = x1[good] - 360.
    good = (x0 le (lonmax-lonmin)) or (x1 gt 0)

    if test_lat then begin      ;test lat & lon
        subs = where((ndx.latmin lt latmax) and (ndx.latmax gt latmin) and $
                     good, count)
        if count ne 0 then ndx = ndx[subs]
    endif else begin            ;lon only
        subs = where(good, count)
        if count ne 0 then ndx = ndx[subs]
    endelse
endif else if test_lat then begin ;Lat only
    subs = where((ndx.latmin lt latmax) and (ndx.latmax gt latmin), count)
    if count ne 0 then ndx = ndx[subs]
endif else count = n_elements(ndx) ;test neither

; ************** Get the segments ***************************
;
if count gt 0 then begin

  xy_out = -1

  for i=0, count-1 do begin
    point_lun, lun, ndx[i].fptr

    if ndx[i].npts lt 2 then $
        continue

    xy=fltarr(2,ndx[i].npts, /NOZERO)
    readu,lun,xy
    xy = REVERSE(xy)

    if (i eq 0) then begin
      tmparr1 = transpose(xy[0, *])
      tmparr2 = transpose(xy[1, *])
    endif else begin
      tmparr1 = [tmparr1, transpose(xy[0, *])]
      tmparr2 = [tmparr2, transpose(xy[1, *])]
    endelse
  endfor
  xy_out = [transpose(tmparr1), transpose(tmparr2)]

  idx_xy = where(((xy_out[0, *] ge lonmin) and (xy_out[0, *] le lonmax) and $
                 (xy_out[1, *] ge latmin) and (xy_out[1, *] le latmax)), icnt_xy)
  if (icnt_xy ne 0) then begin
    tmparr = fltarr(2, icnt_xy)
    tmparr[0, *] = xy_out[0, idx_xy]
    tmparr[1, *] = xy_out[1, idx_xy]
    xy_out = tmparr
  endif
endif

FREE_LUN, lun

return, xy_out

end
