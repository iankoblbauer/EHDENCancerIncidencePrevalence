# code for getting denominator and estimating incidence below

# cancer populations  -----
print(paste0("- Getting denominator: cancer populations"))
info(logger, "- Getting denominator: cancer populations")

#get denominator
cdm$denominator <- generateDenominatorCohortSet(
  cdm = cdm,
  startDate = as.Date(studyStartDate),
  endDate = as.Date(studyEndDate),
  ageGroup =list(
    c(18, 150),
    c(18, 29),
    c(30, 39),
    c(40, 49),
    c(50, 59),
    c(60, 69),
    c(70, 79),
    c(80, 89),
    c(90, 150)
  ),
  sex = c("Male", "Female", "Both"),
  daysPriorHistory = 365,
  verbose = TRUE
)

print(paste0("- Got denominator: cancer populations"))
info(logger, "- Got denominator: cancer populations")


# Estimate yearly incidence -------
print(paste0("- Getting incidence and period prevalence: cancer populations"))
info(logger, "- Getting incidence and period prevalence: cancer populations")

print(paste0("- Getting yearly incidence: cancer populations"))
info(logger, "- Getting yearly incidence: cancer populations")

inc <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeTable = outcome_table_name,
  denominatorCohortId = NULL,
  outcomeCohortId = outcome_cohorts$cohortId,
  outcomeCohortName = outcome_cohorts$cohortName,
  interval = c("years"), 
  outcomeWashout = NULL,
  repeatedEvents = FALSE,
  completeDatabaseIntervals = TRUE,
  minCellCount = 5,
  returnParticipants = FALSE
)

print(paste0("- Got incidence: cancer populations"))
info(logger, "- Got incidence: cancer populations")

print(paste0("- Getting period prevalence: cancer populations"))
info(logger, "- Getting period prevalence: cancer populations")

# Estimate period prevalence ---------
prev_period <- estimatePeriodPrevalence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeCohortId = outcome_cohorts$cohortId,
  outcomeCohortName = outcome_cohorts$cohortName,
  outcomeLookbackDays = 0, 
  outcomeTable = outcome_table_name,
  interval = c("years"),
  completeDatabaseIntervals = TRUE, # prev only estimate for intervals where db captures all of the interval
  fullContribution = c(TRUE, FALSE) , # individuals only required to be present for one day in interval
  minCellCount = 5
)

print(paste0("- Got period prevalence: cancer populations"))
info(logger, "- Got period prevalence: cancer populations")


print(paste0("- Got incidence and period prevalence: cancer population"))
info(logger, "- Got incidence and period prevalence: cancer population")


# Get the results ----------------
print(paste0("- Gathering incidence and period prevalence results: cancer populations"))
info(logger, "- Gathering incidence and period prevalence results: cancer populations")


study_results<- gatherIncidencePrevalenceResults(cdm =cdm, 
                                                 resultList=list(inc,prev_period ),
                                                 databaseName = db.name)

print(paste0("- Got incidence and period prevalence results: cancer populations"))
info(logger, "- Got incidence and period prevalence results: cancer populations")

# Export the results -----
print(paste0("- Exporting incidence and period prevalence results: cancer populations"))
info(logger, "- Exporting incidence and period prevalence results: cancer populations")

exportIncidencePrevalenceResults(result=study_results,
                                 zipName= paste0(db.name, "IPResults"),
                                 outputFolder=here::here("Results", db.name))


print(paste0("- Exported incidence and period prevalence results: cancer populations"))
info(logger, "- Exported incidence and period prevalence results: cancer populations")

print(paste0("- Plotting incidence and period prevalence results: cancer populations"))
info(logger, "- Plotting incidence and period prevalence results: cancer populations")

###########################################
# run plots for checking QC checking -----

