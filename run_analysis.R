library(reshape2)
library(zip)
filename <- "./getdata_dataset.zip"
## Download and unzip the dataset:
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, filename)
} 

##unziping files
if (!file.exists("./UCI HAR Dataset")) { 
        unzip(filename) 
}

# Load activity labels & conver Factor to characters
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

# Load features into table & conver Factor to characters
features <- read.table("./UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extracting the datas on mean and standard deviation only
featuresDesired <- grep(".*mean.*|.*std.*", features[,2])
featuresDesired.names <- features[featuresDesired,2]
featuresDesired.names = gsub('-mean', 'Mean', featuresDesired.names)
featuresDesired.names = gsub('-std', 'Std', featuresDesired.names)
featuresDesired.names <- gsub('[-()]', '', featuresDesired.names)


# Load the Train datasets (x_train,y_train, and subject_train)
trainX <- read.table("./UCI HAR Dataset/train/X_train.txt")
trainX <- trainX[featuresDesired]
trainY <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")
trainData <- cbind(trainSubjects, trainY, trainX)

# Load the Ttest datasets (x_test,y_test, and subject_test)
testX <- read.table("./UCI HAR Dataset/test/X_test.txt")
testX <- testX[featuresDesired]
testY <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
testData <- cbind(testSubjects, testY, testX)

# merging training and test datasets and labling data set with descriptive activity
allData <- rbind(trainData, testData)
colnames(allData) <- c("subject", "activity", featuresDesired.names)

# turning activities & subjects into factors, and putting descreptive activity names
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

## converting data into melted data frame
allData.melted <- melt(allData, id = c("subject", "activity"))

## creating independent tidy data set with average of each variable and each activity and each subject
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)
write.table(allData.mean, "./tidy.txt", row.names = FALSE, quote = FALSE)

## end