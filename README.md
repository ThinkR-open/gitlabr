
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gitlabr

<!-- badges: start -->

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/gitlabr)](https://cran.r-project.org/package=gitlabr)
![CRAN Downloads Badge](https://cranlogs.r-pkg.org/badges/gitlabr) [![R
build
status](https://github.com/statnmap/gitlabr/workflows/R-CMD-check/badge.svg)](https://github.com/statnmap/gitlabr/actions)
<!-- badges: end -->

## Installation

You can install the most recent stable version from CRAN using:

``` r
install.packages("gitlabr")
```

To install the development version using
[devtools](https://cran.r-project.org/package=devtools)), type:

``` r
devtools::install_github("statnmap/gitlabr")
```

See the [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on how to
run tests locally and contributor information.

## Recommended Gitlab versions

Gitlab 11.6 or higher is generally recommended when using gitlabr
version 1.1.6 or higher. This gitlabr version uses the gitlab API v4,
older versions of Gitlab using API v3 are still supported by gitlabr
0.9, see details section “API version” of the documentation of
`gl_connection` on how to use them. From gitlabr 1.1.6 on API v3 is
deprecated and will no longer be tested or maintained, although it is
still present in the code. Also within API v4, changes have been made to
the gitlab API, most notably for gitlabr, the session endpoint was
removed. The versions of gitlabr will always be tested on the
corresponding gitlab version, i.e. gitlabr 1.1.6 works best with gitlab
11.6. However, not for every new gitlab version there will be a gitlabr
version.

## Quick Start Example

R code using gitlabr to perform some easy, common gitlab actions can
look like this:

``` r
library(gitlabr)

# Store your token in .Renviron and restart your session
usethis::edit_r_environ()
# Add: GITLAB_COM_TOKEN=YourTokenHere
# You can verify it worked
Sys.getenv("GITLAB_COM_TOKEN")

# connect as a fixed user to a gitlab instance
my_gitlab <- gl_connection("https://gitlab.com",
                           private_token = Sys.getenv("GITLAB_COM_TOKEN"))
# a function is returned
# its first argument is the request (name or function), optionally followed by parameters

my_gitlab(gl_list_projects) # a data_frame is returned, as is always by gitlabr functions

my_gitlab(gl_list_files, project = my_project)

# Define the project you want to work on
my_project <- my_project
# It is even better if you use the project ID (as numeric),
# in particular, if you have a big Gitlab server
my_project <- 20416969

# create a new issue
new_feature_issue <- my_gitlab(gl_new_issue, project = my_project, "Implement new feature")

# requests via gitlabr always return data_frames, so you can use all common manipulations
library(dplyr)
example_user <-
  my_gitlab("users") %>%
    filter(username == "statnmap")

# assign issue to a user
my_gitlab(gl_assign_issue, project = my_project,
          new_feature_issue$iid,
          assignee_id = example_user$id)

my_gitlab(gl_list_issues, my_project, state = "opened")

# close issue
my_gitlab(gl_close_issue, project = my_project, new_feature_issue$iid)$state
```

## Further information

  - For a comprehensive overview & introduction see the
    `vignette("quick-start-gitlabr")`
  - When writing custom extensions (“convenience functions”) for gitlabr
    or when you experience any trouble, the very extensive [Gitlab API
    documentation](http://doc.gitlab.com/ce/api/) can be helpful.

*Note that the {gitlabr} package was originally created by [Jirka
Lewandowski](https://github.com/jirkalewandowski/gitlabr). The present
repository is a fork to be able to continue development of this
package.*

## To Do - If you want to contribute

*See the [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on how to
run tests locally and contributor information.*  
**Please help me pass unit tests \!**

From [Jenny Brian
review](https://github.com/jennybc/gitlabr/blob/jenny-review/jenny-review.md)

### Example with gitlab.com

I have not been able to run basic code against gitlab.com. I *can* run
essentially all code I see in tests, vignette, etc. against
gitlab.points-of-interest.cc. It’s not clear if this is a real problem
or a documentation problem, leading to user error. Either way, it needs
to be addressed. + It would probably be best if examples, README, etc.
featured gitlab.com, as most users would probably be doing that. It
might also reveal now or in the future if there is some underlying
problem that I am experiencing. + For example, here’s code adapted from
the examples in `gl_connection()`:

``` r
my_gitlab <- gl_connection(
  "https://gitlab.com",
  private_token = Sys.getenv("GITLAB_PVT_TOKEN")
)
my_gitlab("projects")
```

  - First, the `gl_connection()` call needs to specify the name of the
    second argument or else it’s interpreted as the `login`. Second, the
    `my_gitlab()` call hangs indefinitely for me.

### Automated tests

*See the [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on how to
run tests locally and contributor information.*

I was able to run tests for this package without too much pain, which is
pretty impressive, so big kudos for that\! I have yet to write tests for
an API-wrapping package that achieves this worthy goal. Some thoughts
and suggestions:

  - Why test against your gitlab server vs gitlab.com? It’s not
    completely hard-wired, given the URL in `environment.yml` but I
    suspect there would be some undocumented setup required if I
    actually changed the target gitlab server.
  - The instructions don’t tell me how to populate `environment.yml`.
    Where do I get this info on gitlab? Is the token supposed to be the
    private token displayed in the account tab of user settings or an
    access token generated from the access tokens tab?
  - Once I populate `environment.yml` with real info, I should
    `.gitignore` it, right? That would be good to clarify. If testing on
    CI, then I assume there’s an encryption strategy for this file. Or
    maybe secure env vars are used?
  - Each test file should use `context("blah blah")` at the top for
    nicer reporting. I’ve done this is my review branch.
  - I had to `skip()` the test about issue editing, because I don’t have
    necessary permission. Would be good to implement this such that
    tester is editing an issue they have permission on. Again, pretty
    impressive that it’s the *only* test I had to skip\! I’ve done this
    is my review branch.
  - [These lines re: API version in
    `testthat.R`](https://github.com/jirkalewandowski/gitlabr/blob/3525479b1316abd2f2122f7778be2c3c4f8b3d06/tests/testthat.R#L4-L14)
    are pretty unusual. I can’t infer the exact goal, but wonder if
    there’s a better / more conventional way to achieve it. Obviously, I
    understand it’s got something to do with testing against different
    API versions.
  - I’ve moved common env var setup into `helper.R` and out of
    individual test files. Looking at the top of these files, I suspect
    even more setup could probably be similarly centralized? `helper.R`
    is always sourced by `devtools::load_all()` so this makes for a nice
    workflow even when developing / running tests interactively,
    i.e. the info doesn’t *need* to live in each file.

# Contributing to {gitlabr}

You’re welcome to contribute to {gitlabr} by editing the source code,
adding more convenience functions, filing issues, etc.
[CONTRIBUTING.md](CONTRIBUTING.md) compiles some information helpful in
that process.

Please also note the [Code of Conduct](CONDUCT.md).
