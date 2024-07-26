install.packages("tidyverse")
install.packages("tm")
install.packages("SmowballC")
install.packages("tidytext")
install.packages("textdata")
install.packages("corrplot")
install.packages("car")

library(carData)
library(car)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(NLP)
library(tm)
library(data.table)
library(SnowballC)
library(tidytext)
library(tidyverse)
library(textdata)
library(corrplot)

# 0. 데이터 불러오기
getwd() 
london <- read.csv("listings.csv")

## 분석할 변수 선택
selected_columns = c("description","host_since","host_about",
                     "host_response_time", "host_response_rate", "host_is_superhost",
                     "host_total_listings_count", "host_has_profile_pic",
                     "latitude", "longitude","room_type","accommodates",
                     "bathrooms_text", "bedrooms", "beds", "amenities",
                     "price", "minimum_nights", "maximum_nights",
                     "number_of_reviews_ltm", "review_scores_rating", 
                     "review_scores_accuracy", "review_scores_cleanliness", 
                     "review_scores_checkin", "review_scores_communication", 
                     "review_scores_location", "instant_bookable")

london = london %>% select(selected_columns)

# 1. 데이터 확인
str(london)
sapply(london, class)

# 2. 전처리
# 2-1. 결측치 확인
sum(is.na(london))
colSums(is.na(london)) # 컬럼별 결측치 개수

london <- select(london, -c(bedrooms, longitude, latitude)) # 결측치가 많은 bedrooms 삭제 / 위도, 경도 삭제
colSums(is.na(london)) # 컬럼별 결측치 개수
london = na.omit(london) # 결측치 존재 행 삭제
sum(is.na(london)) # 다시 결측치 확인 : 0개

# 2-2. 변수 전처리
########## [description, host_about] ##########
cleanFun <- function(htmlString) {
  htmlString <- gsub("<.*?>", "", htmlString)
  htmlString <- gsub("[^A-Za-z]", " ", htmlString)
  htmlString <- removeWords(htmlString, stopwords('en'))
  htmlString <- gsub(" +", " ", htmlString)
  return(sapply(strsplit(htmlString, " "), length))
}
london$description <- cleanFun(london$description)
london$host_about <- cleanFun(london$host_about)

########## [host_since] ##########
dplyr::count(london, host_since, sort = TRUE)
london$host_since[which(london$host_since== '')]<- NA

sum(is.na(london$host_since))
london <- na.omit(london)

london$host_since <- as.Date("2023-09-06")-as.Date(london$host_since) # 기준 연도 바꿈
london$host_since <- as.numeric(london$host_since, units='days')

########## [host_response_time] ##########
table(london$host_response_time)
sum(is.na(london$host_response_time))

# 'N/A'를 'NoInfo'로 대체
london <- london %>%
  mutate(host_response_time = ifelse(host_response_time == 'N/A', 'NoInfo', host_response_time))

# change data type for dummy variable (character -> factor)
london$host_response_time=as.factor(london$host_response_time)

########## [host_response_rate] ##########
table(london$host_response_rate)
sum(is.na(london$host_response_rate))

# N/A 와 "" 값 : '0%' 로 변경 -> 응답 안했다고 간주 
london <- london %>%
  mutate(host_response_rate = ifelse(host_response_rate == 'N/A', '0%', host_response_rate))

# change data type (factor -> numeric) 
london$host_response_rate <- as.numeric(gsub("\\D", "", london$host_response_rate))
str(london)

########## [host_is_superhost] ############
#dummy variable --> t=1, f=0
london$host_is_superhost <- ifelse(london$host_is_superhost=='t',1,0)

# 변수 유형 바꿈
london$host_is_superhost <- as.factor(london$host_is_superhost)


########## [room_type] ##########
table(london$room_type)

# replace outlier with most frequent variable : 'Entire home/apt' 
# london %>% filter(room_type=='')
# which(london$room_type == '')
# london[66856,11] = 'Entire home/apt'

# check variable distribution
dplyr::count(london, room_type, sort = TRUE)

# change data type 
london$room_type = as.factor(london$room_type)