# whole population
# incidence
inc_yrs_plot <- study_results$incidence_estimates %>%  # need to amend this bit of code to select the estimates relating to inc_yrs
  filter(denominator_cohort_id == 3 &
           denominator_age_group == "18;150" &
           analysis_interval == "years") %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "ProstateCancerMaleOnly", "Prostate")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLungCancer", "Lung")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantBreastCancer", "Breast")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantColorectalCancer", "Colorectal")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantHeadNeckCancer", "Head and Neck")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLiverCancer", "Liver")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantPancreaticCancer", "Pancreas")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantStomachCancer", "Stomach")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "esophagealCancer", "Esophagus")) %>%  
  mutate(time = format(incidence_start_date, format="%Y")) %>%
  as.data.frame()

plotAll <- inc_yrs_plot %>%
  ggplot( aes(x = time, y = incidence_100000_pys, group=outcome_cohort_name, color = outcome_cohort_name)) +
  geom_ribbon(aes(ymin = incidence_100000_pys_95CI_lower, ymax = incidence_100000_pys_95CI_upper, fill = outcome_cohort_name), alpha = .3, color = NA, show.legend = FALSE) +
  geom_line(color = "black", size = 0.25) +
  geom_point(size = 2.5) +
  xlab("Calender year") +
  ylab("Incidence rate per 100000 person-years") +
  scale_colour_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) + #blue, #red, #lightblue, #green, purple, peach, dark read, gry
  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) +
  labs(colour = "Cancer") +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.background = element_blank() ,
        axis.line = element_line(colour = "black", size = 0.6) ,
        panel.grid.major = element_line(color = "grey", size = 0.2, linetype = "dashed"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"))

plotname <- paste0("IncidenceRatesWholePop", db.name,".pdf")

pdf(here(qcfolder, plotname),
    width = 7, height = 5)
print(plotAll, newpage = FALSE)
dev.off()



# period prevalence
pp_yrs_plot <- study_results$prevalence_estimates %>%  # need to amend this bit of code to select the estimates relating to inc_yrs
  filter((denominator_cohort_id == 3 &
           denominator_age_group == "18;150" ) & 
           analysis_interval == "years",
         analysis_full_contribution == "FALSE") %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "ProstateCancerMaleOnly", "Prostate")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLungCancer", "Lung")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantBreastCancer", "Breast")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantColorectalCancer", "Colorectal")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantHeadNeckCancer", "Head and Neck")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLiverCancer", "Liver")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantPancreaticCancer", "Pancreas")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantStomachCancer", "Stomach")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "esophagealCancer", "Esophagus")) %>% 
  mutate(time = format(prevalence_start_date, format="%Y")) %>%
  as.data.frame()

plotAll <- pp_yrs_plot %>%
  ggplot( aes(x = time, y = prevalence, group=outcome_cohort_name, color = outcome_cohort_name)) +
  geom_ribbon(aes(ymin = prevalence_95CI_lower, ymax = prevalence_95CI_upper, fill = outcome_cohort_name), alpha = .3, color = NA, show.legend = FALSE) +
  geom_line(color = "black", size = 0.25) +
  geom_point(size = 2.5) +
  xlab("Calender year") +
  ylab("Prevalence") +
  scale_colour_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) + #blue, #red, #lightblue, #green, purple, peach, dark read, gry
  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) +
  labs(colour = "Cancer") +
  scale_y_continuous( labels = scales::percent, limits = c(0, NA)) +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.background = element_blank() ,
        axis.line = element_line(colour = "black", size = 0.6) ,
        panel.grid.major = element_line(color = "grey", size = 0.2, linetype = "dashed"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"))

plotname <- paste0("PeriodPrevRatesWholePop", db.name,".pdf")

pdf(here(qcfolder, plotname),
    width = 7, height = 5)
print(plotAll, newpage = FALSE)
dev.off()


# ###########################################
# # plot the results stratified by gender

inc_yrs_plot <- study_results$incidence_estimates %>%  # need to amend this bit of code to select the estimates relating to inc_yrs
    filter((denominator_cohort_id == 1 | denominator_cohort_id == 2 &
           denominator_age_group == "18;150") &
             analysis_interval == "years") %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "ProstateCancerMaleOnly", "Prostate")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLungCancer", "Lung")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantBreastCancer", "Breast")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantColorectalCancer", "Colorectal")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantHeadNeckCancer", "Head and Neck")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLiverCancer", "Liver")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantPancreaticCancer", "Pancreas")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantStomachCancer", "Stomach")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "esophagealCancer", "Esophagus")) %>% 
  mutate(time = format(incidence_start_date, format="%Y")) %>%
  as.data.frame()

