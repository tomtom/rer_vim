

rer.rdata <- paste(getwd(), '.rer.rdata', sep = '/')
if (file.access(rer.rdata) == 0) {
    sys.load.image(rer.rdata, TRUE)
} else {
    rer.rdata <- NULL
}


if (all((c('reuse', 'history') %in% rer.options$features) == c(FALSE, TRUE))) {
    rer.rhistory <- paste(getwd(), '.Rhistory', sep = '/')
    if (file.access(rer.rhistory) == 0) {
        loadhistory(rer.rhistory)
    } else {
        rer.rhistory <- NULL
    }
} else {
    rer.rhistory <- NULL
}


if (!exists("rer.quit")) {
    rer.quit <- function() {
        if (!is.null(rer.rhistory)) {
            try(savehistory(rer.rhistory))
        }
        if (!'reuse' %in% rer.options$features) {
            q()
        }
    }
}


if (!exists("rer.help")) {
    rer.help <- function(name.string) {
        help((name.string), try.all.packages = TRUE)
    }
}


if (!exists("rer.complete")) {
    rer.complete <- function(pattern, mode = '') {
        completions <- switch(mode,
            tskeleton = sapply(apropos(pattern), function(t) {
                if (try(is.function(eval.parent(parse(text = t))), silent = TRUE) == TRUE)
                    sprintf("%s(<+CURSOR+>)", t)
                else
                    t
                }),
            apropos(pattern)
        )
        paste(completions, collapse = "\n")
    }
}


if (!exists("rer.keyword")) {
    rer.keyword <- function(name, name.string) {
        if (name.string == '') {
            rer.help(name)
        } else if (mode(name) == 'function') {
            rer.help(name.string)
        } else {
            str(name)
        }
    }
}


if (!exists("rer.inspect.data.frame")) {
    rer.inspect.data.frame <- fix
}

if (!exists("rer.inspect.matrix")) {
    rer.inspect.matrix <- fix
}

if (!exists("rer.inspect.function")) {
    rer.inspect.function <- fix
}

if (!exists("rer.inspect.default")) {
    rer.inspect.default <- if (exists('gvarbrowser')) gvarbrowser else str
}

if (!exists("rer.inspect")) {
    rer.inspect <- function(name) {
        UseMethod("rer.inspect")
    }
}