########## [bathrooms_text] ##########
#check variable distribution
dplyr::count(london, bathrooms_text, sort = TRUE)

#total 41 types of baths and shared-baths --> Regardless of bathroom type, only count number of bathroom
which(london$bathrooms_text == '')
london$bathrooms_text[which(london$bathrooms_text== '')]<- '1 bath'
london$bathrooms_text[which(london$bathrooms_text== 'Shared half-bath')] <- '1 bath'
london$bathrooms_text[which(london$bathrooms_text== 'Half-bath')]<- '1 bath'
london$bathrooms_text[which(london$bathrooms_text== 'Private half-bath')]<- '1 bath'

london$bathrooms_text <- as.numeric(gsub("[A-Za-z]", "", london$bathrooms_text))
#london$bathrooms_text <- ifelse(london$bathrooms_text==NA, 0, next)

########## [amenities] ##########
# count number of amenities
london$amenities <- sapply(strsplit(london$amenities, ","), length)
amenities <- table(london$amenities)
barplot(amenities, beside = TRUE, legend=TRUE)

########## [price] ##########
#remove "$" sign 
london$price = gsub("[\\$]","",london$price)

# change data type 
london$price = as.numeric(london$price)

# 결측치 행 삭제
sum(is.na(london$price))
london = na.omit(london)

########## [instant_bookable] ##########
london$instant_bookable <- ifelse(london$instant_bookable=='t',1,0)

# change to factor variables 
london$instant_bookable <- as.factor(london$instant_bookable)

#########[host_has_profile_pic]####################
# change to factor variables 
london$host_has_profile_pic <- ifelse(london$host_has_profile_pic == "t", 1, 0)
london$host_has_profile_pic <- as.factor(london$host_has_profile_pic)

# 추가 전처리
######################################
#             이상치 제거            #
######################################
summary(london)

### beds 변수 삭제
london = select(london, -c("beds"))

### price 로그 변환
london$price = log(london$price)
which.max(london$price)

### 화장실 가장 많은 1개 삭제
max_bathroom_row <- which.max(london$bathrooms_text)
london$bathrooms_text[36802] # 화장실 최대 개수
london <- london[-max_bathroom_row, ] # 화장실 0인 컬럼 삭제

### 화장실 비율 변환
london <- london[london$bathrooms_text != 0, ]
london$bathrooms_text = london$accommodates / london$bathrooms_text

### 이상치들 제거
london <- london[!(london$host_is_superhost == 1 & london$review_scores_rating < 4.8), ]
london <- london[!(london$description %in% boxplot.stats(london$description)$out), ]
london <- london[!(london$host_since %in% boxplot.stats(london$host_since)$out), ]
london <- london[!(london$host_total_listings_count %in% boxplot.stats(london$host_total_listings_count)$out), ]
london <- london[!(london$amenities %in% boxplot.stats(london$amenities)$out), ]
london <- london[!(london$price %in% boxplot.stats(london$price)$out), ]
london <- london[!(london$minimum_nights %in% boxplot.stats(london$minimum_nights)$out), ]
london <- london[!(london$maximum_nights %in% boxplot.stats(london$maximum_nights)$out), ]
london$review_scores_accuracy <- ifelse(london$review_scores_accuracy == "", 0, as.numeric(london$review_scores_accuracy))
london$review_scores_rating <- ifelse(london$review_scores_rating== "", 0, as.numeric(london$review_scores_rating))
london$review_scores_checkin <- ifelse(london$review_scores_checkin == "", 0, as.numeric(london$review_scores_checkin))
london$review_scores_cleanliness <- ifelse(london$review_scores_cleanliness == "", 0, as.numeric(london$review_scores_cleanliness))
london$review_scores_communication <- ifelse(london$review_scores_communication == "", 0, as.numeric(london$review_scores_communication))
london$review_scores_location <- ifelse(london$review_scores_location == "", 0, as.numeric(london$review_scores_location))

### 리뷰 0점 제거 ###
london <- london[london$review_scores_rating != 0, ]
london <- london[london$review_scores_accuracy != 0, ]
london <- london[london$review_scores_checkin != 0, ]
london <- london[london$review_scores_cleanliness != 0, ]
london <- london[london$review_scores_communication != 0, ]
london <- london[london$review_scores_location != 0, ]