plotGender <- inc_yrs_plot %>%
  ggplot( aes(x = time, y = incidence_100000_pys, group=outcome_cohort_name, color = outcome_cohort_name)) +
  geom_ribbon(aes(ymin = incidence_100000_pys_95CI_lower, ymax = incidence_100000_pys_95CI_upper, fill = outcome_cohort_name), alpha = .3, color = NA, show.legend = FALSE) +
  geom_line(color = "black", size = 0.25) +
  geom_point(size = 2.5) +
  xlab("Calender year") +
  ylab("Incidence rate per 100000 person-years") +
  scale_colour_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) + #blue, #red, #lightblue, #green, purple, peach, dark read, gry
  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) +
  labs(colour = "Cancer") +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.background = element_blank() ,
        panel.grid.major = element_line(color = "grey", size = 0.2, linetype = "dashed"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"))

plotGender <- plotGender + facet_wrap(~denominator_sex, scales="free_y") +
  theme(strip.background = element_rect(colour="black", fill=NA),
        panel.border = element_rect(fill = NA, color = "black"))

plotname <- paste0("IncidenceRatesGender", db.name,".pdf")

pdf(here(qcfolder, plotname),
    width = 11, height = 5)
print(plotGender, newpage = FALSE)
dev.off()

# period prevalence
pp_yrs_plot <- study_results$prevalence_estimates %>%  # need to amend this bit of code to select the estimates relating to inc_yrs
  filter((denominator_cohort_id == 1 | denominator_cohort_id == 2 &
           denominator_age_group == "18;150" ) &
           analysis_interval == "years",
         analysis_full_contribution == "FALSE") %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "ProstateCancerMaleOnly", "Prostate")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLungCancer", "Lung")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantBreastCancer", "Breast")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantColorectalCancer", "Colorectal")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantHeadNeckCancer", "Head and Neck")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLiverCancer", "Liver")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantPancreaticCancer", "Pancreas")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantStomachCancer", "Stomach")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "esophagealCancer", "Esophagus")) %>% 
  mutate(time = format(prevalence_start_date, format="%Y")) %>%
  as.data.frame()

plotGender <- pp_yrs_plot %>%
  ggplot( aes(x = time, y = prevalence, group=outcome_cohort_name, color = outcome_cohort_name)) +
  geom_ribbon(aes(ymin = prevalence_95CI_lower, ymax = prevalence_95CI_upper, fill = outcome_cohort_name), alpha = .3, color = NA, show.legend = FALSE) +
  geom_line(color = "black", size = 0.25) +
  geom_point(size = 2.5) +
  xlab("Calender year") +
  ylab("Prevalence") +
  scale_colour_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) + #blue, #red, #lightblue, #green, purple, peach, dark read, gry
  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) +
  labs(colour = "Cancer") +
  scale_y_continuous( labels = scales::percent, limits = c(0, NA)) +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.background = element_blank() ,
        panel.grid.major = element_line(color = "grey", size = 0.2, linetype = "dashed"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"))

plotGender <- plotGender + facet_wrap(~denominator_sex , scales="free_y") +
  theme(strip.background = element_rect(colour="black", fill=NA),
        panel.border = element_rect(fill = NA, color = "black"))


plotname <- paste0("PeriodPrevRatesGender", db.name,".pdf")

pdf(here(qcfolder, plotname),
    width = 11, height = 5)
print(plotGender, newpage = FALSE)
dev.off()


# ###########################################
# # plot the results stratified by age ----

# incidence
inc_yrs_plot <- study_results$incidence_estimates %>%  # need to amend this bit of code to select the estimates relating to inc_yrs
  filter((denominator_age_group != "18;150" &
           denominator_sex == "Both" ) &
           analysis_interval == "years") %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "ProstateCancerMaleOnly", "Prostate")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLungCancer", "Lung")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantBreastCancer", "Breast")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantColorectalCancer", "Colorectal")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantHeadNeckCancer", "Head and Neck")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLiverCancer", "Liver")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantPancreaticCancer", "Pancreas")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantStomachCancer", "Stomach")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "esophagealCancer", "Esophagus")) %>% 
  mutate(time = format(incidence_start_date, format="%Y")) %>%
  mutate(time = as.numeric(time)) %>%
  as.data.frame()


