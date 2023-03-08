# Virtual-Test-Bench
Extract MOSFET datasheet parameters from a SPICE model

# Path in batch files
in Rdson/LTspice_call.bat, adjust path to your application, and working folder. Do the same for Coss/LTspice_call.bat


Example:
Rdson/LTspice_call.bat
start "LTSpice" "[Path to LTSpice .exe file]\\XVIIx86.exe" -b "[Path to local copy of repository]\\Rdson\\RdsonTestBench.net" -alt

Could look something like this:
start "LTSpice" "C:\\Program Files\\LTC\\LTspiceXVII\\XVIIx86.exe" -b "C:\\Users\\gd48aa\\OneDrive - Aalborg Universitet\\Documents\\PhD       CoDE\\automatedDCDC\virtualTestBench\\Rdson\\RdsonTestBench.net" -alt
  
  
# Run mainMosfetExtract.m
- Make sure to define the working folder & LTSpice directory correctly
- Define the file name of the Spice model (without .lib)
- The figures should show Rdson(Tj) curve fit, Coss(Vds) interpolation, and Coss(Vds) curve fit
- The variable output is a struct containing the curvefitted functions of Rdson(Tj), Coss(Vds), and the corresponding look-up tables 

GOOD LUCK!