# 4.8 이상 데이터 만들기
london_sh <- london[london$review_scores_rating >= 4.8, , drop = FALSE] 

# 2-3 최종 데이터 확인 # 이거 가지고 EDA
str(london) 
numeric_ld <- select_if(london, is.numeric)
cor(numeric_ld)
corrplot(cor(numeric_ld),method = "color") 

# 3. EDA (logtitude, latitude, bathrooms / beds 삭제 - accommodates랑 높은 상관관계인데 둘중에 beds를 삭제하는것이 좋다고 해석면에서 생각)
# description
summary(london$description)
ggplot(london, aes(x = london$host_is_superhost, y = london$description)) +
  geom_boxplot() +
  labs(title = "Box Plot of london$description by Superhost Status", x = "Superhost", y = "london$description") +
  theme_minimal()

ggplot(london, aes(x = london$description, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of london$description by Superhost Status",
       x = "london$description",
       y = "Count") +
  theme_minimal()

ggplot(london, aes(x = london$description, fill = london$host_is_superhost)) +
  geom_bar(position = "stack") +
  labs(title = "Distribution of london$description by Superhost Status",
       x = "london$description",
       y = "Count") +
  theme_minimal()

# host_since
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$host_since)) +
  geom_boxplot() +
  labs(title = "Box Plot of host_since by Superhost Status", x = "Superhost", y = "host_since") +
  theme_minimal()


ggplot(london, aes(x = london$host_since, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of host_since by Superhost Status",
       x = "host_since",
       y = "Count") +
  theme_minimal()

ggplot(london, aes(x = london$host_since, fill = london$host_is_superhost)) +
  geom_bar(position = "stack") +
  labs(title = "Distribution of host_since by Superhost Status",
       x = "host_since",
       y = "Count") +
  theme_minimal()

# host_about
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$host_about)) +
  geom_boxplot() +
  labs(title = "Box Plot of london$host_about by Superhost Status", x = "Superhost", y = "london$description") +
  theme_minimal()

ggplot(london, aes(x = host_about, fill = host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of host_about by Superhost Status",
       x = "host_about",
       y = "Count") +
  theme_minimal() +
  scale_x_discrete(limits = c(0,150)) +
  scale_y_continuous(limits = c(0,100))


ggplot(london, aes(x = london$host_about, fill = london$host_is_superhost)) +
  geom_bar(position = "stack") +
  labs(title = "Distribution of london$host_about by Superhost Status",
       x = "london$host_about",
       y = "Count") +
  theme_minimal() +
  scale_x_discrete(limits = c(0,150)) +
  coord_cartesian(ylim = c(0,300))

# host_response_time
summary(london$host_response_time)

## 수평 그래프
ggplot(london, aes(x = london$host_response_time, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "host_response_time & host_is_superhost", x = "host_response_time", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle =45, hjust = 1, size = 8)) 

## 수직 그래프
ggplot(london, aes(x =london$host_response_time, fill = london$host_is_superhost)) +
  geom_bar(position = "stack") +
  labs(title = "Distribution of london$host_response_time by Superhost Status",
       x = "london$host_response_time",
       y = "Count") +
  theme_minimal()

## 비율로 보기 
prop_data <- london %>%
  group_by(host_response_time, host_is_superhost) %>%
  summarise(count = n()) %>%
  group_by(host_response_time) %>%
  mutate(proportion = count / sum(count))

ggplot(prop_data, aes(x = host_response_time, y = proportion, fill = host_is_superhost)) +
  geom_col(position = "stack") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +
  labs(title = "Proportion of host_is_superhost by host_response_time",
       x = "host_response_time",
       y = "Proportion") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 6))


# host_response_rate
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$host_response_rate)) +
  geom_boxplot() +
  labs(title = "Box Plot of london$host_response_rate by Superhost Status", x = "Superhost", y = "london$host_response_rate") +
  theme_minimal()

summary(london$host_response_rate)
ggplot(london, aes(x = london$host_response_rate, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "host_response_rate & host_is_superhost", x = "host_response_rate", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8)) 

