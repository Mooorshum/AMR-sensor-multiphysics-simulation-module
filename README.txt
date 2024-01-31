Requirements:

To run this solver you need Matlab with the pdeModeler app and Mumax3
https://uk.mathworks.com/help/pde/ug/pdemodeler-app.html
https://mumax.github.io/download.html



Calculation process:

1. Create a black and white .png image of each layer with the 
     geometry of your ferromagnetic film, conductive layer and contacts in the root folder

2. Set the properties of the magnetic medium and external field 
     inside the PNG_MAG.mx3 script (a plain text editor will work just fine)
   You can also set the geometry resolution by changing the nx, ny and nz variables
   Run the script from the console window via: mumax3 PNG_MAG.mx3
   The output data will be saved to the folder /PNG_MAG.out/

4. Set the electrical properties of the film and current inside main.m
   Run main.m from the matlab editor panel
   Choose which faces you want to apply voltage to


Additional info: 

If you want to visualize the magnetic configuration, 
  run the following command from the PNG_MAG.out folder: mumax3-convert -png *.ovf

The module saves the results for a given geometry. 
  If you want to run the simulation for another geometry - you have to save the results,
  otherwise, they will be rewritten!

