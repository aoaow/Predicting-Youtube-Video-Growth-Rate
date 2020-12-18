setwd("d:/Documents/R/projects/101c_final")
library(dplyr)
library(stringr)
library(randomForest)
library(e1071)
library(caret)
library(car)
library(lubridate)

#Load Data
training <- read.csv("training.csv")
test <- read.csv("test.csv")

#Feature Engineering 
PublishDate <- c(training$PublishedDate, test$PublishedDate)
date <- PublishDate %>% str_extract("(.*)(?=\\/)") %>% as.Date(format="%m/%d")
wkds <- weekdays(date)
wkds <- as.factor(wkds)
hrs <- PublishDate %>% 
  str_extract("(?<=\\s)(.*)(?=:)") %>% 
  as.factor()
hrs<- ordered(hrs, levels=c("0", "1", "2", "3", "4", "5", "6", "7", "8", 
                            "9", "10", "11", "12", "13", "14", "15", "16", 
                            "17", "18", "19", "20", "21", "22", "23"))
# mins <- PublishDate %>% 
#   str_extract("(?<=:)(.*)")
# mins <- ifelse(mins=="00", "60", mins)
# mins <- as.integer(mins)
# mins <- cut(mins, breaks=c(0, 10, 20, 30, 40, 50, 60))
##provide graphs
training$wkds <- wkds[1:7242]
training$hrs <- hrs[1:7242]
#training$mins <- mins[1:7242]
par(mfrow=c(1, 2))
ggplot(training, aes(x=hrs, y=growth_2_6)) +
  geom_boxplot(fill=rainbow(24)) +
  labs(x="Hours In A Day", y="growth_2_6")
ggplot(training, aes(x=wkds, y=growth_2_6)) +
  geom_boxplot(fill=rainbow(7)) +
  labs(x="Weekdays", y="growth_2_6")
ggplot(training, aes(x=mins, y=growth_2_6)) +
  geom_boxplot(fill=rainbow(6)) +
  labs(x="Minutes In An Hour", y="growth_2_6")

#subset data
subdata <- training[, 3:259]

#remove 0 vars
subdata <- subdata[, -nearZeroVar(subdata)]

#remove high correlated r.v's
subdata <- subdata[, -findCorrelation(cor(subdata), cutoff=.9)]

#Transform categorical
for (i in 141:151) {
  subdata[, i] <- as.factor(subdata[, i])
}
subdata$growth_2_6 <- training$growth_2_6
subdata$hrs <- training$hrs
subdata$wkds <- training$wkds
subdata$mins <- training$mins

#Feature Importance
set.seed(123)
recommended.mtry <- floor(sqrt(ncol(subdata)))
rf.imp <- randomForest(growth_2_6~., subdata, mtry=154, ntree=1500, importance=T)
imp <- importance(rf.imp, scale=F, type=1)
imp.ordered <- imp[order(abs(imp), decreasing=T),]
selected <- c(names(imp.ordered[1:30]), "growth_2_6")
# selected <- c("Duration", "views_2_hours", "hog_341", "cnn_10", "cnn_17", "cnn_19", "cnn_25", 
#               "cnn_68", "cnn_86", "cnn_88", "cnn_89", "mean_red", "sd_red", "mean_blue", 
#               "sd_blue", "punc_num_..1", "punc_num_..28", "num_chars", "num_uppercase_chars",
#               "num_digit_chars", "Num_Subscribers_Base_low_mid", "Num_Subscribers_Base_mid_high",
#               "Num_Views_Base_mid_high", "avg_growth_low", "avg_growth_low_mid", 
#               "avg_growth_mid_high", "count_vids_low_mid", "count_vids_mid_high",
#               "hrs", "mins", "growth_2_6")
subdata2 <- subdata[, which(colnames(subdata)%in%selected)]

######################Extra Stuff here
control <- trainControl(method="cv", number=10, search="grid")
set.seed(123)
tunegrid <- expand.grid(.mtry=c(5:30))
rf_gridsearch <- train(growth_2_6~., data=subdata2, method="rf", tuneGrid=tunegrid, trControl=control)
print(rf_gridsearch)
plot(rf_gridsearch)

######################

#fit model
rf <- randomForest(growth_2_6~., subdata2, importance=F, mtry=30, ntree=1500,
                   trControl=oob_train_control)

#Convert test data
test$wkds <- wkds[7243:10347]
test$hrs <- hrs[7243:10347]
test$mins <- mins[7243:10347]
for (i in 248:259) {
  test[, i] <- as.factor(test[, i])
}
pred <- predict(rf, newdata=test)
submit <- data.frame(id=test$id, growth_2_6=pred)
write.csv(submit, file="submit.csv", row.names = F)