ggplot(london, aes(x =london$host_response_rate, fill = london$host_is_superhost)) +
  geom_bar(position = "stack") +
  labs(title = "Distribution of london$host_response_rate by Superhost Status",
       x = "london$host_response_rate",
       y = "Count") +
  theme_minimal()

# host_is_superhost(종속변수)
london$host_is_superhost
table(london$host_is_superhost)

## 막대그래프 
ggplot(london, aes(x = london$host_is_superhost, fill = host_is_superhost)) +
  geom_bar() +
  labs(title = "Distribution of host_is_superhost",
       x = "Superhost Status",
       y = "Count") +
  theme_minimal()

# host_total_listings_count
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$host_total_listings_count)) +
  geom_boxplot() +
  labs(title = "Box Plot of london$host_total_listings_count by Superhost Status", x = "Superhost", y = "london$host_total_listings_count") +
  theme_minimal()

ggplot(london, aes(x = london$host_total_listings_count, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "host_total_listings_count & host_is_superhost", x = "host_total_listings_count", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8)) + 
  coord_cartesian(xlim = c(0,10))  #이상치 날림

ggplot(london, aes(x = london$host_total_listings_count, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "stack") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "host_total_listings_count & host_is_superhost", x = "host_total_listings_count", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8)) + 
  coord_cartesian(xlim = c(0,10))  #이상치 날림

# host_has_profile_pic
london_super <- subset(london,host_is_superhost==1)
london_host <- subset(london,host_is_superhost==0)

## 수평 그래프
ggplot(london, aes(x = london$host_has_profile_pic, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "host_has_profile_pic & host_is_superhost", x = "host_has_profile_pic", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8)) 

## 수직 그래프
ggplot(london, aes(x = london$host_has_profile_pic, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "stack") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "host_has_profile_pic & host_is_superhost", x = "host_has_profile_pic", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8)) 

# 비율로 보기 
prop_data <- london %>%
  group_by(host_has_profile_pic, host_is_superhost) %>%
  summarise(count = n()) %>%
  group_by(host_has_profile_pic) %>%
  mutate(proportion = count / sum(count))

ggplot(prop_data, aes(x = factor(host_has_profile_pic), y = proportion, fill = factor(host_is_superhost))) +
  geom_col(position = "stack") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +
  labs(title = "Proportion of host_is_superhost by host_has_profile_pic",
       x = "Host_has_profile_pic",
       y = "Proportion") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 6))

# room_type
table(london_host$room_type)
table(london_super$room_type)

## 수평 그래프
ggplot(london, aes(x = london$room_type, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "room_type & host_is_superhost", x = "room_type", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 6)) 

## 수직 그래프
ggplot(london, aes(x = london$room_type, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "stack") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "room_type & host_is_superhost", x = "room_type", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 6)) 

## 비율로 보기
prop_data <- london %>%
  group_by(room_type, host_is_superhost) %>%
  summarise(count = n()) %>%
  group_by(room_type) %>%
  mutate(proportion = count / sum(count))

ggplot(prop_data, aes(x = factor(room_type), y = proportion, fill = factor(host_is_superhost))) +
  geom_col(position = "stack") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +
  labs(title = "Proportion of host_is_superhost by room_type",
       x = "room_type",
       y = "Proportion") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8))

# accommodates
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$accommodates)) +
  geom_boxplot() +
  labs(title = "Box Plot of london$accommodates by Superhost Status", x = "Superhost", y = "london$accommodates") +
  theme_minimal()

ggplot(london, aes(x = london$accommodates, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "accommodates & host_is_superhost", x = "accommodates", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8)) 

ggplot(london, aes(x = london$accommodates, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "stack") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "accommodates & host_is_superhost", x = "accommodates", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8)) 

# bathrooms_text
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$bathrooms_text)) +
  geom_boxplot() +
  labs(title = "Box Plot of london$bathrooms_text by Superhost Status", x = "Superhost", y = "london$bathrooms_text") +
  theme_minimal()

