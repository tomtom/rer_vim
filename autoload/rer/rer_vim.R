

rer.rdata <- paste(getwd(), '.rer.rdata', sep = '/')
if (file.access(rer.rdata) == 0) {
    sys.load.image(rer.rdata, TRUE)
} else {
    rer.rdata <- NULL
}


if ('history' %in% rer.options$features) {
    rer.rhistory <- paste(getwd(), '.Rhistory', sep = '/')
    if (file.access(rer.rhistory) == 0) {
        loadhistory(rer.rhistory)
    } else {
        rer.rhistory <- NULL
    }
} else {
    rer.rhistory <- NULL
}


if (!exists("rerQuit")) {
    rerQuit <- function() {
        if (!is.null(rer.rhistory)) {
            try(savehistory(rer.rhistory))
        }
        q()
    }
}


if (!exists("rerHelp")) {
    rerHelp <- function(name.string) {
        help((name.string), try.all.packages = TRUE)
    }
}


if (!exists("rerComplete")) {
    rerComplete <- function(pattern, mode = '') {
        completions <- switch(mode,
            tskeleton = sapply(apropos(pattern), function(t) {
                if (try(is.function(eval.parent(parse(text = t))), silent = TRUE) == TRUE)
                    sprintf("%s(<+CURSOR+>)", t)
                else
                    t
                }),
            apropos(pattern)
        )
        invisible(paste(completions, collapse = "\n"))
    }
}


if (!exists("rerKeyword")) {
    rerKeyword <- function(name, name.string) {
        if (name.string == '') {
            rerHelp(name)
        } else if (mode(name) == 'function') {
            rerHelp(name.string)
        } else {
            str(name)
        }
    }
}


if (!exists("rerInspect.data.frame")) {
    rerInspect.data.frame <- fix
}


if (!exists("rerInspect.matrix")) {
    rerInspect.matrix <- fix
}


if (!exists("rerInspect.function")) {
    rerInspect.function <- fix
}


if (!exists("rerInspect.default")) {
    rerInspect.default <- if (exists('gvarbrowser')) gvarbrowser else str
}


if (!exists("rerInspect")) {
    rerInspect <- function(name) {
        UseMethod("rerInspect")
    }
}


if (!exists("rerSetBreakpoint")) {
    rer.breakpoints <- list()
    rer.breakpoints.nameonly <- FALSE
    rerSetBreakpoint <- function(filename, lnum, clear = FALSE, nameonly = rer.breakpoints.nameonly, ...) {
        bps <- rer.breakpoints[[filename]]
        bps <- bps[bps != lnum]
        if (!clear) {
            bps <- c(bps, lnum)
        }
        rer.breakpoints[[filename]] <<- bps
        setBreakpoint(filename, lnum, clear = clear, nameonly = nameonly, ...)
    }
}


if (!exists("rerSource")) {
    rerSource <- function(filename) {
        env <- globalenv()
        eval(substitute(source(f), list(f = filename)), envir = env)
        for (filename in names(rer.breakpoints)) {
            for (lnum in rer.breakpoints[[filename]]) {
                eval(substitute({
                    try(
                        setBreakpoint(f, n, clear = TRUE, nameonly = rer.breakpoints.nameonly),
                        silent = TRUE)
                    try(
                        setBreakpoint(f, n, nameonly = rer.breakpoints.nameonly),
                        silent = TRUE)
                }, list(
                        f = filename,
                        n = lnum)),
                     envir = env)
            }
        }
    }
}



