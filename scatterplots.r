# scatterplots.r

# Generic scatterplot function
scatterplot <- function(x, ...) UseMethod("scatterplot")

# Default scatterplot method for numeric vectors or lists
scatterplot.default <- function(x, y = NULL, ..., pch = 16, col = NULL, cex = 1, xlab = NULL, ylab = NULL, main = NULL, xlim = NULL, ylim = NULL, add = FALSE) {
    if (!is.null(y)) {
        # If y is provided, create a scatter plot
        plot(x, y, ..., pch = pch, col = col, cex = cex, xlab = xlab, ylab = ylab, main = main, xlim = xlim, ylim = ylim, type = "p")
    } else {
        # If y is not provided, assume x is a list of numeric vectors
        groups <- x
        n <- length(groups)
        if (n == 0) stop("Invalid first argument")

        # Create scatter plots for each group
        for (i in 1:n) {
            plot(groups[[i]], pch = pch, col = col, cex = cex, xlab = xlab, ylab = ylab, main = paste(main, "Group", i), xlim = xlim, ylim = ylim, type = "p", add = (i > 1))
        }
    }
}

# Method for matrices: scatter plots for each column against the first column
scatterplot.matrix <- function(x, use.cols = TRUE, ..., pch = 16, col = NULL, cex = 1, xlab = NULL, ylab = NULL, main = NULL, xlim = NULL, ylim = NULL) {
    if (use.cols) {
        groups <- split(c(x), rep.int(1L:ncol(x), each = nrow(x)))
    } else {
        groups <- split(c(x), seq(nrow(x)))
    }
    
    # Make use of col/row names if present
    if (length(nam <- dimnames(x)[[1 + use.cols]])) names(groups) <- nam

    scatterplot(groups, ..., pch = pch, col = col, cex = cex, xlab = xlab, ylab = ylab, main = main, xlim = xlim, ylim = ylim)
}

# Method for formula: scatter plots based on a formula and data
scatterplot.formula <- function(formula, data = NULL, ..., subset, na.action = NULL) {
    if (missing(formula) || length(formula) != 3L) stop("'formula' missing or incorrect")
    
    m <- match.call(expand.dots = FALSE)
    if (is.matrix(eval(m$data, parent.frame()))) m$data <- as.data.frame(data)
    m$... <- NULL
    m$na.action <- na.action
    m[[1L]] <- quote(stats::model.frame)
    mf <- eval(m, parent.frame())
    response <- attr(attr(mf, "terms"), "response")
    scatterplot(mf[[response[1]]], mf[[response[2]]], ...)
}

# Example plotting function for scatter plots
plot.scatterplot <- function(x, pch = 16, col = NULL, cex = 1, xlab = NULL, ylab = NULL, main = NULL, xlim = NULL, ylim = NULL, add = FALSE) {
    plot(x, pch = pch, col = col, cex = cex, xlab = xlab, ylab = ylab, main = main, xlim = xlim, ylim = ylim, type = "p", add = add)
}