ggplot(london, aes(x = london$bathrooms_text, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "bathrooms_text & host_is_superhost", x = "bathrooms_text", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8))  +  # x축 레이블 크기 조절
  coord_cartesian(xlim = c(0, 5))  # 이상치날림

london_super <- subset(london,host_is_superhost==1)
london_host <- subset(london,host_is_superhost==0)
dplyr::count(london_host, bathrooms_text, sort = TRUE)
dplyr::count(london_super, bathrooms_text, sort = TRUE)

tbl_s <- london_super$bathrooms_text
tbl_h <- london_host$bathrooms_text

boxplot(list(tbl_h, tbl_s), 
        names = c("Host", "Super"),
        main = "Boxplot of Host vs Super Bathrooms_text",
        ylab = "Values",
        ylim = c(0, max(c(tbl_h, tbl_s)))) +  # x축 레이블 크기 조절
  
  # bedrooms -> 결측치 많아서 삭제
  bedrooms_h <- dplyr::count(london_host, bedrooms,sort = TRUE)
bedrooms_s <- dplyr::count(london_super, bedrooms,sort = TRUE)
dplyr::count(london_super, bedrooms,sort = TRUE)
dplyr::count(london_host, bedrooms,sort = TRUE)

ggplot(london, aes(x = london$bedrooms, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "bedrooms & host_is_superhost", x = "bedrooms", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8)) +  # x축 레이블 크기 조절
  coord_cartesian(xlim = c(0, 22))  # x축 범위 지정

## 박스 플롯
ggplot(london, aes(x = factor(london$host_is_superhost), y = london$beds)) +
  geom_boxplot() +
  labs(title = "Box Plot of beds by Superhost Status", x = "Superhost", y = "beds") +
  theme_minimal()

ggplot(london, aes(x = london$beds, fill = factor(london$host_is_superhost))) +
  geom_bar(position = "stack") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +  # 슈퍼호스트 여부에 따른 색 지정
  labs(title = "bedrs & host_is_superhost", x = "beds", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8)) +  # x축 레이블 크기 조절
  coord_cartesian(xlim = c(0, 10)) #이상치 날림

# amenities
## 박스 플롯
ggplot(london, aes(x = factor(london$host_is_superhost), y = london$amenities)) +
  geom_boxplot() +
  labs(title = "Box Plot of amenities by Superhost Status", x = "Superhost", y = "amenities") +
  theme_minimal()

ggplot(london, aes(x = london$amenities, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of Amenities by Superhost Status",
       x = "Amenities",
       y = "Count") +
  theme_minimal()

ggplot(london, aes(x = london$amenities, fill = london$host_is_superhost)) +
  geom_bar(position = "stack") +
  labs(title = "Distribution of Amenities by Superhost Status",
       x = "Amenities",
       y = "Count") +
  theme_minimal()

# price
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$price)) +
  geom_boxplot() +
  labs(title = "Box Plot of price by Superhost Status", x = "Superhost", y = "price") +
  theme_minimal()

ggplot(london, aes(x = london$price, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of price by Superhost Status",
       x = "price",
       y = "Count") +
  theme_minimal()

ggplot(london, aes(x = london$price, fill = london$host_is_superhost)) +
  geom_bar(position = "stack") +
  labs(title = "Distribution of price by Superhost Status",
       x = "price",
       y = "Count") +
  theme_minimal()

# minimum_nights
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$minimum_nights)) +
  geom_boxplot() +
  labs(title = "Box Plot of minimum_nights by Superhost Status", x = "Superhost", y = "minimum_nights") +
  theme_minimal()

ggplot(london, aes(x = london$minimum_nights, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of minimum_nights by Superhost Status",
       x = "minimum_nights",
       y = "Count") +
  theme_minimal()

# maximum_nights
## 박스플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$maximum_nights)) +
  geom_boxplot() +
  labs(title = "Box Plot of maximum_nights by Superhost Status", x = "Superhost", y = "maximum_nights") +
  theme_minimal()

ggplot(london, aes(x = maximum_nights, fill = host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of maximum_nights by Superhost Status",
       x = "maximum_nights",
       y = "Count") +
  theme_minimal()

# number_of_reviews_ltm
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$number_of_reviews_ltm)) +
  geom_boxplot() +
  labs(title = "Box Plot of number_of_reviews_ltm by Superhost Status", x = "Superhost", y = "number_of_reviews_ltm") +
  theme_minimal()

