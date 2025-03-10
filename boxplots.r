boxplot <- function(x, ...) UseMethod("boxplot")

boxplot.default <-
function(x, ..., range = 1.5, width = NULL, varwidth = FALSE,
	 notch = FALSE, outline = TRUE, names, plot = TRUE,
	 border = par("fg"), col = NULL, log = "",
	 pars = list(boxwex = 0.8, staplewex = 0.5, outwex = 0.5),
	 horizontal = FALSE, add = FALSE, at = NULL)
{
    args <- list(x, ...)
    namedargs <-
	if(!is.null(attributes(args)$names)) attributes(args)$names != ""
	else rep_len(FALSE, length(args))
    ## pars <- c(args[namedargs], pars)
    groups <- if(is.list(x)) x else args[!namedargs]
    if(0L == (n <- length(groups)))
	stop("invalid first argument")
    if(length(class(groups)))
	groups <- unclass(groups)
    if(!missing(names))
	attr(groups, "names") <- names
    else {
	if(is.null(attr(groups, "names")))
	    attr(groups, "names") <- 1L:n
	names <- attr(groups, "names")
    }
    cls <- sapply(groups, function(x) class(x)[1L])
    cl <- if(all(cls == cls[1L])) cls[1L] else NULL
    for(i in 1L:n)
	groups[i] <- list(boxplot.stats(unclass(groups[[i]]), range)) # do.conf=notch)
    stats <- matrix(0, nrow = 5L, ncol = n)
    conf  <- matrix(0, nrow = 2L, ncol = n)
    ng <- out <- group <- numeric(0L)
    ct <- 1
    for(i in groups) {
	stats[,ct] <- i$stats
	conf [,ct] <- i$conf
	ng <- c(ng, i$n)
	if((lo <- length(i$out))) {
	    out	  <- c(out,i$out)
	    group <- c(group, rep.int(ct, lo))
	}
	ct <- ct+1
    }
    if(length(cl) && cl != "numeric") oldClass(stats) <- cl
    z <- list(stats = stats, n = ng, conf = conf, out = out, group = group,
	      names = names)
    if(plot) {
        if(is.null(pars$boxfill) && is.null(args$boxfill)) pars$boxfill <- col
        do.call("bxp",
                c(list(z, notch = notch, width = width, varwidth = varwidth,
                       log = log, border = border, pars = pars,
                       outline = outline, horizontal = horizontal, add = add,
                       at = at), args[namedargs]))
	invisible(z)
    }
    else z
}

boxplot.matrix <- function(x, use.cols = TRUE, ...)
{
    ## Purpose: Boxplot for each column or row [use.cols= TRUE / FALSE] of a matrix
    ## -------------------------------------------------------------------------
    ## Arguments: x: a numeric matrix; use.cols: logical, columns (T) or rows (F)
    ## <FIXME split.matrix>
    groups <- if(use.cols) {
        split(c(x), rep.int(1L:ncol(x), rep.int(nrow(x), ncol(x))))
    } else split(c(x), seq(nrow(x)))
    ## Make use of col/row names if present
    if (length(nam <- dimnames(x)[[1+use.cols]])) names(groups) <- nam
    invisible(boxplot(groups, ...))
}

boxplot.formula <-
    function(formula, data = NULL, ..., subset, na.action = NULL)
{
    if(missing(formula) || (length(formula) != 3L))
	stop("'formula' missing or incorrect")
    m <- match.call(expand.dots = FALSE)
    if(is.matrix(eval(m$data, parent.frame())))
	m$data <- as.data.frame(data)
    m$... <- NULL
    m$na.action <- na.action # force use of default for this method
    ## need stats:: for non-standard evaluation
    m[[1L]] <- quote(stats::model.frame)
    mf <- eval(m, parent.frame())
    response <- attr(attr(mf, "terms"), "response")
    boxplot(split(mf[[response]], mf[-response]), ...)
}

