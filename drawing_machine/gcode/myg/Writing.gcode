(Scribbled version of C:\Users\BENBOU~1\AppData\Local\Temp\ink_ext_XXXXXX.svg3H3BWZ @ 3500.00)
( unicorn.py --tab="pen_changes" --pen-up-angle=50 --pen-down-angle=30 --start-delay=150 --stop-delay=150 --xy-feedrate=3500 --z-feedrate=150 --z-height=0 --finished-height=0 --register-pen=true --x-home=0 --y-home=0 --num-copies=1 --continuous=false --pause-on-layer-change=false C:\Users\BENBOU~1\AppData\Local\Temp\ink_ext_XXXXXX.svg3H3BWZ )
G21 (metric ftw)
G90 (absolute mode)
G92 X0.00 Y0.00 Z0.00 (you are here)

M300 S30 (pen down)
G4 P150 (wait 150ms)
M300 S50 (pen up)
G4 P150 (wait 150ms)
M18 (disengage drives)
M01 (Was registration test successful?)
M17 (engage drives if YES, and continue)

(Polyline consisting of 2 segments.)
G1 X11.25 Y32.09 F3500.00
M300 S30.00 (pen down)
G4 P150 (wait 150ms)
G1 X11.51 Y33.77 F3500.00
G1 X12.26 Y35.03 F3500.00
G1 X13.42 Y35.83 F3500.00
G1 X14.87 Y36.10 F3500.00
G1 X16.75 Y35.60 F3500.00
G1 X18.03 Y34.21 F3500.00
G1 X18.47 Y32.18 F3500.00
G1 X18.00 Y30.13 F3500.00
G1 X16.69 Y28.76 F3500.00
G1 X14.86 Y28.29 F3500.00
G1 X12.96 Y28.81 F3500.00
G1 X11.69 Y30.21 F3500.00
G1 X11.25 Y32.09 F3500.00
G1 X11.25 Y32.09 F3500.00
M300 S50.00 (pen up)
G4 P150 (wait 150ms)

(Polyline consisting of 2 segments.)
G1 X12.28 Y32.08 F3500.00
M300 S30.00 (pen down)
G4 P150 (wait 150ms)
G1 X12.47 Y30.86 F3500.00
G1 X13.02 Y29.93 F3500.00
G1 X13.84 Y29.34 F3500.00
G1 X14.86 Y29.15 F3500.00
G1 X15.88 Y29.34 F3500.00
G1 X16.71 Y29.94 F3500.00
G1 X17.26 Y30.90 F3500.00
G1 X17.44 Y32.19 F3500.00
G1 X17.13 Y33.79 F3500.00
G1 X16.22 Y34.86 F3500.00
G1 X14.87 Y35.24 F3500.00
G1 X13.89 Y35.06 F3500.00
G1 X13.05 Y34.51 F3500.00
G1 X12.47 Y33.54 F3500.00
G1 X12.28 Y32.08 F3500.00
G1 X12.28 Y32.08 F3500.00
M300 S50.00 (pen up)
G4 P150 (wait 150ms)

(Polyline consisting of 1 segments.)
G1 X19.71 Y28.42 F3500.00
M300 S30.00 (pen down)
G4 P150 (wait 150ms)
G1 X19.71 Y35.96 F3500.00
G1 X20.71 Y35.96 F3500.00
G1 X20.71 Y32.22 F3500.00
G1 X24.45 Y35.96 F3500.00
G1 X25.80 Y35.96 F3500.00
G1 X22.64 Y32.91 F3500.00
G1 X25.94 Y28.42 F3500.00
G1 X24.63 Y28.42 F3500.00
G1 X21.94 Y32.24 F3500.00
G1 X20.71 Y31.03 F3500.00
G1 X20.71 Y28.42 F3500.00
G1 X19.71 Y28.42 F3500.00
M300 S50.00 (pen up)
G4 P150 (wait 150ms)


(end of print job)
M300 S50.00 (pen up)
G4 P150 (wait 150ms)
M300 S255 (turn off servo)
G1 X0 Y0 F3500.00
G1 Z0.00 F150.00 (go up to finished level)
G1 X0.00 Y0.00 F3500.00 (go home)
M18 (drives off)
