# Virtual-Test-Bench
Extract MOSFET datasheet parameters from a SPICE model. Currently supports Rdson(Tj) & Coss(vds)

Run & follow the dialogue
# Define Model 
Enter the name of the .lib file of the LTSpice model you want to extract. (eg. CD3M190D08J, without the .lib extension)
Optionally, you can also define the model name. Sometimes, one .lib file contains several models, or the name of the .lib file does not correspond to the name of the model. Usually, the name of the model is in the .lib file after the first .subckt statement. For encrypted files,  enter the name here (or manually enter it later in the dialogue, when asked).

# Path picker: First time
First time running the simulation, pick the path to the directory where the device model .lib file is stored. This path will be saved as "LTlibPathInfo.mat".
If the path is changed, the dialogue will appear again.

Afterwards, select the path of the LTSpice executable, preferrably XVIIx86.exe.
  
# Run virtualTestBenchMaster.m
- Define .lib file name
- Optionally: define model name
- Select Paths
- Define Test Conditions for Rdson
-  Define Test Conditions for Coss

- Hope that there are no errors, otherwise try to run the faulty sections again.
- The output of the testbench functions is a structure containing the curvefitted functions of Rdson(Tj), Coss(Vds), and the corresponding look-up tables 

GOOD LUCK!
