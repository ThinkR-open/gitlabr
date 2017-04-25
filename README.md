[![Travis-CI Build Status](https://travis-ci.org/jirkalewandowski/gitlabr.svg?branch=master)](https://travis-ci.org/jirkalewandowski/gitlabr)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/gitlabr)](https://cran.r-project.org/package=gitlabr)
![CRAN\ Downloads\ Badge](http://cranlogs.r-pkg.org/badges/gitlabr)

# gitlabr

## Installation

You can install the most recent stable version from CRAN using:

```{r}
install.packages("gitlabr")
```

To install the development version, in a console type:
```
git clone https://github.com/jirkalewandowski/gitlabr.git
R -e "library(devtools); document('gitlabr'); install('gitlabr')"
```

## Recommended Gitlab versions & Roadmap

Gitlab 9.0 or higher is generally recommended when using gitlabr version 0.9 or higher, since this package version uses the gitlab API v4, older versions use API v3, which was the standard before Gitlab 9.0. Older versions of Gitlab using API v3 are sill supported by gitlabr 0.9, see details section "API version" of the documentation of `gl_connection` on how to use them. From gitlabr 1.0 on (expected in the second half of 2017), API v3 usage will be deprecated.

## Quick Start Example

R code using gitlabr to perform some easy, common gitlab actions can look like this:

```{r}
library(gitlabr)

# connect as a fixed user to a gitlab instance
my_gitlab <- gl_connection("https://gitlab.points-of-interest.cc",
                           login = "testibaer",
                           password = readLines("secrets/gitlab_password.txt"))
# a function is returned
# its first argument is the request (name or function), optionally followed by parameters

my_gitlab(gl_list_projects) # a data_frame is returned, as is always by gitlabr functions

my_gitlab(gl_list_files, project = "gitlabr", path = "R")

# create a new issue
new_feature_issue <- my_gitlab(gl_new_issue, project = "testor", "Implement new feature")

# requests via gitlabr always return data_frames, so you can use all common manipulations
require(dplyr)
example_user <-
  my_gitlab("users") %>%
    filter(username == "testibaer")

# assign issue to a user
my_gitlab(gl_assign_issue, project = "testor",
          new_feature_issue$iid,
          assignee_id = example_user$id)

my_gitlab(gl_list_issues, "testor", state = "opened")

# close issue
my_gitlab(gl_close_issue, project = "testor", new_feature_issue$iid)$state
```

## Further information

- For a comprehensive overview & introduction see the `vignette("quick-start-gitlabr")`
- When writing custom extensions ("convenience functions") for gitlabr or when you experience any trouble, the very extensive [Gitlab API documentation](http://doc.gitlab.com/ce/api/) can be helpful.
- gitlabr is developed on https://gitlab.points-of-interest.cc/points-of-interest/gitlabr -- Github and Gitlab.com are mirrors of this repository, but can be used for filing issues or merge requests.