agelabels <- c(
  `18;29` = "18-29 Years",
  `30;39` = "30-39 Years",
  `40;49` = "40-49 Years",
  `50;59` = "50-59 Years",
  `60;69` = "60-69 Years",
  `70;79` = "70-79 Years",
  `80;89` = "80-89 Years",
  `90;150` = "90+ Years")

plotAge <- inc_yrs_plot %>%
  ggplot( aes(x = time, y = incidence_100000_pys, group=outcome_cohort_name, color = outcome_cohort_name)) +
  geom_ribbon(aes(ymin = incidence_100000_pys_95CI_lower, ymax = incidence_100000_pys_95CI_upper, fill = outcome_cohort_name), alpha = .3, color = NA, show.legend = FALSE) +
  geom_line(color = "black", size = 0.25) +
  geom_point(size = 1.5) +
  xlab("Calender year") +
  ylab("Incidence rate per 100000 person-years") +
  scale_colour_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) + #blue, #red, #lightblue, #green, purple, peach, dark read, gry
  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) +
  labs(colour = "Cancer") +
  scale_x_continuous(breaks=seq(min(inc_yrs_plot$time), max(inc_yrs_plot$time), 2)) +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.background = element_blank() ,
        panel.grid.major = element_line(color = "grey", size = 0.2, linetype = "dashed"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"))

plotAge <- plotAge + facet_wrap(~denominator_age_group, scales="free_y", labeller=labeller(denominator_age_group = agelabels)) +
  theme(strip.background = element_rect(colour="black", fill=NA),
        panel.border = element_rect(fill = NA, color = "black"))

plotname <- paste0("IncidenceRatesAge", db.name,".pdf")

pdf(here(qcfolder, plotname),
    width = 10, height = 6)
print(plotAge, newpage = FALSE)
dev.off()



# period prevalence
pp_yrs_plot <- study_results$prevalence_estimates %>%  # need to amend this bit of code to select the estimates relating to inc_yrs
  filter((denominator_age_group != "18;150" &
           denominator_sex == "Both" ) &
           analysis_interval == "years",
         analysis_full_contribution == "FALSE") %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "ProstateCancerMaleOnly", "Prostate")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLungCancer", "Lung")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantBreastCancer", "Breast")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantColorectalCancer", "Colorectal")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantHeadNeckCancer", "Head and Neck")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLiverCancer", "Liver")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantPancreaticCancer", "Pancreas")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantStomachCancer", "Stomach")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "esophagealCancer", "Esophagus")) %>% 
  mutate(time = format(prevalence_start_date, format="%Y")) %>%
  mutate(time = as.numeric(time)) %>%
  as.data.frame()

