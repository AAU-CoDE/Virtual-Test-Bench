# Virtual-Test-Bench
Extract MOSFET datasheet parameters from a SPICE model


# Run mainMosfetExtract.m
- Make sure to define the working folder & LTSpice directory correctly
- Define the file name of the Spice model (without .lib)
- The figures should show Rdson(Tj) curve fit, Coss(Vds) interpolation, and Coss(Vds) curve fit
- The variable output is a struct containing the curvefitted functions of Rdson(Tj), Coss(Vds), and the corresponding look-up tables 

GOOD LUCK!
