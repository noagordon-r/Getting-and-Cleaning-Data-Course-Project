# Load packages
library(plyr)
library(reshape2)

# Download and unzip zip file
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("data")) {
    dir.create("data")
}
#If the zip file doesn't exist download it
if(!file.exists("getdata_projectfiles_UCI_HAR_Dataset.zip")){
    download.file(Url,destfile="getdata_projectfiles_UCI_HAR_Dataset.zip", mode = "wb")
}
#Unzip the file if it hasn't already been unzipped
if(file.exists("getdata_projectfiles_UCI_HAR_Dataset.zip")){
    unzip(zipfile="getdata_projectfiles_UCI_HAR_Dataset.zip",exdir="data")
}

# Read files
main_path <- file.path("data/UCI HAR Dataset")
XTrain <- read.table(file.path(main_path, "train", "X_train.txt"))
XTest  <- read.table(file.path(main_path, "test" , "X_test.txt" ))
YTrain <- read.table(file.path(main_path, "train", "y_train.txt"))
YTest  <- read.table(file.path(main_path, "test" , "y_test.txt" ))
subTrain <- read.table(file.path(main_path, "train", "subject_train.txt"))
subTest  <- read.table(file.path(main_path, "test" , "subject_test.txt"))
features <- read.table(file.path(main_path, "features.txt"))[,2]
activities <- read.table(file.path(main_path,"activity_labels.txt"))[,2]

YTest[,2] = activities[YTest[,1]]
names(YTest) = c("activity", "activityLabel")
names(subTest) = "subject"
YTrain[,2] = activities[YTrain[,1]]
names(YTrain) = c("activity", "activityLabel")
names(subTrain) = "subject"
#only mean and STD measurements
names(XTrain)<- features
names(XTest)<- features
measurements <- grepl("mean|std", features)
XTrain <- XTrain[,measurements]
XTest <- XTest[,measurements]


# Merge 
#rows
Sub <- rbind(subTrain, subTest)
Y <- rbind(YTrain, YTest)
X <- rbind(XTrain, XTest)
#columns
merge <- cbind(Sub, Y, X)

#Label the merged data
names(merge)<-gsub("^t", "time", names(merge))
names(merge)<-gsub("^f", "frequency", names(merge))
names(merge)<-gsub("Gyro", "Gyroscope", names(merge))
names(merge)<-gsub("Acc", "Accelerometer", names(merge))
names(merge)<-gsub("BodyBody", "Body", names(merge))
names(merge)<-gsub("Mag", "Magnitude", names(merge))
merge[["activity"]] <- as.factor(merge[["activity"]])
merge[["subject"]] <- as.factor(merge[["subject"]])

tidy <- recast(data = merge, subject + activityLabel ~ variable, fun.aggregate = mean)
write.table(tidy, file = "tidy_data.txt",row.name=FALSE)
