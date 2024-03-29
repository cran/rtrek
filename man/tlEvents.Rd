% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{tlEvents}
\alias{tlEvents}
\title{Star Trek event-based timeline.}
\format{
A data frame
}
\usage{
tlEvents
}
\description{
A data frame with 1241 rows and 6 columns containing Star Trek timeline data.
This dataset is event-driven, meaning that the timeline entries (rows)
provide chronologically ordered historical events from the Star Trek
universe. See the \code{tlBooks} dataset for an novel-driven timeline.
}
\details{
As with \code{tlBooks}, this timeline is quite out of date. In fact it is at least
somewhat more out of date than \code{tlBooks}. This timeline is also more
problematic than the other, and less relevant moving forward. Its updating
essentially ceased as the other began.

However, it is included because unlike \code{tlBooks}, which is a timeline of
production titles, this timeline dataset is event-driven. While it may now be
erroneous in places even independent from being out of date, it is useful for
its informative textual entries referencing historically significant events
in Star Trek lore.
}
\seealso{
\code{\link[=tlBooks]{tlBooks()}} \code{\link[=tlFootnotes]{tlFootnotes()}}
}
\keyword{datasets}
