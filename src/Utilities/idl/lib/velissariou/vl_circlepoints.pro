;--------------------
Function VL_CirclePoints, xc, yc, rd, n_points

on_error, 2

if (n_params() lt 3) then $
  message, "need to specify valid values for all: <xc, yc, rd>."

numtypes = [2, 3, 4, 5, 12, 13, 14, 15]
if (where(size(xc, /type) eq numtypes) eq -1) then $
  message, "need to specify valid value for: <xc>."
if (where(size(yc, /type) eq numtypes) eq -1) then $
  message, "need to specify valid value for: <yc>."
if (where(size(rd, /type) eq numtypes) eq -1) then $
  message, "need to specify valid value for: <rd>."

; set the number of points
if (keyword_set(n_points) eq 0) then n_points = 60

thisXC   = Double(xc[0])
thisYC   = Double(yc[0])
thisRD   = Double(rd[0])
thisPNTS = Round(Abs(n_points[0]))

points = (2 * !PI / Double(thisPNTS-1)) * Dindgen(thisPNTS)
x = thisXC + thisRD * cos(points)
y = thisYC + thisRD * sin(points)

return, [ transpose(x),transpose(y) ]

end
