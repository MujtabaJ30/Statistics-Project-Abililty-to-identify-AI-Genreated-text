data=read.csv("C:/Users/Mujtaba Jafri/Downloads/R/Form_Responses.csv")

# converting categorical string variables to factors
data$Sex = as.factor(data$Sex)
data$AGE..below.and.above.24. = as.factor(data$AGE..below.and.above.24.)
data$Education.above.Ug..below.UG. = as.factor(data$Education.above.Ug..below.UG.)

# Drop the 'Age' and 'Sex_Encoded' columns if it exist
data = data[, !(names(data) %in% c("Timestamp","Email.Address","Age", "Sex_Encoded"))]

# Create a High Ability columns
data$High_Ability = ifelse(data$Total.Score >= 4, "Yes", "No")

#converting it to a factor
data$High_Ability = as.factor(data$High_Ability)
# Check the structure of the data frame after adding the new column
str(data)

#performing logistic regression
logistic_ALL = glm(High_Ability ~ Sex+ AGE..below.and.above.24.+ Education.above.Ug..below.UG. , data = data, family=binomial)

summary(logistic_ALL)

# function to get confidence interval for the coefficient estimation
# CIs using profiled log likelihood
confint(logistic_ALL)

## CIs using standard errors
confint.default(logistic_ALL)

## odds ratios only
Odds_Ratio = exp(coef(logistic_ALL))

Odds_Ratio
# predict the high ability based on the model
data$predicted_high_ability = predict(logistic_ALL, type = "response") > 0.5

# Creating the confusion matrix using table function
confusion_matrix = table(data$High_Ability, data$predicted_high_ability)

# Print the confusion matrix
print(confusion_matrix)


# Extract values from the confusion matrix
true_positives = confusion_matrix["Yes", "TRUE"]
false_positives = confusion_matrix["No", "TRUE"]
false_negatives = confusion_matrix["Yes", "FALSE"]
true_negatives = confusion_matrix["No", "FALSE"]

# calculate the metrics
precision = true_positives / (true_positives + false_positives)
recall = true_positives / (true_positives + false_negatives)
accuracy = (true_positives + true_negatives) / sum(confusion_matrix)
f1_score = 2 * (precision * recall) / (precision + recall)

# Print the results
cat("Precision:", precision)
cat("Recall:", recall)
cat("Accuracy:", accuracy)
cat("F1-score:", f1_score)


## now we can plot the data
predicted.data = data.frame(
  probability.of.High_Ability =logistic_ALL$fitted.values,
  High_Ability=data$High_Ability)

# sort the dataframe from low to high probabilities
predicted.data = predicted.data[
  order(predicted.data$probability.of.High_Ability, decreasing=FALSE),]

# add new column for rank
predicted.data$rank = 1:nrow(predicted.data)

# load libraries
library(ggplot2)

# using geom_point plot the data
ggplot(data=predicted.data, aes(x=rank, y=probability.of.High_Ability)) +
  geom_point(aes(color=High_Ability), alpha=1, shape=4, stroke=2) +
  xlab("Index") +
  ylab("Predicted probability of High Ability")

ggsave("plot.pdf")

