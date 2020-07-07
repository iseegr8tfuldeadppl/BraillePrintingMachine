(Scribbled version of C:\Users\BENBOU~1\AppData\Local\Temp\ink_ext_XXXXXX.svg6YO7YZ @ 3500.00)
( unicorn.py --tab="plotter_setup" --pen-up-angle=50 --pen-down-angle=30 --start-delay=150 --stop-delay=150 --xy-feedrate=3500 --z-feedrate=150 --z-height=0 --finished-height=0 --register-pen=true --x-home=0 --y-home=0 --num-copies=1 --continuous=false --pause-on-layer-change=false C:\Users\BENBOU~1\AppData\Local\Temp\ink_ext_XXXXXX.svg6YO7YZ )
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
G1 X5.75 Y6.57 F3500.00
M300 S30.00 (pen down)
G4 P150 (wait 150ms)
G1 X8.56 Y17.46 F3500.00
G1 X9.61 Y17.46 F3500.00
G1 X12.60 Y6.57 F3500.00
G1 X11.50 Y6.57 F3500.00
G1 X10.64 Y9.87 F3500.00
G1 X7.58 Y9.87 F3500.00
G1 X6.78 Y6.57 F3500.00
G1 X5.75 Y6.57 F3500.00
M300 S50.00 (pen up)
G4 P150 (wait 150ms)

(Polyline consisting of 2 segments.)
G1 X7.86 Y11.04 F3500.00
M300 S30.00 (pen down)
G4 P150 (wait 150ms)
G1 X10.34 Y11.04 F3500.00
G1 X9.58 Y14.06 F3500.00
G1 X9.06 Y16.32 F3500.00
G1 X8.67 Y14.24 F3500.00
G1 X7.86 Y11.04 F3500.00
M300 S50.00 (pen up)
G4 P150 (wait 150ms)

(Polyline consisting of 1 segments.)
G1 X13.36 Y6.57 F3500.00
M300 S30.00 (pen down)
G4 P150 (wait 150ms)
G1 X13.36 Y17.46 F3500.00
G1 X14.82 Y17.46 F3500.00
G1 X16.55 Y9.75 F3500.00
G1 X16.90 Y8.14 F3500.00
G1 X17.29 Y9.88 F3500.00
G1 X19.04 Y17.46 F3500.00
G1 X20.35 Y17.46 F3500.00
G1 X20.35 Y6.57 F3500.00
G1 X19.41 Y6.57 F3500.00
G1 X19.41 Y15.69 F3500.00
G1 X17.28 Y6.57 F3500.00
G1 X16.41 Y6.57 F3500.00
G1 X14.29 Y15.84 F3500.00
G1 X14.29 Y6.57 F3500.00
G1 X13.36 Y6.57 F3500.00
M300 S50.00 (pen up)
G4 P150 (wait 150ms)

(Polyline consisting of 1 segments.)
G1 X22.08 Y6.57 F3500.00
M300 S30.00 (pen down)
G4 P150 (wait 150ms)
G1 X22.08 Y17.46 F3500.00
G1 X23.05 Y17.46 F3500.00
G1 X23.05 Y6.57 F3500.00
G1 X22.08 Y6.57 F3500.00
M300 S50.00 (pen up)
G4 P150 (wait 150ms)

(Polyline consisting of 1 segments.)
G1 X24.75 Y6.57 F3500.00
M300 S30.00 (pen down)
G4 P150 (wait 150ms)
G1 X24.75 Y17.46 F3500.00
G1 X25.74 Y17.46 F3500.00
G1 X29.59 Y8.91 F3500.00
G1 X29.59 Y17.46 F3500.00
G1 X30.52 Y17.46 F3500.00
G1 X30.52 Y6.57 F3500.00
G1 X29.52 Y6.57 F3500.00
G1 X25.68 Y15.13 F3500.00
G1 X25.68 Y6.57 F3500.00
G1 X24.75 Y6.57 F3500.00
M300 S50.00 (pen up)
G4 P150 (wait 150ms)

(Polyline consisting of 1 segments.)
G1 X32.17 Y6.57 F3500.00
M300 S30.00 (pen down)
G4 P150 (wait 150ms)
G1 X32.17 Y17.46 F3500.00
G1 X37.46 Y17.46 F3500.00
G1 X37.46 Y16.18 F3500.00
G1 X33.14 Y16.18 F3500.00
G1 X33.14 Y12.84 F3500.00
G1 X37.19 Y12.84 F3500.00
G1 X37.19 Y11.56 F3500.00
G1 X33.14 Y11.56 F3500.00
G1 X33.14 Y7.85 F3500.00
G1 X37.63 Y7.85 F3500.00
G1 X37.63 Y6.57 F3500.00
G1 X32.17 Y6.57 F3500.00
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
