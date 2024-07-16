library(lubridate)
library(corrplot)
library(dplyr)
library(ggplot2)
library(MASS)

#Load data
data <- read.csv('ks-projects-201801.csv', header = T, na.string='')
summary(data)
head(data, 2)

#################################
# NULL VALUES AND DATA CLEANING #
#################################
anyNA(data)
colSums(is.na(data))
sum(data$country == 'N,0"')
identical(which(data$country == 'N,0"'), which(is.na(data$usd.pledged)))

###########################
# PLOT: Project by Status #
state.freq <- data %>% group_by(state) %>% summarize(count=n()) %>% arrange(desc(count))
state.freq$state <- factor(state.freq$state, levels=state.freq$state)
ggplot(state.freq, aes(state, count, fill=count)) + geom_bar(stat="identity") + 
  ggtitle("Projects by Status") + xlab("Project Status") + ylab("Frequency") + 
  geom_text(aes(label=count), vjust=-0.5)

data <- data %>%
  filter(state %in% c("failed", "canceled", "successful", "suspended")) %>% #Omitting live and undefined projects
  mutate(state_bi = factor(ifelse(state == "successful", 1, 0))) %>% #Creating a factor -> 1 for a successful project, 0 otherwise
  mutate(launch_year = year(launched)) %>% #We aren't interested in datetime in our case, just the year of the project
  mutate(launched = date(launched)) #We are only interested in the date, as datetime is too detailed for our uses

#########################
# PLOT: Project by Year #
year.freq <- data %>% group_by(year=year(launched)) %>% summarize(count=n())
ggplot(year.freq, aes(year, count, fill=count)) + geom_bar(stat="identity") + 
  ggtitle("Number of Projects by Launch Year") + xlab("Year") + ylab("Frequency") + 
  geom_text(aes(label=paste0(count)), vjust=-0.5)

############################
# PLOT: Project by Country #
country.freq <- data %>% group_by(country) %>% summarize(count=n())
ggplot(country.freq, aes(country, count, fill=count)) + geom_bar(stat="identity") + 
  ggtitle("Number of Projects by Country") + xlab("Year") + ylab("Frequency") + 
  geom_text(aes(label=paste0(count)), vjust=-0.5)

europe <- c("DE", "FR", "NL", "IT", "ES", "SE", "DK", "IE", "CH", "NO", "BE", "AT", "LU")

data <- data %>%
  filter(!(year(launched) %in% c(1970, 2018))) %>% #We remove the projects from 1970 and 2018
  filter(!(country == 'N,0"')) %>% #We remove the projects with missing information about the countries
  filter(!is.na(name)) %>% #Remove 4 row with name isNa
  filter(country %in% europe) %>% #Remove the country not in EU
  filter(pledged > 1000 & pledged < 100000)

############################
# PLOT: Project by Country #
country.freq <- data %>% group_by(country) %>% summarize(count=n())
ggplot(country.freq, aes(country, count, fill=count)) + geom_bar(stat="identity") + 
  ggtitle("Number of Projects by Country") + xlab("Year") + ylab("Frequency") + 
  geom_text(aes(label=paste0(count)), vjust=-0.5)

####################################
# PLOT: Distribution over state_bi #
prop.table(table(data$state_bi))

#######################
# Character to Number #
#######################
data$main_category  <- as.numeric(factor(data$main_category)) # Main Category
data$category <- as.numeric(factor(data$category)) # Category
data$country <- as.numeric(factor(data$country)) # Country

# create a column with the number of day between two column with two different date
data$days_between <- as.numeric(difftime(data$deadline, data$launched, units = "days"))

######################
# Correlation Matrix #
######################
new_data_num <- data.frame(lapply(new_data, as.integer))
cor_matrix <- cor(new_data_num)
corrplot(cor_matrix, method = "number", col = colorRampPalette(c("white", "black"))(100))

# Fit a spline curve to the data
spline_fit <- smooth.spline(new_data_num$pledged, new_data_num$backers, df = 100)

# Plot the data points
plot(new_data_num$pledged, new_data_num$backers, xlim = range(10, 4000000), ylim = range(10, 100000))

# Add the spline curve to the plot
lines(spline_fit, col = "blue")

# Add a legend
legend("topleft", legend = "Spline Curve", col = "red", lty = 1, bty = "n")


############
# Outliers #
############
hist(data$goal)
boxplot(data$pledged)
boxplot(data$backers)
boxplot(data$days_between)

##############
# Prediction #
##############
cols <- c("main_category", "goal", "pledged", "backers", "category", "country", "launch_year", "days_between", "state_bi")
new_data <- data[cols]
Y <- data["state_bi"]

set.seed(23) # Set the seed for reproducibility

test_proportion <- 0.3 # (e.g., 70% training, 30% testing)
num_test_samples <- round(nrow(new_data) * test_proportion) # Samples for the test set based on the proportion
test_indices <- sample(nrow(new_data), num_test_samples) # Randomly select the row indices for the test set

