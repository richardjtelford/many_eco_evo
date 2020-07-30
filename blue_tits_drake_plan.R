library("drake")
library("dataDownloader")
library("tidyverse")
library("rjt.misc")
library("lme4")
library("broom.mixed")

#source plans
source("R/last_digit_plan.R")
source("R/analysis_plan.R")

#download and import plan ####
import_plan <- drake_plan(
  #download data
  blue_tit_download = target(
    command = get_file(node = "34fzc", file = "blue_tit_data_updated_2020-04-18.csv", path = "data/"),
    format = "file"),
  
  #import blue tits
  blue_tit0 = read_csv(blue_tit_download, na = "."), 
  
  #make factor variables
  blue_tit = blue_tit0 %>% 
    #fix errors
    mutate(
      #P809444 has wrong year
      hatch_year = if_else(chick_ring_number == "P809444", true = 2003, false = hatch_year)
    ) %>% 
    mutate(
      rear_area = factor(rear_area),
      rear_nest_trt = factor(rear_nest_trt, levels = 5:7, labels = c("increase", "decrease", "no manipulation")),
      chick_sex_molec = factor(chick_sex_molec, levels = 1:2, labels = c("female", "male")),
      hatch_year = factor(hatch_year),
      home_or_away	= factor(home_or_away, levels = 1:2, labels = c("home", "away")),
      day14_measurer = factor(day14_measurer)
      ) %>% 
    #make box-year variable for random effect
    mutate(
      rear_Box_year = paste(rear_Box, hatch_year, sep = "_"),
      hatch_Box_year = paste(hatch_Box, hatch_year, sep = "_"),
    )
)

#### manuscript ####
manuscript_plan <- drake_plan(
  #add package citations to bib file
  biblio2 = {
    #force dependency on renv lock file so updates if new package versions used
    file_in("renv.lock")
    package_citations(
      packages = c("drake", "tidyverse", "renv", "bookdown", "lme4"), 
      old_bib = file_in("Rmd/extra/blue_tits.bib"), 
      new_bib = file_out("Rmd/extra/blue_tits2.bib"))
    },
  
  #render methods
  manuscript = {
    file_in("Rmd/extra/elsevier-harvard_rjt.csl")
    file_in("Rmd/extra/blue_tits2.bib")
    rmarkdown::render(
      input = knitr_in("Rmd/blue_tit_methods.Rmd"), 
      knit_root_dir = "../", 
      clean = FALSE)
  }
)



#### combine plans ####
blue_tit_plan <- bind_plans(import_plan, 
                            last_digit_plan,
                            analysis_plan,
                            manuscript_plan)


#quick plot
plot(blue_tit_plan)

#### configure drake plan ####
blue_tit_config <- drake_config(plan = blue_tit_plan, keep_going = TRUE)
blue_tit_config
