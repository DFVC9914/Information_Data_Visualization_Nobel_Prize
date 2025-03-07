setwd('C:/Users/CUI/Downloads')
library(ggplot2)
library(dplyr)
library(scales)
# LOAD DATA
##############################################################################################################

Prize <- read.csv("prize.csv")
Laureate <- read.csv("laureate.csv")
head(Country, 10) 
head(Prize, 10) 
head(Laureate, 10) 
mode(Laureate)
mode(Prize)
sum(is.na(Laureate))
sum(is.na(Prize))
library(stringr)
Laureate$bornCountry <- ifelse(str_detect(Laureate$bornCountry, "\\("), 
                               str_extract(Laureate$bornCountry, "(?<=\\().+?(?=\\))"),Laureate$bornCountry)
Laureate$diedCountry <- ifelse(str_detect(Laureate$diedCountry, "now"), 
                               str_extract(Laureate$diedCountry, "(?<=\\().*?(?=\\))"),Laureate$diedCountry)
Laureate$bornCountry <- ifelse(str_detect(Laureate$bornCountry, "now"), 
                               word(Laureate$bornCountry,-1),Laureate$bornCountry)
Laureate$diedCountry <- ifelse(str_detect(Laureate$diedCountry, "now"), 
                               word(Laureate$diedCountry,-1),Laureate$diedCountry)
Laureate$bornCountry <- str_replace_all(Laureate$bornCountry,"Scotland","United Kingdom")
Laureate$bornCountry <- str_replace_all(Laureate$bornCountry,"Northern Ireland","United Kingdom")
Laureate$diedCountry <- str_replace_all(Laureate$diedCountry,"Scotland","United Kingdom")
Laureate$diedCountry <- str_replace_all(Laureate$diedCountry,"Northern Ireland","United Kingdom")

# Q1: How many prizes have been given in each category?
tally(group_by(Prize,category))
arrange(tally(group_by(Prize,category)), n) %>% mutate(category=factor(category, levels=category)) %>%
  ggplot(aes(x= category, y= n, fill = category))+ 
  geom_bar(stat = "identity", width = 0.8)+ geom_text(aes(label= n),nudge_y = 10) + 
  labs(title = "How many Nobel winners have been given in each category?", 
       x = "Category", y = "The number of Nobel winner")

# Q2 What is the gender ratio of Nobel Prize?
tally(group_by(Laureate,gender)) %>% mutate(prop = n/sum(n)) %>%
  ggplot(aes(x="", y= prop,fill = gender)) + geom_bar(width = 1, stat = "identity")+ 
  geom_text(aes(label= percent(prop)),size=5,position = position_stack(vjust = 0.5))+ 
  labs(title = "The gender ratio of Noble Prize winners", x="", y = "")+
  coord_polar("y", start=1)+  theme_minimal()+theme(axis.ticks = element_blank(), 
                                                    axis.text.y = element_blank(),
                                                    axis.text.x = element_blank()) 

# Q3: What is the average age of Nobel Prize winners by category?
merge(Laureate,Prize) %>% filter( substr(born,1,4) != "0000" & born !="") %>% 
  mutate(prize_age = as.numeric(year) - as.numeric(substr(born,1,4))) %>% group_by(category)%>% 
  summarise( mean_prize_age = mean(prize_age)) %>% 
  ggplot(aes(x= category, y = mean_prize_age, fill= category)) + geom_bar(stat = "identity") +
  labs(x= "Category", y ="Average age of the prize",title = "Average age of Nobel Prize winners by category")+
  geom_text(aes(label= round(mean_prize_age,2)),nudge_y = 2)
  