ggplot(london, aes(x = london$number_of_reviews_ltm, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of number_of_reviews_ltm by Superhost Status",
       x = "number_of_reviews_ltm",
       y = "Count") +
  theme_minimal()

# review_scores_rating
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$review_scores_rating)) +
  geom_boxplot() +
  labs(title = "Box Plot of review_scores_rating by Superhost Status", x = "Superhost", y = "review_scores_rating") +
  theme_minimal()

ggplot(london, aes(x = london$review_scores_rating, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of review_scores_rating by Superhost Status",
       x = "review_scores_rating",
       y = "Count") +
  theme_minimal()

# review_scores_accuracy
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$review_scores_accuracy)) +
  geom_boxplot() +
  labs(title = "Box Plot of review_scores_accuracy by Superhost Status", x = "Superhost", y = "review_scores_accuracy") +
  theme_minimal()

ggplot(london, aes(x = london$review_scores_accuracy, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of review_scores_accuracy by Superhost Status",
       x = "review_scores_accuracy",
       y = "Count") +
  theme_minimal()

# review_scores_cleanliness
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$review_scores_cleanliness)) +
  geom_boxplot() +
  labs(title = "Box Plot of review_scores_cleanliness by Superhost Status", x = "Superhost", y = "review_scores_cleanliness") +
  theme_minimal()

ggplot(london, aes(x = london$review_scores_cleanliness, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of review_scores_cleanliness by Superhost Status",
       x = "review_scores_cleanliness",
       y = "Count") +
  theme_minimal()

# review_scores_checkin
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$review_scores_checkin)) +
  geom_boxplot() +
  labs(title = "Box Plot of review_scores_checkin by Superhost Status", x = "Superhost", y = "review_scores_checkin") +
  theme_minimal()

ggplot(london, aes(x = london$review_scores_checkin, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of review_scores_checkin by Superhost Status",
       x = "review_scores_checkin",
       y = "Count") +
  theme_minimal()


# review_scores_communication
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$review_scores_communication)) +
  geom_boxplot() +
  labs(title = "Box Plot of review_scores_communication by Superhost Status", x = "Superhost", y = "review_scores_communication") +
  theme_minimal()

ggplot(london, aes(x = london$review_scores_communication, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of review_scores_communication by Superhost Status",
       x = "review_scores_communication",
       y = "Count") +
  theme_minimal()

# review_scores_location
## 박스 플롯
ggplot(london, aes(x = london$host_is_superhost, y = london$review_scores_location)) +
  geom_boxplot() +
  labs(title = "Box Plot of review_scores_location by Superhost Status", x = "Superhost", y = "review_scores_location") +
  theme_minimal()

ggplot(london, aes(x = london$review_scores_location, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of review_scores_location by Superhost Status",
       x = "review_scores_location",
       y = "Count") +
  theme_minimal()

# instant_bookable
table(london$host_is_superhost,london$instant_bookable)

## 수평 그래프
ggplot(london, aes(x = london$instant_bookable, fill = london$host_is_superhost)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribution of instant_bookable by Superhost Status",
       x = "instant_bookable",
       y = "Count") +
  theme_minimal()

## 수직 그래프
ggplot(london, aes(x = london$instant_bookable, fill = london$host_is_superhost)) +
  geom_bar(position = "stack") +
  labs(title = "Distribution of instant_bookable by Superhost Status",
       x = "instant_bookable",
       y = "Count") +
  theme_minimal()

## 비율로 보기
prop_data <- london %>%
  group_by(instant_bookable, host_is_superhost) %>%
  summarise(count = n()) %>%
  group_by(instant_bookable) %>%
  mutate(proportion = count / sum(count))

ggplot(prop_data, aes(x = factor(instant_bookable), y = proportion, fill = factor(host_is_superhost))) +
  geom_col(position = "stack") +
  scale_fill_manual(values = c("0" = "red", "1" = "blue")) +
  labs(title = "Proportion of host_is_superhost by instant_bookable",
       x = "instant_bookable",
       y = "Proportion") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 8))

