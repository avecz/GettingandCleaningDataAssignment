# config variables - not necessary if Samsung data is already in the working directory.
#  oldwd <- "C:/Users/pedro/Documents/Coursera/Data Science JHU"
#  setwd(paste(oldwd,"Course 3 - Getting and Cleaning Data", "Course Project", "getdata_projectfiles_UCI HAR Dataset", "UCI HAR Dataset", sep = "/"))

projectdir <- getwd()

# invoke all libraries necessary for the script
  library(dplyr)

# 1.  Merges the training and the test sets to create one data set.
  
  #1.a load the column (variables) names. Will be used for both the test and train sets.
    columnnames <- read.table(paste(projectdir,"features.txt",sep = "/"))
  
  #1.b load the test set
    testdata <- read.table(paste(projectdir,"test","X_test.txt",sep = "/"))
    names(testdata) <- columnnames$V2

    testlabels <- read.table(paste(projectdir,"test","y_test.txt",sep = "/"))
    testdata$label = testlabels$V1

    testsubject <- read.table(paste(projectdir,"test","subject_test.txt",sep = "/"))
    testdata$subject = testsubject$V1

  #1.c load the train set
    traindata <- read.table(paste(projectdir,"train","X_train.txt",sep = "/"))
    names(traindata) <- columnnames$V2

    trainlabels <- read.table(paste(projectdir,"train","y_train.txt",sep = "/"))
    traindata$label = trainlabels$V1

    trainsubject <- read.table(paste(projectdir,"train","subject_train.txt",sep = "/"))
    traindata$subject = trainsubject$V1

  #1.d Finally, merge the test and train sets together
    mergeddata <- bind_rows(traindata, testdata)


# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
  #2.a  the measurements (columns) were extracted using the select function alongside with contains function.
    onlystdandmean <- select(mergeddata, "subject", "label", contains("std()"),contains("mean()"))

# 3. Uses descriptive activity names to name the activities in the data set
  #3.a  Preparation: create an activity vector, with the code and description for each activity.
    activitylabels <- read.table(paste(projectdir,"activity_labels.txt",sep = "/"))
    activityvector <- activitylabels$V2
    names(activityvector) <- activitylabels$V1
  #3.b  use the mutate function to create a new variable, using the newly created activity vector
  #     to bring the correct activity based on the activity label number.
    DataWithDescriptiveActivityNames <- mutate(onlystdandmean, label = as.vector(activityvector[label]))

# 4.  Appropriately labels the data set with descriptive variable names.
    tidydata <- DataWithDescriptiveActivityNames
  #4.a  several steps were taken to appropriately name the variables, as described below:
  #lowercase all the variables
    names(tidydata) <- tolower(names(tidydata))
  #change all abreviations to more specif names:
    names(tidydata) <- sub("acc","accelerometer",names(tidydata))
    names(tidydata) <- sub("gyro","gyroscope",names(tidydata))
    names(tidydata) <- sub("mag","magnitude",names(tidydata))
    names(tidydata) <- sub("std\\(\\)","Stdeviation",names(tidydata))
    names(tidydata) <- sub("^t","time",names(tidydata))
    names(tidydata) <- sub("^f","frequency",names(tidydata))
    names(tidydata) <- sub("x$","xaxis",names(tidydata))
    names(tidydata) <- sub("y$","yaxis",names(tidydata))
    names(tidydata) <- sub("z$","zaxis",names(tidydata))
  #remove all special characters
    names(tidydata) <- sub("\\(\\)","",names(tidydata))
    names(tidydata) <- gsub("\\-","",names(tidydata))

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
  tidydataaverage <- group_by(tidydata, subject, label)
  tidydataaverage <- summarize_all(tidydataaverage, mean)