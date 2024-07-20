# Graphing-in-R
Creating boxplots and scatter plots in R  

Running boxplots.r: 
After sourcing the R code in R studio, just fill in your data and then call the boxplot function like this:  
 data <- list(
   A = rnorm(100),
   B = rnorm(100, mean = 5),
   C = rnorm(100, mean = 10)
boxplot(data, main = "Custom Boxplot", col = c("red", "blue", "green"))



Running scatterplots.r:
Again source the code.
Then input data and call function in a manner like this: 
x <- 1:10
y <- 2 * x + rnorm(10)

scatterplot(x, y, pch = 16, col = "red", xlab = "X-axis", ylab = "Y-axis", main = "Scatter Plot with Best-Fit Line", add_line = TRUE)
