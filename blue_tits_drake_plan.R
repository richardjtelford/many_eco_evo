library("drake")
library("dataDownloader")
library("tidyverse")
library("rjt.misc")

#download and import plan ####
import_plan <- drake_plan(
  #download data
  blue_tit_download = target(
    command = get_file(node = "34fzc", file = "blue_tit_data_updated_2020-04-18.csv", path = "data/"),
    format = "file"),
  
  #import blue tits
  blue_tit = read_csv(blue_tit_download, na = ".")  
)

# manuscript ####
manuscript_plan <- drake_plan(
  #add package citations to bib file
  biblio2 = package_citations(
    packages = c("drake"), 
    old_bib = file_in("Rmd/extra/blue_tits.bib"), 
    new_bib = file_out("Rmd/extra/blue_tits2.bib")),
  
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
                            manuscript_plan)


#quick plot
plot(blue_tit_plan)

#### configure drake plan ####
blue_tit_config <- drake_config(plan = blue_tit_plan, keep_going = TRUE)
blue_tit_config
