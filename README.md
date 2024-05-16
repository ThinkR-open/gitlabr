
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {gitlabr} <img src="man/figures/logo.png" align="right" alt="" width="120" />

<!-- badges: start -->

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/gitlabr)](https://cran.r-project.org/package=gitlabr)
![CRAN Downloads Badge](https://cranlogs.r-pkg.org/badges/gitlabr)
[![codecov](https://codecov.io/gh/ThinkR-open/gitlabr/graph/badge.svg?token=EVRTX5LST9)](https://app.codecov.io/gh/ThinkR-open/gitlabr)
[![R-CMD-check](https://github.com/ThinkR-open/gitlabr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ThinkR-open/gitlabr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Never dreamt of creating and managing your GitLab projects from R?
{gitlabr} is here to help you with that\!  
With {gitlabr}, you can interact with GitLab’s API to manage your
projects, issues, merge requests, pipelines, wikis, and more.  
Now, the automation of your regular tasks with GitLab is just a few
lines of R code away.

## Installation

You can install the most recent stable version from CRAN using:

``` r
install.packages("gitlabr")
```

To install the development version using
[devtools](https://cran.r-project.org/package=devtools), type:

``` r
install.packages("gitlabr", repos = "https://thinkr-open.r-universe.dev")
```

See the
[CONTRIBUTING.md](https://github.com/ThinkR-open/gitlabr/blob/main/CONTRIBUTING.md)
for instructions on how to run tests locally and contributor
information.

## Recommended GitLab versions

GitLab 11.6 or higher is generally recommended when using {gitlabr}
version 2.0.0 or higher. This {gitlabr} version uses the GitLab API v4.

## Quick Start Example

R code using {gitlabr} to perform some common GitLab actions can look
like this

  - Create a TOKEN on your GitLab instance with scopes: `api`
      - For instance on gitlab.com:
        `https://gitlab.com/-/profile/personal_access_tokens`
  - Store your token in .Renviron as `GITLAB_COM_TOKEN` with
    `usethis::edit_r_environ()` and restart your session
  - Set a connection to GitLab instance

<!-- end list -->

``` r
library(gitlabr)

# You can verify your token works
# Sys.getenv("GITLAB_COM_TOKEN")

# connect as a fixed user to a GitLab instance for the session
set_gitlab_connection(
  gitlab_url = "https://gitlab.com",
  private_token = Sys.getenv("GITLAB_COM_TOKEN")
)
```

  - Find the list of projects available to you
      - Define a limit of pages of projects to search in with
        `max_page`, otherwise the entire GitLab.com will be downloaded
        here…
      - Find all parameters available in the API for projects on this
        page: <https://docs.gitlab.com/ee/api/projects.html>
          - For instance, we can set `owned = FALSE` to retrieve all
            projects except ours.

<!-- end list -->

``` r
# a tibble is returned, as is always by {gitlabr} functions
gl_list_projects(max_page = 2, owned = FALSE)
#> # A tibble: 40 × 129
#>    id       name        name_with_namespace path  path_with_namespace created_at
#>    <chr>    <chr>       <chr>               <chr> <chr>               <chr>     
#>  1 57865685 nodejsappl… Arsalan Ahmed Zia … node… arsalanahmedzia_th… 2024-05-1…
#>  2 57865684 Self-Hoste… Anand R / Self-Hos… self… anandr72/self-host… 2024-05-1…
#>  3 57865661 cuda        handcat / cuda      cuda  handcat/cuda        2024-05-1…
#>  4 57865656 TicTacToe   Debeleac Vincenzzi… tict… Andreidoo/tictactoe 2024-05-1…
#>  5 57865597 Sparks Git… Nicolas Tatard / S… spar… tatardnicolas47/sp… 2024-05-1…
#>  6 57865595 Sparks Git… Patrick Poncy / Sp… spar… PatSopra/sparks-gi… 2024-05-1…
#>  7 57865594 Sparks Git… Emie Bourdeau / Sp… spar… Emie_Bourdeau/spar… 2024-05-1…
#>  8 57865590 ComMan UI   ossama hassari / C… comm… ossamahassari98/co… 2024-05-1…
#>  9 57865581 Sparks Git… Raphaël Mechali / … spar… RaphaelMechali/spa… 2024-05-1…
#> 10 57865574 copy local… mvaskuri / copy lo… copy… mvaskuri1/copy-loc… 2024-05-1…
#> # ℹ 30 more rows
#> # ℹ 123 more variables: default_branch <chr>, ssh_url_to_repo <chr>,
#> #   http_url_to_repo <chr>, web_url <chr>, readme_url <chr>, forks_count <chr>,
#> #   star_count <chr>, last_activity_at <chr>, namespace.id <chr>,
#> #   namespace.name <chr>, namespace.path <chr>, namespace.kind <chr>,
#> #   namespace.full_path <chr>, namespace.avatar_url <chr>,
#> #   namespace.web_url <chr>, container_registry_image_prefix <chr>, …
```

### Work with a specific project

  - Explore one of your projects. You can set the name of the project or
    its ID. The ID is highly recommended, in particular if your project
    does not appear in the first pages of projects above.
      - Let’s explore [project
        “repo.rtask”](https://gitlab.com/statnmap/repo.rtask), with
        `ID = 20384533` on GitLab.com

<!-- end list -->

``` r
my_project <- 20384533 # repo.rtask",
```

  - If the default branch is not named `main`, you need to specify it
    with `gitlabr_options_set()`

<!-- end list -->

``` r
gitlabr_options_set("gitlabr.main", "master")
```

  - List files of the project using `gl_list_files()`

<!-- end list -->

``` r
gl_list_files(project = my_project)
#> # A tibble: 2 × 5
#>   id                                       name        type  path        mode  
#>   <chr>                                    <chr>       <chr> <chr>       <chr> 
#> 1 9c66eff9a1f6f34b6d9108ef07d76f8ce4c4e47f NEWS.md     blob  NEWS.md     100644
#> 2 c36b681bb31b80cbd090f07c95f09788c88629a6 example.txt blob  example.txt 100644
```

  - List issues with `gl_list_issues()`

<!-- end list -->

``` r
gl_list_issues(project = my_project)
#> # A tibble: 2 × 40
#>   id    iid   project_id title description state created_at updated_at author.id
#>   <chr> <chr> <chr>      <chr> <chr>       <chr> <chr>      <chr>      <chr>    
#> 1 6952… 2     20384533   A se… The blog p… open… 2020-08-0… 2020-08-0… 4809823  
#> 2 6952… 1     20384533   An e… No desc in… open… 2020-08-0… 2020-08-0… 4809823  
#> # ℹ 31 more variables: author.username <chr>, author.name <chr>,
#> #   author.state <chr>, author.locked <chr>, author.avatar_url <chr>,
#> #   author.web_url <chr>, type <chr>, user_notes_count <chr>,
#> #   merge_requests_count <chr>, upvotes <chr>, downvotes <chr>,
#> #   confidential <chr>, issue_type <chr>, web_url <chr>,
#> #   time_stats.time_estimate <chr>, time_stats.total_time_spent <chr>,
#> #   task_completion_status.count <chr>, …
```

  - Create an issue

<!-- end list -->

``` r
# create a new issue
new_feature_issue <- gl_create_issue(project = my_project, title = "Implement new feature")

# Your user ID
my_id <- 0000000

# assign issue to me
gl_assign_issue(
  project = my_project,
  issue_id = new_feature_issue$iid,
  assignee_id = my_id
)

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

  - The verb is `POST`
  - The request is `projects`
  - Required attributes are `name` or `path` (if `name` not set)
  - `default_branch` is an attribute that can be set if wanted, but not
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

Implement whatever suits your needs \!

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

  - bookdown-production.yml

  - bookdown.yml

  - check-coverage-pkgdown-renv.yml

  - check-coverage-pkgdown.yml

## Further information

  - For an introduction see the `vignette("a-gitlabr", package =
    "gitlabr")`
  - When writing custom extensions (“convenience functions”) for
    {gitlabr} or when you experience any trouble, the very extensive
    [GitLab API documentation](https://docs.gitlab.com/ce/api/) can be
    helpful.

# Contributing to {gitlabr}

You’re welcome to contribute to {gitlabr} by editing the source code,
adding more convenience functions, filing issues, etc.
[CONTRIBUTING.md](https://github.com/ThinkR-open/gitlabr/blob/main/CONTRIBUTING.md)
compiles some information helpful in that process.

## Code of Conduct

Please note that the gitlabr project is released with a [Contributor
Code of
Conduct](https://thinkr-open.github.io/gitlabr/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

*Note that the {gitlabr} package was originally created by [Jirka
Lewandowski](https://github.com/jirkalewandowski/gitlabr). The present
repository is a fork to be able to continue development of this
package.*
