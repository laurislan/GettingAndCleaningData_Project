# Download the file if it doesn't exist
fileName <- 'getdata_projectfiles_UCI HAR Dataset.zip'
if(!file.exists(fileName)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL,fileName)
}

# Unzips the file
if (!file.exists("UCI HAR Dataset")){unzip(fileName)}

#### MERGE BOTH TRAINING AND TEST SETS
# Load the activity labels
activityLabelsFile <- "UCI HAR Dataset/activity_labels.txt"
activityLabels <- read.table(activityLabelsFile)  
activityLabels$V2 <- as.character(activityLabels$V2)
# Load the features
featureLabelsFile <- "UCI HAR Dataset/features.txt"
featureLabels <- read.table(featureLabelsFile)  
featureLabels$V2 <- as.character(featureLabels$V2)

# Filter the features to take the std() and mean()
toMatch <- c("std","mean")
filterFeature <- grep(paste(toMatch,collapse="|"), featureLabels$V2)
featureLabelsMatch <- featureLabels[filterFeature,2]

# Uses descriptive activity names to name the activities in the data set
featureLabelsMatch <- gsub("[[:punct:]]","",featureLabelsMatch)
featureLabelsMatch <- gsub('mean', '_Mean', featureLabelsMatch)
featureLabelsMatch <- gsub('std', '_Std', featureLabelsMatch)

# Load the train dataset
train <- read.table("UCI HAR Dataset/train/X_train.txt")[filterFeature]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)
colnames(train) <- c("subject", "activity", featureLabelsMatch)

# Load the test dataset
test <- read.table("UCI HAR Dataset/test/X_test.txt")[filterFeature]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)
colnames(test) <- c("subject", "activity", featureLabelsMatch)

# Concatenate both files
finalData <- rbind(train,test)

# Appropriately labels the data set with descriptive variable names and assign levels to factor variables 
finalData$activity <- factor(finalData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
finalData$subject <- as.factor(finalData$subject)

# Calculate the mean for the variables for each pair of subject&activity
library(reshape2)
finalDataMelt = melt(finalData, id.vars = c("subject", "activity"))
finalData.mean <- dcast(finalDataMelt, subject + activity ~ variable, fun.agg = mean)

# Create a txt file with write.table() using row.name=FALSE 
write.table(finalData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