# 3.1 기술 통계량
str(london)
dim(london)


# 3.2 시각화

# 4. model
# 4.1 모델 생성
# 모델 0 (로그변환x, 변수변환x)
mod0 = glm(host_is_superhost~.,data = london, family = binomial(link="logit"))
summary(mod0) # AIC: 24037 


# 모델 1 (PCA X)
mod1 = glm(host_is_superhost~.,data = london, family = binomial(link="logit"))
summary(mod1) # AIC: 25910 

# PCA
selected_columns_reviews = c("review_scores_rating", 
                             "review_scores_accuracy", "review_scores_cleanliness", 
                             "review_scores_checkin", "review_scores_communication", 
                             "review_scores_location")

reviews = london %>% select(selected_columns_reviews)

##### PCA 시각화 #####
pca_result <- prcomp(reviews, scale. = TRUE) # PCA 수행
summary(pca_result) # PCA 결과 요약 표시
screeplot(pca_result, type = "line", main = "Scree Plot") # PCA 수행 결과를 이용하여 scree plot 그리기
screeplot(pca_result, type = "barplot", main = "Cumulative Proportion of Variance") # 주성분이 설명하는 분산의 누적 비율을 시각화하는 scree plot


##### PCA 계수 확인 #####
install.packages("FactoMineR")
library(FactoMineR)
pca = PCA(reviews)
coefficients <- pca$var$coord
print("주성분 계수:")
print(coefficients)

##### PCA 새로운 변수 추가 #####
london['review_scores'] = 
  0.9248577*london['review_scores_rating'] +
  0.8988699*london['review_scores_accuracy'] +
  0.8242932*london['review_scores_cleanliness'] +
  0.8370093*london['review_scores_checkin'] +
  0.8651945*london['review_scores_communication'] +
  0.7306668*london['review_scores_location'] 
str(london)
selected_columns = c("review_scores_rating","review_scores_accuracy", "review_scores_cleanliness",
                      "review_scores_checkin", "review_scores_communication","review_scores_location")
london = london %>% select(-selected_columns)

# 모델 2 PCA 
mod2 = glm(host_is_superhost~.,data = london, family = binomial(link="logit"))
summary(mod2) # AIC: 26972 

# 모델 3 PCA + maximum_nights 삭제
deviance_value <- anova(mod2, test = "Chisq") # deviance 확인
deviance_value
mod3 = glm(host_is_superhost ~ description + host_since + host_about + host_response_time + 
             host_response_rate + host_total_listings_count + host_has_profile_pic + 
             room_type + accommodates + bathrooms_text + amenities + price + 
             minimum_nights + number_of_reviews_ltm + 
             instant_bookable + review_scores,data = london, family = binomial(link="logit"))
summary(mod3) # AIC: 26984 

# 최종 모델 상관관계 확인
london_mod = select(london, -c("maximum_nights"))
numeric_ld <- select_if(london_mod, is.numeric)
cor(numeric_ld)
corrplot(cor(numeric_ld),method = "color") 

######### 추가 분석
ggplot(london_sh, aes(x = london_sh$host_is_superhost, y = london_sh$reponse_rate)) +
  geom_boxplot() +
  labs(title = "Box Plot of london_sh$reponse_rate by Superhost Status", x = "Superhost", y = "london_sh$reponse_rate") +
  theme_minimal()

ggplot(london_sh, aes(x = london_sh$host_is_superhost, y = london_sh$amenities)) +
  geom_boxplot() +
  labs(title = "Box Plot of london_sh$amenities by Superhost Status", x = "Superhost", y = "london_sh$amenities") +
  theme_minimal()

ggplot(london_sh, aes(x = london_sh$host_is_superhost, y = london_sh$bathrooms_text)) +
  geom_boxplot() +
  labs(title = "Box Plot of london_sh$bathrooms_text by Superhost Status", x = "Superhost", y = "london_sh$bathrooms_text") +
  theme_minimal()

