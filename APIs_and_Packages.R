#getwd()
#Session- Set Working Directory- To Source File Location
#warnings could be package interference
setwd("get")

########################################
# Twitter API                          #
########################################
install.packages('twitteR')
library(twitteR)
#setting up the connection
consumer_key <- "dYCPvsWmjtoqDxyQ73Jx0Wd0J" 
consumer_secret <- "s3EhmK67BVEWMurtEe5k4RjaeisnkQfy109VpJZD225ws3Q4Zw" 
access_token <- "570660011-z5ci1luVcgWAIN9vKxxDi57Zg3UQIGqwu44z5dGv" 
access_token_secret <- "xH9any0kf8VlnkLeCfurrteOwZpNaoC7GuFCeh7ORa0oH" 
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_token_secret)

#Extract Tweets
#The API may be randomly sampling from Tweets
?searchTwitter  #can return 20000 Tweets at the free Tier level
times_up_tweets <- searchTwitter("#TimesUp", n=20000, lang ="en")

#JSON is returned (see code below as an example of JSON)-Can be messy. So instead, use a function.
#{'root' {
#        'header'{
#                'font.size':10
#                'background': 'grey'
#  }
#  'body'{
#    'font.size': 8
#    'background': 'blue'
#    'link.color': 'orange'
#        }
#    }
#}
#converts JSON Tweets to a data frame
tweets_df <- twListToDF(times_up_tweets)
write.csv(tweets_df, "nlptweets.csv")
#favorited- whether Tweets were favorited, what might be trending/viral etc. 
#created- the date time
#statusSource- what platform it's coming from, e.g. Twitter web app or Twitter for iPhone
#screenname- look at repeat Tweeters- e.g. DarinTNelson is Tweeting TimesUp stuff-let's reach out to him to understand the situation
#retweetCount- whether it's gone viral
#isRetweet- whether the Tweet has been retweeted
#longitude and latitutde is NA values
str(tweets_df)

########################################
# Analytics                            #
########################################
#info about each of the fields
summary(tweets_df)
head(tweets_df)
#there is a lot of repeat text- lots of Retweets-4091 and 1890 non-Retweets
#you should include all of the Tweets b/c it represents the overall movement of #TimesUp
#DarinTNelson is here twice-may be of interest

###############
# LUBRIDATE   #
###############
#makes working with dates easier
#can explore more by looking at ?lubridate
#good idea to spend half a day with each package, learning it
install.packages("lubridate")
library(lubridate)
?lubridate

#look at format of date and time zone, etc. 
tweets_df$created <- ymd_hms(tweets_df$created)

#converts from to Coordinated Universal Time UTC/Greenwich Mean Time to Mountain Time Zone MDT (the one I'm in)
tweets_df$created <- with_tz(tweets_df$created)

#Engineer some features
#group Tweets by hour and see if there are any patterns
tweets_df$hour <- hour(tweets_df$created)
tweets_df$month <- month(tweets_df$created)
tweets_df$weekday <- wday(tweets_df$created)  #which weekday a Tweet was on

###############
# STRINGR     #
###############
install.packages("stringr")
library(stringr)
str_locate('Hello I am doing NLP!', 'NLP')
str_pad('Hello World', width=20, side='left', pad = 'x')
str_to_lower('HELLO I AM NOT YELLING!')
str_to_upper('i am not being meek')
str_trim('String has too much whitespace     ')

#Looking at a list of popular Twitter social impact hashtags and removing the hashtag symbol
Hashtags <- c("#TimesUp", "#refugeeswelcome", "#MeToo", "#mentalhealth", "#humantraffiking", "#Everydaysexism")
str_remove(Hashtags, "[#]")

###############
# REGEX       #
###############
#Character matching set of tools
#all related to regular expressions
#Gsub can be used to subsitute strings or patterns- it is case-sensitive. Doesn't pick up lower-case curt
gsub('Curt', 'Bad guy', c('Kurt is my name', 
                         'Curt is not a good guy', 
                         'Hello World',
                         'Curt', 
                         'what about curt'))
?gsub
?regex
?grep

Hashtags <- c("#TimesUp", "#refugeeswelcome", "#MeToo", "#mentalhealth", "#humantraffiking", "#Everydaysexism")

#. matches any single character, in grep
grep("Times.", Hashtags, value = TRUE)
# this returns: "#TimesUp"

###############
# DPLYR       #
###############
#by far the most useful one in analytics-you can do tutorials just on dplyr. 
#A lot like SQL
#Piping into Retweet
#One question that came up: are Retweets not able to be favorited? 
library(dplyr)
tweets_df %>%                       #data frame
        group_by(isRetweet) %>%     #have to partition/group by a categorical variable
        summarise(med_fav=median(favoriteCount), #summarize on each level of that                                                        category
                  mean_fav=mean(favoriteCount),
                  samp_size=n())

#looking at ReTweets count from greatest to smallest. There is some repetition in screen names
tweets_df %>%
  arrange(desc(retweetCount))

###############
# GGPLOT2     #
###############
library(ggplot2)
#All ggplots require 3 parameters
#1. Data frame
#2. Aesthetic layer (maps features to dimensions, e.g. hour on the x-axis)
#3. Geometry layer (specify the format of the data type)
#I added in color since last time
ggplot(tweets_df, aes(x=hour, y=favoriteCount, color = isRetweet)) + 
  geom_point()

#most Tweets get 0-50 favorites
#maybe Tweets more likely to go viral in the afternoon


#################################
# R Fundamentals                #
#################################

###############
# IF/ELSE     #
###############
#It's a good idea to practice making if/else statements in R
x <- -5
if(x > 0){
  print("Positive number")
} else {
  print("Negative number")
}

###############
# FOR LOOPS   #
###############
#It's also a good idea to practice making for loops in R
#an example to count the number of even numbers in a vector
x <- c(2,5,3,9,8,11,6)
count <- 0
for (val in x) {
  if(val %% 2 == 0)  count = count+1
}
print(count)


#An example showing that there are other APIs out there: NewsAPI.org-I set up an account
# I configured an account with the NewsAPI in R
 


install.packages('newsanchor')
library(newsanchor)

NEWSAPI_KEY <- "767c7129bc9e4799a76e5aa29c53dbe6" # you can generate this at the NewsAPI site
## save to .Renviron file
cat(
  paste0("NEWSAPI_KEY=767c7129bc9e4799a76e5aa29c53dbe6", NEWSAPI_KEY),
  append = TRUE,
  fill = TRUE,
  file = file.path("~", ".Renviron")
)
set_api_key(NEWSAPI_KEY, path = '/Users/jenniferwolfson/.Renviron')  #change path here to my user name

analytics_headlines <- get_headlines(query = "Analytics")
analytics_news <- get_everything_all(query='Analytics')


