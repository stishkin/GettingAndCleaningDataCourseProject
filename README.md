Getting And Cleaning Data Course Project
===================================

** The script performs the following analysis on training and test datasets

- reads training, test datasets, features, activities
- merges training and test data sets into one dataset by appending them together
- filters out columns that contain mean and standard deviation
- adds subject and activity columns to the dataset
- calcualates for each subjects activity : mean of all columns that contain mean and mean for all columns that contain standard deviation
