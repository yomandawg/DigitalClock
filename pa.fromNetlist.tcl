
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Project_2015440029 -dir "C:/Users/RAY/Desktop/2-2/Project_2015440029/planAhead_run_1" -part xc3s200pq208-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/RAY/Desktop/2-2/Project_2015440029/Digital_Clock.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/RAY/Desktop/2-2/Project_2015440029} }
set_property target_constrs_file "Digital_Clock_PIN.ucf" [current_fileset -constrset]
add_files [list {Digital_Clock_PIN.ucf}] -fileset [get_property constrset [current_run]]
link_design
