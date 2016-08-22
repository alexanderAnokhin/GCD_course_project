Code Book
==================
## Data
<p>These data were obtained from UCI Machine Learning Repository (see link below).</p> 
<p>http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones</p>
<p>Raw data consist of 10299 instances and 561 attributes and represent accelerometers data from the Samsung Galaxy S smartphone.</p>
## Data transformation
### Step 1. Merging train and test datasets

<p>Read train dataset</p>
```
train <- read.table(file = "UCI HAR Dataset/train/X_train.txt")
train.labels <- read.table(file = "UCI HAR Dataset/train/y_train.txt")
train.subjects <- read.table(file = "UCI HAR Dataset/train/subject_train.txt")
```

<p>Read test dataset</p>
```
test <- read.table(file = "UCI HAR Dataset/test/X_test.txt")
test.labels <- read.table(file = "UCI HAR Dataset/test/y_test.txt")
test.subjects <- read.table(file = "UCI HAR Dataset/test/subject_test.txt")
```

<p>Merge train and test datasets</p>
```
train <- cbind(train, train.subjects, train.labels)
test <- cbind(test, test.subjects, test.labels)
data <- rbind(train, test)
```

<p>Delete unused objects from environment</p>
```
rm(train, train.subjects, train.labels, test, test.labels, test.subjects)
```

### Step 2. Select only features on the mean and standard deviation

<p>Read features names</p>
```
features <- read.table(file = "features.txt", col.names = c("number", "feature"))
```

<p>Select features on the mean and standard deviation (use regular expressions to match the features)</p>
```
features <- features[grep("(mean|std)\\(\\)", features[, 2]), ]
data <- data[, c(features[, 1], dim(data)[2] - 1, dim(data)[2])]
```

### Step 3. Name variables appropriately

<p>Name variables</p>
```
names(data) <- c(as.character(features[, 2]), "subject", "activity.number")
```

### Step 4. Name activities appropriately

<p>Name activities (replace activity number by name)</p>
```
activities <- read.table(file = "activity_labels.txt", col.names = c("number", "activity"))
data <- merge(data, activities, by.x = "activity.number", by.y = "number")
data <- data[, -which(names(data) %in% c("activity.number"))]
```

<p> After steps 1 - 4 result dataset includes 66 numeric measurements (on the mean and standard deviation), subject variable representing identifier of the person who carried out the experiment and activity variable representing description of activity.</p>

### Step 5. Average variables for each activity and each subject

<p>Aggregate variables</p>
```
library(dplyr)
library(tidyr)

result <- tbl_df(data) %>%
  group_by(activity, subject) %>%
  summarise_each(funs(mean)) %>%
  gather(variable, mean, -c(activity, subject))
print(result)
write.table(result, row.name = FALSE, file = "tinyData.txt")
```

<p> The final tidy set consists of data averaged through all variables for each activity and each subject. It looks like:
```
  activity subject          variable      mean
1    LAYING       1 tBodyAcc-mean()-X 0.2215982
2    LAYING       2 tBodyAcc-mean()-X 0.2813734
3    LAYING       3 tBodyAcc-mean()-X 0.2755169
4    LAYING       4 tBodyAcc-mean()-X 0.2635592
5    LAYING       5 tBodyAcc-mean()-X 0.2783343
6    LAYING       6 tBodyAcc-mean()-X 0.2486565
7    LAYING       7 tBodyAcc-mean()-X 0.2501767
8    LAYING       8 tBodyAcc-mean()-X 0.2612543
9    LAYING       9 tBodyAcc-mean()-X 0.2591955
10   LAYING      10 tBodyAcc-mean()-X 0.2802306
..      ...     ...               ...       ...
```

## Data dictionary

<p>The output file (tinyData.txt) consists of four columns namely:
<br>activity - name of activity
<br>subject - identifier of the person who carried out the experiment
<br>variable - averaged variable
<br>mean - mean value of the given variable
<p>Alexander Anokhin. October 2016.