# Q4: Which are the ten birth countries with the most Nobel Prize winners?
filter(Laureate, bornCountry!="" ) %>%  group_by(bornCountry) %>% tally() %>% arrange(n)%>% 
  mutate(bornCountry=factor(bornCountry, levels=bornCountry)) %>% tail(10)%>%
  ggplot(aes(x= bornCountry, y = n,fill = bornCountry))+geom_bar(stat = "identity")+
  labs(title ="The ten birth countries with the most Nobel Prize winners" , x= "Country", y = "The number of Nobel Prize winner")+
  theme(axis.text.x = element_text(angle = 50, hjust = 1))+geom_text(aes(label= n),nudge_y = 10)

# Q5: Which are the ten death countries with the most Nobel Prize winners?
filter(Laureate, diedCountry!="" ) %>%  group_by(diedCountry) %>% tally() %>% arrange(n)%>% 
  mutate(diedCountry=factor(diedCountry, levels=diedCountry)) %>% tail(10)%>%
  ggplot(aes(x= diedCountry, y = n,fill = diedCountry))+geom_bar(stat = "identity")+
  labs(title ="The ten death countries with the most Nobel Prize winners" , x= "Country", y = "The number of Nobel Prize winner")+
  theme(axis.text.x = element_text(angle = 50, hjust = 1))+geom_text(aes(label= n),nudge_y = 10)

# Q6: What is ratio of male and female winners in each category?
Laureate %>% filter(gender == "male" | gender == "female") %>% 
  group_by(category,gender)%>% tally() %>%  mutate(prop = round((n/ sum(n)),3))  %>% 
  ggplot(aes( x= "" , y = prop, fill = gender)) +
  geom_bar(width = 1, stat = "identity")+ geom_text(aes(label= percent(prop)),size=5,position = position_stack(vjust = 0.5))+ 
  labs(title = "The ratio of male and female winners in each category", x="", y = "")+
  facet_wrap(~category)+coord_polar("y",start = 0)+
  theme_minimal()+theme(axis.ticks = element_blank(), 
                        axis.text.y = element_blank(),
                        axis.text.x = element_blank()) 

# Q7: What is the migration pattern between the birth country and death country of Nobel laureates?
filter(Laureate, bornCountry!="" ) %>%  group_by(bornCountry) %>% tally() %>% arrange(n)%>%
  tail(10) 

Laureate %>% filter(bornCountry!="" & diedCountry != ""& bornCountry != diedCountry)%>%
  mutate(Top10_BornCountry = case_when(
    bornCountry == "USA" ~ "USA",
    bornCountry == "Germany" ~ "Germany",
    bornCountry == "United kingdom" ~ "United kingdom",
    bornCountry == "France" ~ "France",
    bornCountry == "Sweden" ~ "Sweden",
    bornCountry == "Poland" ~ "Poland",
    bornCountry == "Japan" ~ "Japan",
    bornCountry == "Italy" ~ "Italy",
    bornCountry == "the Netherlands" ~ "the Netherlands",
    bornCountry == "Russia" ~ "Russia",
    TRUE ~ "Others" 
    ))%>% ggplot(
  aes(x=0, y = bornCountry, xend= diedCountry, yend = 0, color = Top10_BornCountry))+
  geom_curve(curvature = -0.4)+ scale_x_discrete() + scale_y_discrete() +
 theme_minimal()+
  theme(panel.grid = element_blank(),
    plot.background = element_rect(fill = "grey"),
    axis.text.x = element_text(angle = 50, hjust = 1))+ labs(title = "The migration pattern between the birth country and death country of Nobel laureates",
                                                             x = "Death Country", y ="Birth Country")

# Q8: What are the trends in the age of Nobel Prize winners in each category?
Laureate %>% filter(substr(born,1,4) != "0000") %>% 
  mutate(prize_age = as.numeric(year) - as.numeric(substr(born,1,4))) %>% group_by(category)%>% 
  ggplot(aes(x= year, y = prize_age)) + geom_smooth(method ="lm")+ geom_point()+
  labs(x= "year", y ="the age of the prize winners",title = "Average age of Nobel Prize winners by category")+
  facet_wrap(~category)+scale_x_continuous(breaks = seq(1900, 2016, 20))
