[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/gitlabr)](https://cran.r-project.org/package=gitlabr)
![CRAN\ Downloads\ Badge](https://cranlogs.r-pkg.org/badges/gitlabr)

# gitlabr

## Installation

You can install the most recent stable version from CRAN using:

```{r}
install.packages("gitlabr")
```

To install the development version using [devtools](https://cran.r-project.org/package=devtools)), type:
```{r}
library(devtools)
install_github("jirkalewandowski/gitlabr")
```

See the [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on how to run tests locally and contributor information.

## Recommended Gitlab versions

Gitlab 11.6 or higher is generally recommended when using gitlabr version 1.1.6 or higher. This gitlabr version uses the gitlab API v4, older versions of Gitlab using API v3 are still supported by gitlabr 0.9, see details section "API version" of the documentation of `gl_connection` on how to use them. From gitlabr 1.1.6 on API v3 is deprecated and will no longer be tested or maintained, although it is still present in the code. Also within API v4, changes have been made to the gitlab API, most notably for gitlabr, the session endpoint was removed. The versions of gitlabr will always be tested on the corresponding gitlab version, i.e. gitlabr 1.1.6 works best with gitlab 11.6. However, not for every nwe gitlab version there will be a gitlabr version.

## Quick Start Example

R code using gitlabr to perform some easy, common gitlab actions can look like this:

```{r eval = FALSE}
library(gitlabr)

# connect as a fixed user to a gitlab instance
my_gitlab <- gl_connection("https://test-gitlab.points-of-interest.cc",
                           private_token = readLines("secrets/gitlab_token.txt"))
# a function is returned
# its first argument is the request (name or function), optionally followed by parameters

my_gitlab(gl_list_projects) # a data_frame is returned, as is always by gitlabr functions

my_gitlab(gl_list_files, project = "testor")

# create a new issue
new_feature_issue <- my_gitlab(gl_new_issue, project = "testor", "Implement new feature")

# requests via gitlabr always return data_frames, so you can use all common manipulations
require(dplyr)
example_user <-
  my_gitlab("users") %>%
    filter(username == "testuser")

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
- The gitlabr development repository is https://github.com/jirkalewandowski/gitlabr
