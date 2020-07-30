#fit models

analysis_plan <- drake_plan(
#split out reference data and treatment data
  reference_data = blue_tit %>% 
    filter(rear_nest_trt == "no manipulation", 
           !is.na(chick_sex_molec), 
           !is.na(rear_d0_rear_nest_brood_size)),

  treatment_data = blue_tit %>% 
    mutate(net_rearing_manipulation = if_else(#rescue some data with missing data
      condition = is.na(net_rearing_manipulation), 
      true = rear_Cs_at_start_of_rearing - rear_d0_rear_nest_brood_size,
      false = net_rearing_manipulation)) %>% 
    #remove reference data and data with missing predictors
    filter(rear_nest_trt != "no manipulation", 
           !is.na(chick_sex_molec), 
           !is.na(rear_d0_rear_nest_brood_size),
           !is.na(net_rearing_manipulation)),

  #fit selection of models to reference data  
  ref0 = lmer(data = readd(reference_data), day_14_weight ~ 1 + (1|rear_Box_year), REML = FALSE),
  ref1 = update(ref0, formula. = . ~ rear_d0_rear_nest_brood_size + (1|rear_Box_year)),
  ref2 = update(ref0, formula. = . ~ rear_d0_rear_nest_brood_size + chick_sex_molec + (1|rear_Box_year)),
#  ref3 = update(ref0, formula. = . ~ hatch_year + chick_sex_molec + (1|rear_Box_year)),
  ref4 = update(ref0, formula. = . ~ rear_d0_rear_nest_brood_size + chick_sex_molec + hatch_year + (1|rear_Box_year)),
  ref5 = update(ref0, formula. = . ~ rear_d0_rear_nest_brood_size + chick_sex_molec + hatch_year + rear_area + (1|rear_Box_year)),
  ref6 = update(ref0, formula. = . ~ rear_d0_rear_nest_brood_size * chick_sex_molec + hatch_year + (1|rear_Box_year)),

  ref_models = list(ref0, ref1, ref2,  ref4, ref5),
  ref_AIC =  AIC(ref0, ref1, ref2,  ref4, ref5) %>% 
    rownames_to_column(var = "Model") %>% 
    mutate(`Fixed effects` = ref_models %>% map(formula) %>% 
             map(as.character) %>% 
             map_chr(3),
           `Fixed effects` = str_remove(`Fixed effects`, pattern = coll(" + (1 | rear_Box_year)")),
           `Fixed effects` = str_remove_all(`Fixed effects`, pattern = coll("_molec")),
           `Fixed effects` = str_remove_all(`Fixed effects`, pattern = coll("rear_d0_"))
           ) %>% 
    arrange(AIC) %>% 
    select(`Fixed effects`, df, AIC),

  #treatment

  treat1 = lmer(data = readd(treatment_data),
                formula = day_14_weight ~ rear_d0_rear_nest_brood_size + chick_sex_molec + hatch_year + net_rearing_manipulation + (1|rear_Box_year) + (1|hatch_Box_year)),

  treat1_fx = tidy(treat1)
)#end of plan

# ggplot(treatment_data, aes(x = net_rearing_manipulation, y = day_14_weight)) + geom_point() +
#   facet_wrap(~rear_d0_rear_nest_brood_size)
# 
  