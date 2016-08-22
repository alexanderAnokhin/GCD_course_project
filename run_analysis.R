## Read train dataset
train <- read.table(file = "UCI HAR Dataset/train/X_train.txt")
train.labels <- read.table(file = "UCI HAR Dataset/train/y_train.txt")
train.subjects <- read.table(file = "UCI HAR Dataset/train/subject_train.txt")

## Read test dataset
test <- read.table(file = "UCI HAR Dataset/test/X_test.txt")
test.labels <- read.table(file = "UCI HAR Dataset/test/y_test.txt")
test.subjects <- read.table(file = "UCI HAR Dataset/test/subject_test.txt")

## Merge train and test datasets
train <- cbind(train, train.subjects, train.labels)
test <- cbind(test, test.subjects, test.labels)
data <- rbind(train, test)

## Delete unused objects
rm(train, train.subjects, train.labels, test, test.labels, test.subjects)

## Read features names
features <- read.table(file = "UCI HAR Dataset/features.txt", col.names = c("number", "feature"))

## Select features on the mean and standard deviation (regular expressions to match the features)
features <- features[grep("(mean|std)\\(\\)", features[, 2]), ]
data <- data[, c(features[, 1], dim(data)[2] - 1, dim(data)[2])]

## Name variables
names(data) <- c(as.character(features[, 2]), "subject", "activity.number")

## Name activities (replace activity number by name)
activities <- read.table(file = "UCI HAR Dataset/activity_labels.txt", col.names = c("number", "activity"))
data <- merge(data, activities, by.x = "activity.number", by.y = "number")
data <- data[, -which(names(data) %in% c("activity.number"))]

## Aggregate variables
library(dplyr)
library(tidyr)

result <- tbl_df(data) %>%
  group_by(activity, subject) %>%
  summarise_each(funs(mean)) %>%
  gather(variable, mean, -c(activity, subject))
print(result)
write.table(result, row.name = FALSE, file = "tinyData.txt")