# Create the training and test sets for features (X) using indexing
X_train <- new_data[-test_indices, -9]  # Exclude the 9th column (target variable)
X_test <- new_data[test_indices, -9]

# Create the training and test sets for the target variable (Y)
Y_train <- new_data[-test_indices, 9]  # Include only the 5th column
Y_test <- new_data[test_indices, 9]

# Print the dimensions of the training and test sets
sprintf("X_train: %d Y_train: %d", dim(X_train)[1], length(Y_train))
sprintf("X_test: %d Y_test: %d", dim(X_test)[1], length(Y_test))

####################################
# PLOT: Distribution over state_bi #
prop.table(table(Y_test))
prop.table(table(Y_train))

ggplot(X_train, aes(factor(Y_train))) +
  geom_bar(fill = "lightblue", color = "black") +
  labs(title = "Distribution of Target Variable (Training Set)",
       x = "Value", y = "Count")

ggplot(X_test, aes(factor(Y_test))) +
  geom_bar(fill = "lightblue", color = "black") +
  labs(title = "Distribution of Target Variable (Test Set)",
       x = "Value", y = "Count")

############################
# Plot Function: Accuracy #
plot_accurancy <- function(predicted_labels, title) {
  thresholds <- seq(0.05, 0.85, by = 0.05)
  accuracy <- vector(length = length(thresholds))
  
  for (i in 1:length(thresholds)) {
    threshold <- thresholds[i]
    predicted_labels <- ifelse(predictions >= threshold, 1, 0)
    accuracy[i] <- sum(predicted_labels == Y_test) / length(Y_test)
  }
  
  accuracy_df <- data.frame(threshold = thresholds, accuracy = accuracy)
  
  # Plot the accuracy graph
  ggplot(accuracy_df, aes(x = threshold, y = accuracy)) +
    geom_line() +
    geom_point() +
    labs(x = "Threshold", y = "Accuracy") +
    ggtitle(title)
}

####################################
# Simple Logistic Regression model #
logreg_model <- glm(Y_train ~ ., data = X_train, family = binomial)
summary(logreg_model) # Print the summary of the model

predictions <- predict(logreg_model, newdata = X_test, type = "response") # Apply logistic regression to the test set
predicted_labels <- ifelse(predictions > 0.5, 1, 0) # Convert predicted probabilities to class labels
accuracy <- sum(predicted_labels == Y_test) / length(Y_test) # Calculate accuracy

print(accuracy) # Print the accuracy
plot_accurancy(predicted_labels, "Simple LogReg")

######################################################
# Logistic Regression model using stepwise selection #
stepwise_model <- stepAIC(glm(Y_train ~ ., data = X_train, family = binomial), direction = "both", trace = FALSE)
summary(stepwise_model) # Print the summary of the model

predictions <- predict(stepwise_model, newdata = X_test, type = "response") # Apply logistic regression to the test set
predicted_labels <- ifelse(predictions > 0.5, 1, 0) # Convert predicted probabilities to class labels
accuracy <- sum(predicted_labels == Y_test) / length(Y_test) # Calculate accuracy

print(accuracy) # Print the accuracy
plot_accurancy(predicted_labels, "Stepwise LogReg")

################################
# Balanced Logistic Regression #
class_weights <- ifelse(Y_train == 1, sum(Y_train != 1) / sum(Y_train == 1), sum(Y_train == 1) / sum(Y_train != 1)) # Calculate class weights
balanced_model <- glm(Y_train ~ ., data = X_train, family = binomial, weights = class_weights) # Create a balanced logistic regression model
summary(balanced_model) # Print the summary of the model

predictions <- predict(balanced_model, newdata = X_test, type = "response") # Apply logistic regression to the test set
predicted_labels <- ifelse(predictions > 0.5, 1, 0) # Convert predicted probabilities to class labels
accuracy <- sum(predicted_labels == Y_test) / length(Y_test) # Calculate accuracy

print(accuracy) # Print the accuracy
plot_accurancy(predicted_labels, "Balanced LogReg")

###########################################################################
# Logistic Regression model using stepwise selection and balanced weights #
stepbalanced_model <- stepAIC(glm(Y_train ~ ., data = X_train, family = binomial, weights = class_weights), direction = "both", trace = FALSE)
summary(stepbalanced_model) # Print the summary of the model

predictions <- predict(stepbalanced_model, newdata = X_test, type = "response") # Apply logistic regression to the test set
predicted_labels <- ifelse(predictions > 0.5, 1, 0) # Convert predicted probabilities to class labels
accuracy <- sum(predicted_labels == Y_test) / length(Y_test) # Calculate accuracy

print(accuracy) # Print the accuracy
plot_accurancy(predicted_labels, "Stepwise Balanced LogReg")