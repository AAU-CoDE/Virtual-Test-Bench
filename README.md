# Virtual-Test-Bench
Extract MOSFET datasheet parameters from a SPICE model

# Path picker
First time running the simulation, pick the path to the directory where the device model .lib file is stored. This path will be saved as "LTlibPathInfo.mat".
If the path is changed, delete LTlibPathInfo.mat and select the new path.

Afterwards, select the path of the LTSpice executable, preferrably XVIIx86.exe.
  
# Run virtualTestBenchMaster.m
- Define Test Conditions for Rdson & Coss tests
- Select Paths
- Hope that there are no errors, otherwise try to run the faulty sections again.
- The variable 'output' is a structure containing the curvefitted functions of Rdson(Tj), Coss(Vds), and the corresponding look-up tables 

GOOD LUCK!
