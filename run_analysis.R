library(tidyverse)


## download data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "UCI HAR Dataset.zip"

if (!file.exists(fileName)) {
    download.file(url, fileName, mode = "wb")
}
## unzip the file
root <- "UCI HAR Dataset"
if (!file.exists(root)) {
    unzip(fileName)
}

## get the training sets
trainSubjects <- read.table(file.path(root, "train", "subject_train.txt"))
trainValues <- read.table(file.path(root, "train", "X_train.txt"))
trainActivities <- read.table(file.path(root, "train", "y_train.txt"))
trainSet <- cbind(trainSubjects, trainActivities, trainValues)

## get the test sets
testSubjects <- read.table(file.path(root, "test", "subject_test.txt"))
testValues <- read.table(file.path(root, "test", "X_test.txt"))
testActivities <- read.table(file.path(root, "test", "y_test.txt"))
testSet <- cbind(testSubjects, testActivities, testValues)


## get the features and labels
features <- read.table(file.path(root, "features.txt"), as.is = TRUE)
activities <- read.table(file.path(root, "activity_labels.txt"))
colnames(activities) <- c("activityId", "activityLabel")

## build the final data set
merged <- rbind(trainSet, testSet)
colnames(merged) <- c("subject", "activity", features[, 2])

# remove all columns other than mean and std
merged <- merged[, grepl("subject|activity|mean|std", colnames(merged))]

# replace activities with labels
merged$activity <- factor(merged$activity, levels = activities[, 1], labels = activities[, 2])

names(merged) <- gsub("^f", "frequency", names(merged))
names(merged) <- gsub("^t", "time", names(merged))
names(merged) <- gsub("Acc", "Accelerometer", names(merged))
names(merged) <- gsub("Gyro", "Gyroscope", names(merged))
names(merged) <- gsub("Mag", "Magnitude", names(merged))
names(merged) <- gsub("Freq", "Frequency", names(merged))
names(merged) <- gsub("mean", "Mean", names(merged))
names(merged) <- gsub("std", "StandardDeviation", names(merged))
names(merged) <- gsub("BodyBody", "Body", names(merged))

# group by mean and write to disk
tidySet <- merged %>% 
    group_by(subject, activity) %>%
    summarise_each(funs(mean))

write.table(tidySet, "tidy.txt", row.names = FALSE, quote = FALSE)


