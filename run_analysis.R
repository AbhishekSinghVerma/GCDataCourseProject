#Setting up url and raw data downloading
#fileurl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# download.file(fileurl,"data.zip")

#Raw data was zipped so unzipping the same
# unzip("C:\\Users\\z076156\\Downloads\\RDataGettingNCleaning\\data.zip",
#        exdir="C:\\Users\\z076156\\Downloads\\RDataGettingNCleaning\\data")

#Setting up working directory where the unzipped files are present
setwd("C:\\Users\\z076156\\Downloads\\RDataGettingNCleaning\\data\\UCI HAR Dataset")

#Reading data sets containing variable names and activity mapping
var_names<-read.table("features.txt")
activity_lables<-read.table("activity_labels.txt")
names(activity_lables)<-c("activityCode","activityName")

#Reading test and train data sets
setwd("C:\\Users\\z076156\\Downloads\\RDataGettingNCleaning\\data\\UCI HAR Dataset\\test")
subject_test<-read.table("subject_test.txt")
x_test<-read.table("X_test.txt")
activity_test<-read.table("Y_test.txt")
setwd("C:\\Users\\z076156\\Downloads\\RDataGettingNCleaning\\data\\UCI HAR Dataset\\train")
subject_train<-read.table("subject_train.txt")
x_train<-read.table("X_train.txt")
activity_train<-read.table("Y_train.txt")

#Binding training and testing data sets
x_complete<-rbind(x_test,x_train)
activity_complete<-rbind(activity_test,activity_train)
subject_complete<-rbind(subject_test,subject_train)

#Removing the part data sets as they are big and thus eating up RAM. Retaining only combined
#data sets
rm(x_test,x_train,activity_test,activity_train,subject_test,subject_train)

#Naming the 2 data frame's columns to make the final data frame column names intuitive
names(activity_complete)<-"activity"
names(subject_complete)<-"subject"

#Joining all 3 data chunks in one single data frame. Now we have all data along with actvity and
#subject details in one data frame
complete<-cbind(x_complete,activity_complete,subject_complete)

#We need to report the avg values for the variables so here taking mean grouped by activity &
#subject codes. Removal of the unnecessary variables will be done later
mean_sbj_act<-aggregate(complete[,1:(ncol(complete)-2)], complete[,c('activity','subject')],
                function(x) mean(x,na.rm=T))

#Merging up the data frame to give activities meaningful names from mapping
mean_sbj_act1<-merge(mean_sbj_act,activity_lables,by.x="activity",by.y="activityCode",all.x=T)

#naming the variables in the complete avg'ed using the variable names mapping provided
names(mean_sbj_act1)[3:(ncol(mean_sbj_act1)-1)] <- as.character(var_names$V2)

#As we need variables containing only "mean" and "std" in thee names so retrieving the variable
#names and storing them in a string
names<-names(mean_sbj_act1)

#loading package for string manipulation
require(stringr)

#there are certain variable for which count of opening brackets does not match with count of 
# closing brackets. Counting these for all variables
open<-lapply(as.list(names),str_count,"\\(")
close<-lapply(as.list(names),str_count,"\\)")

# Finding those variable for which counts of opening and closing brackets does not match
names[which(mapply("-",open,close)!=0)]<-sub("\\)","",names[which(mapply("-",open,close)!=0)])

#We need only those variables which contain mean or std but not angle in their name
match<-intersect(grep("^(angle)",names,ignore.case=T,invert=T),grep("mean|std",names,
                                                                    ignore.case=T))

# getting the comma separated string of all variables having mean/std 
varsFinal<-paste("c(",paste(match,collapse=","),")",sep="")

#getting the formula in text string format
mean_sbj_act1_txt<-paste("subset(mean_sbj_act1,select=",varsFinal,")",sep="")

#evaluating the formula and getting data frame final output
mean_sbj_act2<-eval(parse(text=mean_sbj_act1_txt))

#adding columns which are essential in final data set but dont have mean/std e.g. activity name
mean_sbj_act_f<-cbind(mean_sbj_act1[1:2],mean_sbj_act2,mean_sbj_act1[ncol(mean_sbj_act1)])

#Removing activity code as we now have activity name in data frame
mean_sbj_act_f<-subset(mean_sbj_act_f,select=-c(activity))

#Reordering the variables to make data frame more readable
mean_sbj_act_f<-mean_sbj_act_f[,c(1,ncol(mean_sbj_act_f),2:(ncol(mean_sbj_act_f)-1))]

#Sorting variables in data frame so as to get X, Y & Z components in consecutive columns
mean_sbj_act_f<-mean_sbj_act_f[,order(names(mean_sbj_act_f))]

#Getting all variable names in the final data set
rm(names)
names<-names(mean_sbj_act_f)

#Next steps give more intuitive names to the variable which include expansion of abbreviation,
#incorrect names removal, addition of new phrases to make name more intuitive etc
dashes<-sapply(as.data.frame(names),str_count,"\\-")

#X, Y and Z components could be seen as measurement say mean or std measurement components along
#different axis. A tidy data principles says that there should be just one column for each type 
#of measurement not components scattered across columns so all components need to combined.
#as used in vector algebra final magnitude has beeen calculated using formula
#   value = sqrt( x^2 + y^2 + z^2)
for (i in 1:nrow(dashes)){
  if(dashes[i] == 2)
  {
    vec<-as.data.frame(sqrt(mean_sbj_act_f[,i]^2 + mean_sbj_act_f[,(i+1)]^2 + 
                               mean_sbj_act_f[,(i+2)]^2))
    full_name<-names(mean_sbj_act_f)[i]
    names(vec)<-sub("\\-X","",full_name)
    mean_sbj_act_f<-cbind(mean_sbj_act_f,vec)
    i<-i+3
  }
}

#As there are new variables added in data frame so again capturing names and finding out those
#variables which belongs to X/Y/Z components by counting number of dashes in name
names1<-names(mean_sbj_act_f)
dashes1<-sapply(as.data.frame(names1),str_count,"\\-")
varnum<-which(dashes1==2)

#droping columns related to different components as the final vectors has already been calculated
#and added in the data frame
mean_sbj_act_f<-subset(mean_sbj_act_f,select=-c(varnum))

#following lines of code automatically create the explanatory names of the columns 
rm(names)
names<-names(mean_sbj_act_f)

names<-sub("^t","Time Domain ",names)
names<-sub("^f","Frequency Domain ",names)
names<-sub("Acc"," Accleation Measure ",names)
names<-sub("std","Standard Deviation",names)
names<-sub("Mag","Magnitude ",names)
names<-sub("Gyro","Gyrometer ",names)
names<-sub("Jerk","Jerk ",names)
names<-sub("BodyBody|Body"," Body ",names)
names<-sub("-"," Across ",names)
names<-sub("\\()","",names)

#Assigning names to final data set
names(mean_sbj_act_f)<-names

#writing the results in a csv file
write.csv(mean_sbj_act_f,
file="C:\\Users\\z076156\\Downloads\\RDataGettingNCleaning\\data\\UCI HAR Dataset\\finalData.txt"
          ,row.names=F)
