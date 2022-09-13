
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {gitlabr} <img src="man/figures/logo.png" align="right" alt="" width="120" />

<!-- badges: start -->

[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/gitlabr)](https://cran.r-project.org/package=gitlabr)
![CRAN Downloads Badge](https://cranlogs.r-pkg.org/badges/gitlabr)
[![R-CMD-check](https://github.com/statnmap/gitlabr/workflows/R-CMD-check/badge.svg)](https://github.com/statnmap/gitlabr/actions)
[![Codecov test
coverage](https://codecov.io/gh/statnmap/gitlabr/branch/master/graph/badge.svg)](https://app.codecov.io/gh/statnmap/gitlabr?branch=main)
<!-- badges: end -->

**There are multiple breaking changes in {gitlabr} v2, please refer to
the corresponding vignette:
<https://statnmap.github.io/gitlabr/articles/z-gitlabr-v2.html>**

*Note that the {gitlabr} package was originally created by [Jirka
Lewandowski](https://github.com/jirkalewandowski/gitlabr). The present
repository is a fork to be able to continue development of this
package.*

## Installation

You can install the most recent stable version from CRAN using:

``` r
install.packages("gitlabr")
```

To install the development version using
[devtools](https://cran.r-project.org/package=devtools), type:

``` r
install.packages("statnmap/gitlabr", repos = 'https://thinkr-open.r-universe.dev')
```

See the
[CONTRIBUTING.md](https://github.com/statnmap/gitlabr/blob/main/CONTRIBUTING.md)
for instructions on how to run tests locally and contributor
information.

## Recommended GitLab versions

GitLab 11.6 or higher is generally recommended when using {gitlabr}
version 2.0.0 or higher. This {gitlabr} version uses the GitLab API v4.

## Quick Start Example

R code using {gitlabr} to perform some common GitLab actions can look
like this

-   Create a TOKEN on your GitLab instance with scopes: `api`
    -   For instance on gitlab.com:
        `https://gitlab.com/-/profile/personal_access_tokens`
-   Store your token in .Renviron as `GITLAB_COM_TOKEN` with
    `usethis::edit_r_environ()` and restart your session
-   Set a connection to GitLab instance

``` r
library(gitlabr)

# You can verify your token works
# Sys.getenv("GITLAB_COM_TOKEN")

# connect as a fixed user to a GitLab instance for the session
set_gitlab_connection(
  gitlab_url = "https://gitlab.com",
  private_token = Sys.getenv("GITLAB_COM_TOKEN"))
```

-   Find the list of projects available to you
    -   Define a limit of pages of projects to search in with
        `max_page`, otherwise the entire GitLab.com will be downloaded
        here…
    -   Find all parameters available in the API for projects on this
        page: <https://docs.gitlab.com/ee/api/projects.html>
        -   For instance, we can set `owned = FALSE` to retrieve all
            projects except ours.

``` r
# a tibble is returned, as is always by {gitlabr} functions
gl_list_projects(max_page = 2, owned = FALSE) 
#> # A tibble: 40 × 135
#>    id       description name  name_with_names… path  path_with_names… created_at
#>    <chr>    <chr>       <chr> <chr>            <chr> <chr>            <chr>     
#>  1 30670263 ""          Proj… Enzo Lop / Proj… proj… enzo.lop.pro/pr… 2021-10-2…
#>  2 30670257 ""          test  Seung-hyun Lee … test  faintblue324/te… 2021-10-2…
#>  3 30670253 ""          s54   Zuitt-projects … s54   zuitt-projects3… 2021-10-2…
#>  4 30670220 ""          temp… taka / template  temp… hnam/template    2021-10-2…
#>  5 30670189 ""          Jeng… NATALIA GARCIA … jeng… 22113346/jenga-… 2021-10-2…
#>  6 30670181 ""          RStu… yannyven / RStu… rstu… yannyven/rstudi… 2021-10-2…
#>  7 30670175 "NAO ENSTA… NAO-… Danut POP / NAO… NAO-… blueDonuts69/NA… 2021-10-2…
#>  8 30670166 "A complet… remo… Alexa Fevic / r… remo… alexafevic/remo… 2021-10-2…
#>  9 30670163 ""          YAOD… flagarde / YAOD… YAOD… flagarde/YAODAQ  2021-10-2…
#> 10 30670162 ""          eval… zenika-poei-ren… eval… zenika-poei-ren… 2021-10-2…
#> # … with 30 more rows, and 128 more variables: default_branch <chr>,
#> #   ssh_url_to_repo <chr>, http_url_to_repo <chr>, web_url <chr>,
#> #   readme_url <chr>, forks_count <chr>, star_count <chr>,
#> #   last_activity_at <chr>, namespace.id <chr>, namespace.name <chr>,
#> #   namespace.path <chr>, namespace.kind <chr>, namespace.full_path <chr>,
#> #   namespace.avatar_url <chr>, namespace.web_url <chr>,
#> #   container_registry_image_prefix <chr>, _links.self <chr>, …
```

### Work with a specific project

-   Explore one of your projects. You can set the name of the project or
    its ID. The ID is highly recommended, in particular if your project
    does not appear in the first pages of projects above.
    -   Let’s explore [project
        “repo.rtask”](https://gitlab.com/statnmap/repo.rtask), with
        `ID = 20384533` on GitLab.com

``` r
my_project <- 20384533 #repo.rtask",
```

-   If the default branch is not named `main`, you need to specify it
    with `gitlabr_options_set()`

``` r
gitlabr_options_set("gitlabr.main", "master")
```

-   List files of the project using `gl_list_files()`

``` r
gl_list_files(project = my_project)
#> # A tibble: 2 × 5
#>   id                                       name        type  path        mode  
#>   <chr>                                    <chr>       <chr> <chr>       <chr> 
#> 1 9c66eff9a1f6f34b6d9108ef07d76f8ce4c4e47f NEWS.md     blob  NEWS.md     100644
#> 2 c36b681bb31b80cbd090f07c95f09788c88629a6 example.txt blob  example.txt 100644
```

-   List issues with `gl_list_issues()`

``` r
gl_list_issues(project = my_project)
#> # A tibble: 2 × 35
#>   id       iid   project_id title description state created_at updated_at author.id
#>   <chr>    <chr> <chr>      <chr> <chr>       <chr> <chr>      <chr>      <chr>    
#> 1 69525849 2     20384533   A se… The blog p… open… 2020-08-0… 2020-08-0… 4809823  
#> 2 69525845 1     20384533   An e… No desc in… open… 2020-08-0… 2020-08-0… 4809823  
#> # … with 26 more variables: author.name <chr>, author.username <chr>,
#> #   author.state <chr>, author.avatar_url <chr>, author.web_url <chr>,
#> #   type <chr>, user_notes_count <chr>, merge_requests_count <chr>,
#> #   upvotes <chr>, downvotes <chr>, confidential <chr>, issue_type <chr>,
#> #   web_url <chr>, time_stats.time_estimate <chr>,
#> #   time_stats.total_time_spent <chr>, task_completion_status.count <chr>,
#> #   task_completion_status.completed_count <chr>, …
```

-   Create an issue

``` r
# create a new issue
new_feature_issue <- gl_create_issue(project = my_project, title = "Implement new feature")

# statnmap user ID
my_id <- 4809823

# assign issue to me
gl_assign_issue(project = my_project,
                issue_id = new_feature_issue$iid,
                assignee_id = my_id)

# Verify new issue is here
gl_list_issues(project = my_project, state = "opened")

# close issue
gl_close_issue(project = my_project, issue_id = new_feature_issue$iid)$state
```

*Note that recent version of GitLab may have anti-spam on opening
issues, leading to ERROR with `gl_create_issue()` if you abuse the API.
You will need to open the issue manually in this case.*

### Use additional requests

If an API request is not already available in {gitlabr}, function
`gitlab()` allows to use any request of the GitLab API
<https://docs.gitlab.com/ce/api/>.

For instance, the API documentation shows how to create a new project in
<https://docs.gitlab.com/ce/api/projects.html#create-project>:

-   The verb is `POST`
-   The request is `projects`
-   Required attributes are `name` or `path` (if `name` not set)
-   `default_branch` is an attribute that can be set if wanted, but not
    required

The corresponding use of `gitlab()` is:

``` r
gitlab(
  req = "projects",
  verb = httr::POST,
  name = "toto",
  default_branch = "main"
)
```

Implement whatever suits your needs !

### Unset connection

``` r
unset_gitlab_connection()
```

## Using GitLab CI with {gitlabr}

{gitlabr} can also be used to create a `.gitlab-ci.yml` file to test,
build and check an R package, a bookdown, … using GitLab’s CI software.
Use `gitlabr::use_gitlab_ci()` with a specific `type` in your project
and your CI should be ready to start in the next commit.

There are pre-defined templates:

-   bookdown-production.yml

-   bookdown.yml

-   check-coverage-pkgdown-renv.yml

-   check-coverage-pkgdown.yml

## Further information

-   For an introduction see the
    `vignette("quick-start-guide-to-gitlabr")`
-   When writing custom extensions (“convenience functions”) for
    {gitlabr} or when you experience any trouble, the very extensive
    [GitLab API documentation](https://docs.gitlab.com/ce/api/) can be
    helpful.

# Contributing to {gitlabr}

You’re welcome to contribute to {gitlabr} by editing the source code,
adding more convenience functions, filing issues, etc.
[CONTRIBUTING.md](https://github.com/statnmap/gitlabr/blob/main/CONTRIBUTING.md)
compiles some information helpful in that process.

## Code of Conduct

Please note that the gitlabr project is released with a [Contributor
Code of
Conduct](https://statnmap.github.io/gitlabr/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.
