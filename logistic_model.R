
#Load data
data <- read.csv("creditcard.csv")
head(data)

#Null values in columns
colSums(is.na(data))

#Count 1 in Class column
sum(data$Class == 1)

hist(data$Class)

### SMOTE ###
#Install DMwR library
install.packages("smotefamily")
library(smotefamily)

smote_data <- SMOTE(data, data$Class, K=5)
head(smote_data)

sum(smote_data$Class == 1)

### LOGISTIC REGRESSION ###

#Test and Training Set
install.packages("caret")
library(caret)

set.seed(123) # riproducibility
index <- createDataPartition(data$Class, p = 0.8, list = FALSE)

train <- data[index, ]
test <- data[-index, ]

#Fit model
model <- glm(Class ~., family=binomial(link='logit'), data=train)
summary(model)

fitted.results <- predict(model,newdata=test, type='response')
fitted.results <- ifelse(fitted.results > 0.5,1,0)
misClasificError <- mean(fitted.results != test$Class)

#Accurancy
print(paste('Accuracy',1-misClasificError))


