#' Retrieve Star Trek data from STAPI
#'
#' Retrieve Star Trek data from the Star Trek API (STAPI).
#'
#' See [stapiEntities()] for all the currently available API entities. These are
#' the IDs for dataset collections or categories passed to `id`.
#'
#' The universal ID `uid` can be supplied to retrieve a more specific subset of
#' data. By default, `uid = NULL` and `stapi()` operates in search mode. As part
#' of a stepwise process, you can first use search mode. Then if the resulting
#' data frame includes a `uid` column, you can make a second call to the
#' function providing a specific `uid`. This puts `stapi()` into extraction mode
#' and will return satellite data associated with the unique entry from the
#' original general sweep of the entity `id`.
#'
#' `rtrek` employs anti-DOS measures. It will not perform an API call to STAPI
#' more than once per second. To be an even better neighbor, you can increase
#' this wait time using `options()`, e.g. `options(rtrek_antidos = 10)` to
#' increase the minimum time between API calls to ten seconds. Values less than
#' one are ignored (defaulting back to one second) and a warning will be thrown
#' when making any API call if this is the case.
#'
#' Currently STAPI contains primarily real world data such as episode air dates,
#' movie metadata, or production company information. Fictional world data is
#' secondary and more limited.
#'
#' @param id character, name of STAPI entity. See details.
#' @param page integer vector, defaults to first page.
#' @param uid `NULL` for search mode, character for extraction mode. See details.
#' @param page_count logical, set to `TRUE` to do a preliminary check of the
#' total number a pages of results available for a potential entity search.
#' This will only have the impact of searching the first page.
#'
#' @return a data frame in search mode, a list in extraction mode, and nothing
#' is returned in page count check mode but the result is printed to the console.
#' @export
#'
#' @examples
#' \donttest{
#' library(dplyr)
#' stapi("character", page_count = TRUE) # check first
#' stapi("character", page = 2) |> select(1:2)
#' Q <- stapi("character", uid = "CHMA0000025118")
#' Q$episodes |> select(uid, title, stardateFrom, stardateTo)
#' }
stapi <- function(id, page = 1, uid = NULL, page_count = FALSE){
  if(!id %in% rtrek::stapiEntities$id) stop("Invalid `id`.", call. = FALSE)
  .antidos("stapi")
  type <- if(is.null(uid)) "/search?pageNumber=" else paste0("?uid=", uid)
  uri <- paste0("http://stapi.co/api/v1/rest/", id, type)
  if(!is.null(uid)){
    json <- jsonlite::fromJSON(uri)
    assign("stapi", Sys.time(), envir = rtrek_api_time)
    if(is.list(json) & !is.data.frame(json) & length(json) == 1) json <- json[[1]]
    return(json)
  }
  json0 <- jsonlite::fromJSON(paste0(uri, "0&pageSize=100"))
  total_pages <- json0$page$totalPages
  if(page_count){
    assign("stapi", Sys.time(), envir = rtrek_api_time)
    cat("Total pages to retrieve all results:", total_pages, "\n")
    return(invisible())
  }
  json0 <- jsonlite::flatten(json0[[3]], recursive = TRUE)
  if(total_pages != 1 && (length(page) != 1 || page != 1)){
    include_page1 <- 1 %in% page
    page <- page[page != 1]
    json <- lapply(page, function(x) jsonlite::flatten(
      jsonlite::fromJSON(paste0(uri, x, "&pageSize=100"))[[3]], recursive = TRUE)
    )
    if(include_page1) json <- c(list(json0), json)
    d <- dplyr::bind_rows(json)
  } else {
    d <- json0
  }
  assign("stapi", Sys.time(), envir = rtrek_api_time)
  d <- dplyr::select(d, -dplyr::any_of(attr(rtrek::stapiEntities, "ignored columns")))
  dplyr::as_tibble(d)
}

.antidos <- function(x, sec = getOption("rtrek_antidos", 1)){
  if(sec < 1){
    sec <- 1
    warning("`rtrek_antidos` setting in `options` is less than one and will be ignored.\n")
  }
  wait <- 0
  if(!is.null(rtrek_api_time[[x]])){
    wait <- as.numeric(get(x, rtrek_api_time)) + sec - as.numeric(Sys.time())
    if(wait > 0) Sys.sleep(wait) else wait <- 0
  }
  assign(x, Sys.time(), envir = rtrek_api_time)
  wait
}
