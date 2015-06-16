# GCDataCourseProject
#Downloaded the raw data and after unzipping the same put it in a folder to be used as working directory

#Read data sets containing variable names, activity code-name mapping, test and train data sets

#Joined training and testing data sets by rbind. Joined activity name and subject detail datasets the resulting data.
#Dataset now contain all test and train data along with the descriptors activity and subject information.

#We need to report the avg values for the variables so took mean grouped by activity & subject codes.

#mapped the variable names in the complete avg'ed using the variable names mapping provided

#Retrieved the variable names and stored them in a string

#there are certain variable for which count of opening brackets does not match with count of 
# closing brackets. Through pattern matching removed these problematic variables

#Pattern matching to find out only those variables which contain mean or std but not angle in their name (as per requirement)

#Subsetted the data set to get the columns of concern only. this will give data frame final output

#Reordering the variables to make data frame more tidy

#Coded to give more intuitive names to the variable which include expansion of abbreviation, incorrect names removal, addition of new 
#phrases to make name more intuitive etc

#Assigned names to final data set
