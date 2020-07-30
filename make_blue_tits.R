#load packages
library("drake")


#Build the right things
r_make(source = "R/blue_tits_drake_plan.R")

drake_failed()

if(length(drake_failed()) == 0){
  fs::file_show("Rmd/blue_tit_methods.pdf")#display pdf
}


#view dependency graph
if(interactive()){
  #r_vis_drake_graph(source = "R/blue_tits_drake_plan.R")
  r_vis_drake_graph(source = "R/blue_tits_drake_plan.R", targets_only = TRUE)
}