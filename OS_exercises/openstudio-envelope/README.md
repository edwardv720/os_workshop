# OpenStudio envelope (construction) data
After consructing the geoemetry, the construction of the building envelope needs to be defined. In OpenStudio, this is done by 
1.  defining each material layer of a type of construction (e.g. south facing walls)
2.  ordering the mayerial layer into a construction object
3.  assigning each construction object to the corresponding surface (this includes fenestration)

# Exercise
* Prior to opening OpenStudio, a significant portion of the time spent building a model is collecting the data needed. This first step has been completed in [envelope_data.xlsx](https://github.com/edwardv720/os_workshop/blob/main/OS_exercises/openstudio-envelope/envelope_data.xlsx).
* The steps taken to define the construction objects and assigning them is shown in [4_os_envelope_exercise.pdf](4_os_envelope_exercise.pdf).
* [4.1_infiltration_calculation.pdf](4.1_infiltration_calculation.pdf) contains a simple explanation of characterizing blower door test results and modelling infiltration in OpenStudio.
* The [osm_files](osm_files) contain .osm of the intermediate steps take in 4_os_envelope_exercise.pdf. **Note: Although infiltration is closely related to the construction of a building, the steps taken to incorporating it in the OpenStudio exercise was only completed in [openstudio-hvac](https://github.com/edwardv720/os_workshop/tree/main/OS_exercises/openstudio-hvac). This was a whimsical preference. The user may choose to enter any data, in any order they like**
