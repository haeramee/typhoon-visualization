library(tidyverse)
library(lubridate)
library(RColorBrewer)

data <- read_csv("ibtracs.WP.list.v04r00.csv")
str(data)

# 데이터 탐색

# 이름이 중복 사용되기도 하나
name.df <- data %>% 
  count(SEASON, NAME)

basin.df <- data %>% 
  count(BASIN)

# 힌남노가 육지에 도착했을 때의 강도가 다른 태풍에 비해 굉장히 강한 편 
# -> 얼마나 강한걸까

# 내가 궁금한 WP + 육지에 도착한 태풍 중에서 NA 값을 돌려주는 열은
df.1 <- data %>% 
  filter(BASIN == "WP" & LANDFALL == 0) %>% 
  map(~sum(is.na(.)))

# WMO_WIND가 NA면 TOKYO_WIND로 채워줘
df.2 <- data %>% 
  filter(BASIN == "WP" & LANDFALL == 0) %>%
  mutate(WIND_SPEED = coalesce(WMO_WIND, TOKYO_WIND))

# 그래도 NA가 있으면 USA_WIND로 채워줘
df.3 <- df.2 %>% 
  mutate(WIND_SPEED = coalesce(WIND_SPEED, USA_WIND))

df.3 %>% 
  map(~sum(is.na(.)))

# WP, LANDFALL=0, 풍속 데이터 최대한 채운 데이터셋, 필요한 열만 남기기 
df.4 <- df.3 %>% 
  select(c(SID:LON, STORM_SPEED, WIND_SPEED))

df.4 %>% 
  map(~sum(is.na(.)))

# 풍속이 그래도 NA인 경우 행 제외
# 이렇게하면 1945 이전 태풍들 안 잡힘.. 풍속 데이터가 없나봄
df.5 <- df.4 %>% 
  drop_na(WIND_SPEED) 

df.5 %>% 
  map(~sum(is.na(.)))

# 연대, 태풍 별 육지에 도착했을 시점에 최대 풍속
# 데이터셋에 있는 연도들은 언제부터 언제까지?
df.6 <- df.5 %>% 
  count(SEASON) # 1945~2022

# 각 태풍 별 시간, 위도에따른 최대 풍속 시각화
df.7 <- df.5 %>% 
  group_by(SID) %>% 
  slice_max(WIND_SPEED)

df.7 %>% 
  ggplot(aes(x=SEASON, y=LAT, size=WIND_SPEED)) +
  geom_point()

# 같은 태풍에 대해 max 중복 값이 있을 경우 시간 순 가장 앞에 있는거만 남기고 나머지 삭제
df.8 <- df.7 %>% 
  group_by(SID, NAME) %>% 
  slice_min(ISO_TIME)
  

df.8 %>% 
  ggplot(aes(x=LON, y=LAT)) +
  geom_point()

df.8 %>% 
  ggplot(aes(x=WIND_SPEED, y=LAT)) +
  geom_point()


# 연도 카테고리 만들기
# 1940s 1950s 1960s 1970s 1980s 1990s 2000s 2010s 2020s
df.9 <- df.8 %>% 
  mutate(
    category = case_when(
      SEASON >= 1940 & SEASON < 1950 ~ "1940s", # 1945~
      SEASON >= 1950 & SEASON < 1960 ~ "1950s",
      SEASON >= 1960 & SEASON < 1970 ~ "1960s",
      SEASON >= 1970 & SEASON < 1980 ~ "1970s",
      SEASON >= 1980 & SEASON < 1990 ~ "1980s",
      SEASON >= 1990 & SEASON < 2000 ~ "1990s",
      SEASON >= 2000 & SEASON < 2010 ~ "2000s",
      SEASON >= 2010 & SEASON < 2020 ~ "2010s",
      SEASON >= 2020 ~ "2020s", # ~2022
    )
  )

df.9 %>% 
  ggplot(aes(x=LON, y=LAT, size = WIND_SPEED, color = category)) +
  geom_point(alpha = 0.3) + 
  scale_color_manual(values = brewer.pal(n=9, name = "YlOrRd")) + 
  facet_grid(cols = vars(category)) +
  ggtitle("태풍 별 육지 위 최대 풍속")


# 각 태풍 별 시간, 위도에 따른 (육지 위) 최대 이동 속도 시각화

df.10 <- df.5 %>% 
  group_by(SID) %>% 
  slice_max(STORM_SPEED) %>% 
  slice_min(ISO_TIME)


df.11 <- df.10 %>% 
  mutate(
    category = case_when(
      SEASON >= 1940 & SEASON < 1950 ~ "1940s", # 1945~
      SEASON >= 1950 & SEASON < 1960 ~ "1950s",
      SEASON >= 1960 & SEASON < 1970 ~ "1960s",
      SEASON >= 1970 & SEASON < 1980 ~ "1970s",
      SEASON >= 1980 & SEASON < 1990 ~ "1980s",
      SEASON >= 1990 & SEASON < 2000 ~ "1990s",
      SEASON >= 2000 & SEASON < 2010 ~ "2000s",
      SEASON >= 2010 & SEASON < 2020 ~ "2010s",
      SEASON >= 2020 ~ "2020s", # ~2022
    )
  )

df.11 %>% 
  ggplot(aes(x=LON, y=LAT, size = STORM_SPEED, color = category)) +
  geom_point(alpha = 0.3) + 
  scale_color_manual(values = brewer.pal(n=9, name = "YlOrRd")) + 
  facet_grid(cols = vars(category)) +
  ggtitle("태풍 별 육지 위 최대 이동 속도")

# 지도 위에 시각화
install.packages("rnaturalearthdata")
library("ggplot2")
theme_set(theme_bw())
library("sf")
library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(scale = "medium", returnclass = "sf")
world$name

# Western north pacific basin 지도
ggplot(data = world) +
  geom_sf() +  
  coord_sf(xlim = c(80, 160), ylim = c(-5, 60), expand = FALSE) +
  geom_point(data = df.11, 
             aes(x=LON, y=LAT, 
                 size = STORM_SPEED, 
                 color = category), 
             alpha = 0.3) +
  scale_color_manual(values = brewer.pal(n=9, name = "YlOrRd"))+
  ggtitle("태풍 별 육지 위 최대 이동 속도")


# Western north pacific basin 지도 위에 시각화
ggplot(data = world) +
  geom_sf() +  
  coord_sf(xlim = c(80, 160), ylim = c(-5, 60), expand = FALSE) +
  geom_point(data = df.11, 
             aes(x=LON, y=LAT, 
                 size = STORM_SPEED, 
                 color = category), 
             alpha = 0.3) +
  scale_color_manual(values = brewer.pal(n=9, name = "YlOrRd"))+
  ggtitle("태풍 별 육지 위 최대 이동 속도")

ggplot(data = world) +
  geom_sf() +  
  coord_sf(xlim = c(80, 160), ylim = c(-5, 60), expand = FALSE) +
  geom_point(data = df.9, 
             aes(x=LON, y=LAT, 
                 size = WIND_SPEED, 
                 color = category), 
             alpha = 0.3) +
  scale_color_manual(values = brewer.pal(n=9, name = "YlOrRd"))+
  ggtitle("태풍 별 육지 위 최대 풍속")



