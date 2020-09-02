#' Trace or untrace ggplot functions
#'
#' @param pkgs packages where to find functions to trace/untrace
#' @param prefixes prefixes of those functions
#' @param exceptions exceptions
#'
#' @export
trace_funs <- function(
  pkgs = "ggplot2",
  prefixes = c("annotate_", "coord_", "facet_", "geom_", "scale_", "stat_", "theme"),
  exceptions = c("scale_type", "theme_get", "coord_munch", "geom_blank")) {

  tracer <- quote({
    if(getOption("ggfail")) {

      scs <- sys.calls()
      n <- length(scs) - 4 # -4 to account for the trace overhead
      #print(scs[[n]])
      #browser()
      # we allow calls to "+" and calls to print, list, `%+%` and `c`
      # calls to `+` are detected differently
      plus_call_lgl <- is.call(scs[[n]]) &&
        identical(quote(`+`), str2lang(paste(capture.output(print(scs[[n]])), collapse = " "))[[1]])
      other_allowed_call_lgl <-
        n >= 2 &&
        is.call(call <- scs[[n - 1]]) && (
          # kept to be able to view objects without triggering an error:
          identical(call[[1]], quote(print)) ||
            # used internally by ggplot on prefixed functions :
            identical(call[[1]], quote(structure)) ||
            identical(call[[1]], quote(find_scale)) ||
            # functions allowed to be used on prefixed functions:
            identical(call[[1]], quote(list)) ||
            identical(call[[1]], quote(`%+%`)) ||
            identical(call[[1]], quote(c))
        )
      if(n != 1 && !plus_call_lgl && !other_allowed_call_lgl) {
        stop("Did you forget a `+` in a ggplot call ?\n",
             "Use `print(", deparse(scs[[n]], width.cutoff = 500), ")` to view the ",
             "object, or set `options(ggfail = FALSE)` to disable this error."
        )
      }
    }
  })

  for(pkg in pkgs) {
    all_funs <- getNamespaceExports("ggplot2")
    traced_funs <- all_funs[Reduce(`|`, lapply(prefixes, startsWith, x = all_funs))]
    # don't consider some prefixed functions
    traced_funs <- setdiff(traced_funs, exceptions)
    for (fun in traced_funs) {
      #browser()
      suppressMessages(eval(bquote(
        trace(.(getExportedValue(pkg, fun)), tracer = tracer, print = FALSE))))
      # suppressMessages(eval(bquote(
      #   trace(`::`(.(as.name(pkg)),.(as.name(fun))), tracer = tracer, print = FALSE))))
    }
  }
  invisible(NULL)
}


#' @rdname trace_funs
#' @export
untrace_funs <- function(
  pkgs = "ggplot2",
  prefixes = c("annotate_", "coord_", "facet_", "geom_", "scale_", "stat_", "theme"),
  exceptions = c("scale_type", "theme_get", "coord_munch")) {

  for(pkg in pkgs) {
    all_funs <- getNamespaceExports("ggplot2")
    traced_funs <- all_funs[Reduce(`|`, lapply(prefixes, startsWith, x = all_funs))]
    # don't consider some prefixed functions
    traced_funs <- setdiff(traced_funs, exceptions)
    for (fun in traced_funs) {
      #browser()
      suppressMessages(eval(bquote(
        untrace(.(getExportedValue(pkg, fun))))))
    }
  }
  invisible(NULL)
}

