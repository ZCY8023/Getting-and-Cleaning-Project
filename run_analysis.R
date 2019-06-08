# Getting and Cleaning Data Project

# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation for each measurement.
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names.
# 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


# get the data
library("data.table","reshape2")
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,file.path(path,"data.zip"))
unzip(zipfile = "data.zip")

# load train&test sets and merge
train <- fread(file.path(path,"UCI HAR Dataset/train/X_train.txt"))
TrainActivity <- fread(file.path(path,"UCI HAR Dataset/train/y_train.txt"))
TrainSubject <- fread(file.path(path,"UCI HAR Dataset/train/subject_train.txt"))
train <- cbind(TrainSubject,TrainActivity,train)

test <- fread(file.path(path,"UCI HAR Dataset/test/X_test.txt"))
TestActivity <- fread(file.path(path,"UCI HAR Dataset/test/y_test.txt"))
TestSubject <- fread(file.path(path,"UCI HAR Dataset/test/subject_test.txt"))
test <- cbind(TestSubject,TestActivity,test)

combined <- rbind(train,test)

# extract only the measurements on the mean and std
ActivityLabel <- fread(file.path(path,"UCI HAR Dataset/activity_labels.txt"),
                       col.names = c("ClassLabel","ActivityName"))

Feature <- fread(file.path(path,"UCI HAR Dataset/features.txt"),
                 col.names = c("FeatureIndex","FeatureName"))

FeatureExtracted <- grep("(mean|std)\\(\\)",Feature$FeatureName)

Measurements <- Feature[FeatureExtracted,FeatureName]
Measurements <- gsub('[()]','',Measurements)

combined <- combined[,c(1,2,FeatureExtracted+2), with = FALSE]

# label the data set with descriptive variable names.
colnames(combined) <- c("SubjectNumber","Activity",Measurements)

# Uses descriptive activity names to name the activities in the data set
combined$Activity<-factor(combined$Activity,levels = ActivityLabel$ClassLabel, 
                          labels = ActivityLabel$ActivityName)

         
# creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.

CombinedMelt <- melt(combined,id = c("SubjectNumber","Activity"))
TidyData <- dcast(CombinedMelt, SubjectNumber + Activity ~ variable,mean)

write.table(TidyData,file = "TidyData.txt", row.names = FALSE)


