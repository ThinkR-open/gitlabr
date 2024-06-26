% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/groups.R
\name{gl_list_groups}
\alias{gl_list_groups}
\alias{gl_list_sub_groups}
\title{List and manage groups}
\usage{
gl_list_groups(...)

gl_list_sub_groups(group, ...)
}
\arguments{
\item{...}{passed on to \code{\link[=gitlab]{gitlab()}}}

\item{group}{The ID, name or URL-encoded path of the group}
}
\value{
tibble of each group with corresponding information
}
\description{
List and manage groups
}
\details{
When using \code{gl_list_sub_groups()}, if you request this list as:
\itemize{
\item An unauthenticated user, the response returns only public groups.
\item An authenticated user, the response returns only the groups
you’re a member of and does not include public groups.
}
}
\examples{
\dontrun{
set_gitlab_connection(
  gitlab_url = "https://gitlab.com",
  private_token = Sys.getenv("GITLAB_COM_TOKEN")
)
# List all groups
gl_list_groups(max_page = 1)
# List sub-groups of a group
gl_list_sub_groups(group_id = "<<group-id>>", max_page = 1)
}
}
