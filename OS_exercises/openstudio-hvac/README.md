# OpenStudio HVAC
HVAC modelling in  can be the easiest aspect of a building to specify in OpenStudio but the most difficult to define correctly. An entire HVAC system can be specified with working default values with just a few clicks. But this is only possible because a lot of the nitty gritty detail is hidden or encapsulated in simple looking icons.

# Exercise
* The steps to defining the HVAC system (instruction, background information, and specs of the CCHT HVAC system is in the [.ppt](https://github.com/edwardv720/os_workshop/blob/main/An%20introduction%20to%20%20OpenStudio%20%26%20Energyplus.pptx)) can be found in [7_os_hvac_exercise.pdf](7_os_hvac_exercise.pdf).
* Although this section is HVAC, the domestic hot water heater is also specified in this exercise. The hot water load profile (usage throughout a day) is included as a schedule object in dhw_load_profile.osm. This .osm (like any other) can be set as a library object so there's not need to manually define the profile. This step is shown in 7_os_hvac_exercise.pdf.
* **1_ccht_f_hvac.osm** is the starting step and **Final_ccht_f_hvac.osm** is the fully defined building (envelope, gains, schedules, hvac, hot water system)