plotAge <- pp_yrs_plot %>%
  ggplot( aes(x = time, y = prevalence, group=outcome_cohort_name, color = outcome_cohort_name)) +
  geom_ribbon(aes(ymin = prevalence_95CI_lower, ymax = prevalence_95CI_upper, fill = outcome_cohort_name), alpha = .3, color = NA, show.legend = FALSE) +
  geom_line(color = "black", size = 0.25) +
  geom_point(size = 1.5) +
  xlab("Calender year") +
  ylab("Prevalence") +
  scale_colour_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) + #blue, #red, #lightblue, #green, purple, peach, dark read, gry
  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) +
  labs(colour = "Cancer") +
  scale_x_continuous(breaks=seq(min(inc_yrs_plot$time), max(inc_yrs_plot$time), 2)) +
  scale_y_continuous( labels = scales::percent, limits = c(0, NA)) +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.background = element_blank() ,
        panel.grid.major = element_line(color = "grey", size = 0.2, linetype = "dashed"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"))

plotAge <- plotAge + facet_wrap(~denominator_age_group, scales="free_y", labeller=labeller(denominator_age_group = agelabels)) +
  theme(strip.background = element_rect(colour="black", fill=NA),
        panel.border = element_rect(fill = NA, color = "black"))

plotname <- paste0("PeriodPrevRatesAge", db.name,".pdf")

pdf(here(qcfolder, plotname),
    width = 10, height = 6)
print(plotAge, newpage = FALSE)
dev.off()


# ###########################################
# # plot the results stratified by age AND gender ----

# incidence
inc_yrs_plot <- study_results$incidence_estimates %>% 
  filter((denominator_age_group != "18;150" &
           denominator_sex != "Both" ) &
           analysis_interval == "years") %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "ProstateCancerMaleOnly", "Prostate")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLungCancer", "Lung")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantBreastCancer", "Breast")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantColorectalCancer", "Colorectal")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantHeadNeckCancer", "Head and Neck")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLiverCancer", "Liver")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantPancreaticCancer", "Pancreas")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantStomachCancer", "Stomach")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "esophagealCancer", "Esophagus")) %>% 
  mutate(time = format(incidence_start_date, format="%Y")) %>%
  mutate(time = as.numeric(time)) %>%
  as.data.frame()

agelabels <- c(
  `18;29` = "18-29 Years",
  `30;39` = "30-39 Years",
  `40;49` = "40-49 Years",
  `50;59` = "50-59 Years",
  `60;69` = "60-69 Years",
  `70;79` = "70-79 Years",
  `80;89` = "80-89 Years",
  `90;150` = "90+ Years")

plotAgeGender <- inc_yrs_plot %>%
  ggplot( aes(x = time, y = incidence_100000_pys, group=outcome_cohort_name, color = outcome_cohort_name)) +
  geom_ribbon(aes(ymin = incidence_100000_pys_95CI_lower, ymax = incidence_100000_pys_95CI_upper, fill = outcome_cohort_name), alpha = .3, color = NA, show.legend = FALSE) +
  geom_line(color = "black", size = 0.25) +
  geom_point(size = 1.5) +
  xlab("Calender year") +
  ylab("Incidence rate per 100000 person-years") +
  scale_colour_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) + #blue, #red, #lightblue, #green, purple, peach, dark read, gry
  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) +
  labs(colour = "Cancer") +
  scale_x_continuous(breaks=seq(min(inc_yrs_plot$time), max(inc_yrs_plot$time), 2)) +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.background = element_blank() ,
        panel.grid.major = element_line(color = "grey", size = 0.2, linetype = "dashed"),
        legend.key = element_rect(fill = "transparent", colour = "transparent")
  )

plotAgeGender <- plotAgeGender + facet_grid(denominator_sex ~ denominator_age_group , labeller=labeller(denominator_age_group = agelabels), scales = "free") +
  theme(strip.background = element_rect(colour="black", fill=NA),
        panel.border = element_rect(fill = NA, color = "black"))


plotname <- paste0("IncidenceRatesAgeGender", db.name,".pdf")

pdf(here(qcfolder, plotname),
    width = 20, height = 8)
print(plotAgeGender, newpage = FALSE)
dev.off()

# period prevalence
pp_yrs_plot <- study_results$prevalence_estimates %>% 
  filter((denominator_age_group != "18;150" &
           denominator_sex != "Both") &
           analysis_interval == "years",
         analysis_full_contribution == "FALSE") %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "ProstateCancerMaleOnly", "Prostate")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLungCancer", "Lung")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantBreastCancer", "Breast")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantColorectalCancer", "Colorectal")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantHeadNeckCancer", "Head and Neck")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantLiverCancer", "Liver")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantPancreaticCancer", "Pancreas")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "MalignantStomachCancer", "Stomach")) %>%
  mutate(outcome_cohort_name = replace(outcome_cohort_name, outcome_cohort_name == "esophagealCancer", "Esophagus")) %>% 
  mutate(time = format(prevalence_start_date, format="%Y")) %>%
  mutate(time = as.numeric(time)) %>%
  as.data.frame()

