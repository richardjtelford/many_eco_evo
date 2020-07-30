last_digit_plan <- drake_plan(

  last_digit_data = blue_tit %>% 
    #extract last digit
    mutate(Mass = (day_14_weight %% 1) * 10,
           Mass = round(Mass),
           Tarsus = (day_14_tarsus_length %% 1) * 10,
           Tarsus = round(Tarsus)) %>% 
    select(Mass, Tarsus, day14_measurer, hatch_year) %>% 
    pivot_longer(cols = c("Mass", "Tarsus"), names_to = "variable", values_to = "last_digit"),
  
  #plot
  last_digit_plot = last_digit_data %>% 
    ggplot(aes(last_digit, fill = day14_measurer)) + 
    geom_bar(show.legend = FALSE) +
    facet_grid(variable ~ day14_measurer) +
    scale_x_continuous(breaks = seq(0, 8, 2)) +
    labs(x = "Last digit of day 14 data", y = "Frequency"),
  
  #chi.sq test
  last_digit_chi = last_digit_data %>% 
    filter(day14_measurer != 4) %>% 
    group_by(day14_measurer, variable) %>% 
    count(last_digit) %>% 
    summarise(broom::glance(chisq.test(n))),
  
  last_digit_year_chi = last_digit_data %>% 
    filter(day14_measurer != 4) %>% 
    group_by(day14_measurer, hatch_year, variable) %>% 
    count(last_digit) %>% 
    summarise(broom::glance(chisq.test(n)))
)