# Graphing-in-R
Creating boxplots and scatter plots in R studio 


To run scatter plot file, just source the R code in R studio then input your data in a similar fashion to this: 
data_values <- list(c(1, 2, 3, 4, 5), c(2, 3, 4, 5, 6), c(3, 4, 5, 6, 7))
labels <- c("A", "B", "C")
Then run the folllowing command: create_boxplot(data_values, labels)
You will then be able to visualize your box plot.


To run box plot file, again source the R code in R studio. This time the data should look like this: 
x_values <- c(1, 2, 3, 4, 5)
y_values <- c(2, 3, 4, 5, 6)
labels <- c("A", "B", "C", "D", "E")
Then run this command: create_scatter_plot(x_values, y_values, labels)
You will then be able to visualize your scatter plot. 
