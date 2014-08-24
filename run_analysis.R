
#will not use data table sine when reading in x_train and x_test produces following error
#Not positioned correctly after testing format of header row. ch=' '
#Error in fread(paste(dir, "\\train\\", "X_train.txt", sep = "")) : 
#library(data.table)
library(reshape2)

dir <- "C:\\DataScience\\CourseProjectGettingAndCleaningData\\UCI HAR Dataset"

subj_train <- read.table(paste(dir, "\\train\\", "subject_train.txt", sep=""))
x_train <- read.table(paste(dir, "\\train\\", "X_train.txt", sep=""))
y_train <- read.table(paste(dir, "\\train\\", "Y_train.txt", sep=""))


subj_test <- read.table(paste(dir, "\\test\\", "subject_test.txt", sep=""))
x_test <- read.table(paste(dir, "\\test\\", "X_test.txt", sep=""))
y_test <- read.table(paste(dir, "\\test\\", "Y_test.txt", sep=""))

subj_bind <- rbind(subj_test, subj_train)

activity_labels <- read.table(paste(dir,"\\activity_labels.txt", sep=""), stringsAsFactors = FALSE)
features <- read.table(paste(dir,"\\features.txt", sep=""), stringsAsFactors = FALSE)

x_bind <- rbind(x_test, x_train)
y_bind <- rbind(y_test, y_train)
y_bind[,2] <- activity_labels[y_bind[,1],][,2]

names(x_bind) <- features[,2]


mean_and_std <- sapply(features[,2], function(x){ grep("mean|std", x, ignore.case = TRUE) > 0})
c_mean_and_std <- unlist(mean_and_std)

mean_and_std_columns <- x_bind[, names(c_mean_and_std)]

mean_and_std_columns$activity <- y_bind[,2]
mean_and_std_columns$subj <- subj_bind[,1]



#1) iterate through every feature and melt mean_and_std_columns
#2) iterate through all activities and subjects, get all subsets, calculate the mean, and 
#add the value to the final set

init_df <- function(n_subjects){
  n_activity <- length(activity_labels[,2])  
  s <- c()
  a <- c()
  
  for (activity in 1 : n_activity){
    activity_label = activity_labels[activity,2]
    for (subject in 1 : n_subjects){
        s <- append(s, subject)
        a <- append(a, activity_labels[activity,2])
    }  
  }
  data.frame(activity = a, subj = s)
}



get_mean <- function(measure_var, n_subjects){
  n_activity <- length(activity_labels[,2])
  v <- c()
  
  m <- melt(mean_and_std_columns, id = c("activity", "subj"), measure.vars=c(measure_var))
    
  for (activity in 1 : n_activity){
    activity_label = activity_labels[activity,2]
    for (subject in 1 : n_subjects){
      m2 <- m[(m$activity == activity_label & m$subj == subject),]
      activity_mean <- mean(m2$value)     
      v <- append(v, activity_mean)
    }  
  }
  v
}

df <- init_df(30)
for(f in names(mean_and_std_columns[, -which(names(mean_and_std_columns) %in% c("subj", "activity"))])){
  df[, f] <- get_mean(f, 30)
}

write.csv(df, file = paste(dir, "\\submission.csv", sep=""))