agelabels <- c(
  `18;29` = "18-29 Years",
  `30;39` = "30-39 Years",
  `40;49` = "40-49 Years",
  `50;59` = "50-59 Years",
  `60;69` = "60-69 Years",
  `70;79` = "70-79 Years",
  `80;89` = "80-89 Years",
  `90;150` = "90+ Years")

plotAgeGender <- pp_yrs_plot %>%
  ggplot( aes(x = time, y = prevalence, group=outcome_cohort_name, color = outcome_cohort_name)) +
  geom_ribbon(aes(ymin = prevalence_95CI_lower, ymax = prevalence_95CI_upper, fill = outcome_cohort_name), alpha = .3, color = NA, show.legend = FALSE) +
  geom_line(color = "black", size = 0.25) +
  geom_point(size = 1.5) +
  xlab("Calender year") +
  ylab("Prevalence") +
  scale_colour_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) + #blue, #red, #lightblue, #green, purple, peach, dark read, gry
  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#0099B4FF", "#42B540FF", "#925E9FFF", "#FDAF91FF", "#AD002AFF", "grey", "hotpink")) +
  labs(colour = "Cancer") +
  scale_x_continuous(breaks=seq(min(inc_yrs_plot$time), max(inc_yrs_plot$time), 2)) +
  scale_y_continuous( labels = scales::percent, limits = c(0, NA)) +
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        panel.background = element_blank() ,
        panel.grid.major = element_line(color = "grey", size = 0.2, linetype = "dashed"),
        legend.key = element_rect(fill = "transparent", colour = "transparent"))

plotAgeGender <- plotAgeGender + facet_grid(denominator_sex ~ denominator_age_group , labeller=labeller(denominator_age_group = agelabels), scales = "free") +
  theme(strip.background = element_rect(colour="black", fill=NA),
        panel.border = element_rect(fill = NA, color = "black"))

plotname <- paste0("PeriodPrevRatesAgeGender", db.name,".pdf")

pdf(here(qcfolder, plotname),
    width = 20, height = 8)
print(plotAgeGender, newpage = FALSE)
dev.off()

print(paste0("- Plotted incidence and period prevalence results: cancer populations"))
info(logger, "- Plotted incidence and period prevalence results: cancer populations")


#get the overall incidence from 2000 to 2019 -----
print(paste0("- Getting overall incidence: cancer populations"))
info(logger, "- Getting overall incidence: cancer populations")

inc_overall <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeTable = outcome_table_name,
  denominatorCohortId = NULL,
  outcomeCohortId = outcome_cohorts$cohortId,
  outcomeCohortName = outcome_cohorts$cohortName,
  interval = c("overall"),
  outcomeWashout = NULL,
  repeatedEvents = FALSE,
  completeDatabaseIntervals = TRUE,
  minCellCount = 5,
  returnParticipants = TRUE
)

print(paste0("- Got incidence: cancer populations"))
info(logger, "- Got incidence: cancer populations")

# Get the results ----------------
print(paste0("- Gathering overall incidence results: cancer populations"))
info(logger, "- Gathering overall incidence results: cancer populations")


study_results_overall<- gatherIncidencePrevalenceResults(cdm =cdm,
                                                 resultList=list(inc_overall),
                                                 databaseName = db.name)


print(paste0("- Got overall incidence results: cancer populations"))
info(logger, "- Got overall incidence results: cancer populations")

# Export the results -----
print(paste0("- Exporting incidence overall results: cancer populations"))
info(logger, "- Exporting incidence overall results: cancer populations")

exportIncidencePrevalenceResults(result=study_results_overall,
                                 zipName= paste0(db.name, "IPResults_overall"),
                                 outputFolder=here::here("Results", db.name))


print(paste0("- Exported overall incidence results: cancer populations"))
info(logger, "- Exported overall incidence results: cancer populations")