bxp <- function(z, notch = FALSE, width = NULL, varwidth = FALSE,
                outline = TRUE, notch.frac = 0.5, log = "", border = par("fg"),
		pars = NULL, frame.plot = axes, horizontal = FALSE,
		add = FALSE, at = NULL, show.names = NULL, ...)
{
    pars <- c(list(...), pars)
    ## this could give duplicates, so ensure first mentioned wins.
    pars <- pars[unique(names(pars))]

    bplt <- function(x, wid, stats, out, conf, notch, xlog, i)
    {
	## Draw single box plot
        ok <- TRUE
	if(!anyNA(stats)) {
	    ## stats = +/- Inf:	polygon & segments should handle

	    ## Compute 'x + w' -- "correctly" in log-coord. case:
	    xP <-
		if(xlog) function(x,w) x * exp(w)
		else function(x,w) x + w
	    wid <- wid/2
	    if (notch) {
                ## check for overlap of notches and hinges
                ok <- stats[2L] <= conf[1L] && conf[2L] <= stats[4L]

		xx <- xP(x, wid * c(-1, 1, 1, notch.frac, 1,
				    1, -1,-1,-notch.frac,-1))
		yy <- c(stats[c(2, 2)], conf[1L], stats[3L], conf[2L],
			stats[c(4, 4)], conf[2L], stats[3L], conf[1L])
	    }
	    else {
		xx <- xP(x, wid * c(-1, 1, 1, -1))
		yy <- stats[c(2, 2, 4, 4)]
	    }
	    if(!notch) notch.frac <- 1
	    wntch <- notch.frac*wid

	    ## the box filling over which to draw the rest:
	    xypolygon(xx, yy, lty = "blank", col = boxfill[i])
	    ## Median
	    xysegments(xP(x, -wntch), stats[3L],
		       xP(x, +wntch), stats[3L],
		       lty = medlty[i], lwd = medlwd[i], col = medcol[i],
                       lend = 1) ## avoid oerlap by butt line endings.
	    xypoints(x, stats[3L],
		     pch = medpch[i], cex = medcex[i], col = medcol[i], bg = medbg[i])
	    ## Whiskers
	    xysegments(rep.int(x, 2), stats[c(1,5)],
		       rep.int(x, 2), stats[c(2,4)],
		       lty = whisklty[i], lwd = whisklwd[i], col = whiskcol[i])
	    xysegments(rep.int(xP(x, -wid * staplewex[i]), 2), stats[c(1,5)],
		       rep.int(xP(x, +wid * staplewex[i]), 2), stats[c(1,5)],
		       lty = staplelty[i], lwd = staplelwd[i], col = staplecol[i])
	    ## finally the box borders
	    xypolygon(xx, yy, lty = boxlty[i], lwd = boxlwd[i], border = boxcol[i])

	    if ((nout <- length(out))) { ## Outliers
		xysegments(rep(x - wid * outwex, nout), out,
			   rep(x + wid * outwex, nout), out,
			   lty = outlty[i], lwd = outlwd[i], col = outcol[i])
		xypoints(rep.int(x, nout), out, pch = outpch[i],
                         lwd = outlwd[i],
			 cex = outcex[i], col = outcol[i], bg = outbg[i])
	    }

	    if(any(inf <- !is.finite(out))) {
		## FIXME: should MARK on plot !! (S-plus doesn't either)
		warning(sprintf(ngettext(length(unique(out[inf])),
				 "Outlier (%s) in boxplot %d is not drawn",
				 "Outliers (%s) in boxplot %d are not drawn"),
				paste(unique(out[inf]), collapse=", "), i),
			domain = NA)
	    }
	}
        return(ok)
    } ## bplt

    if(!is.list(z) || 0L == (n <- length(z$n)))
	stop("invalid first argument")
    if(is.null(at))
	at <- 1L:n
    else if(length(at) != n)
        stop(gettextf("'at' must have same length as 'z$n', i.e. %d", n),
             domain = NA)
    ## just for compatibility with S
    if(is.null(z$out))
	z$out <- numeric()
    if(is.null(z$group) || !outline)
	z$group <- integer()
    if(is.null(pars$ylim))
	ylim <- range(z$stats[is.finite(z$stats)],
		      if(outline) z$out  [is.finite(z$out)],
		      if(notch) z$conf [is.finite(z$conf)])
    else {
	ylim <- pars$ylim
	pars$ylim <- NULL
    }

    if(length(border) == 0L) border <- par("fg")

    dev.hold(); on.exit(dev.flush())
    if (!add) {
	if(is.null(pars$xlim))
	    xlim <- range(at, finite=TRUE) + c(-0.5, 0.5)
	else {
	    xlim <- pars$xlim
	    pars$xlim <- NULL
	}
	plot.new()
	## shall we switch log for horizontal with
	## switch(log, x="y", y="x", log) ??
	if (horizontal)
	    plot.window(ylim = xlim, xlim = ylim, log = log, xaxs = pars$yaxs)
	else
	    plot.window(xlim = xlim, ylim = ylim, log = log, yaxs = pars$yaxs)
    }
    xlog <- (par("ylog") && horizontal) || (par("xlog") && !horizontal)

    pcycle <- function(p, def1, def2 = NULL)# or rather NA {to be rep()ed}?
	rep(if(length(p)) p else if(length(def1)) def1 else def2,
	    length.out = n)
    ## we have to be careful to avoid partial matching here
    p <- function(sym) pars[[sym, exact = TRUE]]

    boxlty    <- pcycle(pars$boxlty,	p("lty"), par("lty"))
    boxlwd    <- pcycle(pars$boxlwd,	p("lwd"), par("lwd"))
    boxcol    <- pcycle(pars$boxcol,	border)
    boxfill   <- pcycle(pars$boxfill,	par("bg"))
    boxwex    <- pcycle(pars$boxwex,	0.8 * {
	if(n <= 1) 1 else
	stats::quantile(diff(sort(if(xlog) log(at) else at)), 0.10) })
    medlty    <- pcycle(pars$medlty,	p("lty"), par("lty"))
    medlwd    <- pcycle(pars$medlwd,	3*p("lwd"), 3*par("lwd"))
    medpch    <- pcycle(pars$medpch,	NA_integer_)# NA when that works
    medcex    <- pcycle(pars$medcex,	p("cex"), par("cex"))
    medcol    <- pcycle(pars$medcol,	border)
    medbg     <- pcycle(pars$medbg,	p("bg"),  par("bg"))
    whisklty  <- pcycle(pars$whisklty,	p("lty"), "dashed")
    whisklwd  <- pcycle(pars$whisklwd,	p("lwd"), par("lwd"))
    whiskcol  <- pcycle(pars$whiskcol,	border)
    staplelty <- pcycle(pars$staplelty, p("lty"), par("lty"))
    staplelwd <- pcycle(pars$staplelwd, p("lwd"), par("lwd"))
    staplecol <- pcycle(pars$staplecol, border)
    staplewex <- pcycle(pars$staplewex,	0.5)
    outlty    <- pcycle(pars$outlty,	"blank")
    outlwd    <- pcycle(pars$outlwd,	p("lwd"), par("lwd"))
    outpch    <- pcycle(pars$outpch,	p("pch"), par("pch"))
    outcex    <- pcycle(pars$outcex,	p("cex"), par("cex"))
    outcol    <- pcycle(pars$outcol,	border)
    outbg     <- pcycle(pars$outbg,	p("bg"),  par("bg"))
    outwex    <- pcycle(pars$outwex,	0.5)

    width <-
	if(!is.null(width)) {
	    if(length(width) != n | anyNA(width) | any(width <= 0))
		stop("invalid boxplot widths")
	    boxwex * width/max(width)
	}
	else if(varwidth) boxwex * sqrt(z$n/max(z$n))
	else if(n == 1) 0.5 * boxwex
	else rep.int(boxwex, n)

    if(horizontal) {
	xypoints <- function(x, y, ...) points(y, x, ...)
	xypolygon <- function(x, y, ...) polygon(y, x, ...)
	xysegments <- function(x0, y0, x1, y1, ...) segments(y0, x0, y1, x1, ...)
    }
    else {
	xypoints <- points
	xypolygon <- polygon
	xysegments <- segments
    }

    ok <- TRUE
    for(i in 1L:n)
	ok <- ok & bplt(at[i], wid = width[i], stats = z$stats[,i],
                        out = z$out[z$group == i], conf = z$conf[,i],
			notch = notch, xlog = xlog, i = i)
    if(!ok)
	warning("some notches went outside hinges ('box'): maybe set notch=FALSE")

    axes <- is.null(pars$axes)
    if(!axes) { axes <- pars$axes; pars$axes <- NULL }
    if(axes) {
	ax.pars <- pars[names(pars) %in% c("xaxt", "yaxt", "xaxp", "yaxp",
                                           "las",
					   "cex.axis", "col.axis", "format")]
	if (is.null(show.names)) show.names <- n > 1
	if (show.names)
	    do.call("axis", c(list(side = 1 + horizontal,
				   at = at, labels = z$names), ax.pars))
	do.call("Axis", c(list(x = z$stats, side = 2 - horizontal), ax.pars))
    }
    do.call("title",
	    pars[names(pars) %in% c("main", "cex.main", "col.main",
				    "sub", "cex.sub", "col.sub",
				    "xlab", "ylab", "cex.lab", "col.lab")])
    if(frame.plot)
	box()
    invisible(at)
}
