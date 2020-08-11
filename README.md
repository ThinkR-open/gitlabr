
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

R code using {gitlabr} to perform some common gitlab actions can look
like this

  - Store your token in .Renviron with `usethis::edit_r_environ()` and
    restart your session

  - Set a connection to Gitlab instance

<!-- end list -->

``` r
library(gitlabr)

# Add: GITLAB_COM_TOKEN=YourTokenHere
# You can verify it worked
Sys.getenv("GITLAB_COM_TOKEN")
#> [1] "YPKzyzsFZcRnbubCFMLT"

# connect as a fixed user to a gitlab instance
my_gitlab <- gl_connection(
  gitlab_url = "https://gitlab.com",
  private_token = Sys.getenv("GITLAB_COM_TOKEN"))
# a function is returned
# its first argument is the request (name or function), optionally followed by parameters
```

  - Find the list of projects available to you
      - Define a limit of pages of projects to search in with
        `max_page`, otherwise the entire Gitlab.com will be downloaded
        here…

<!-- end list -->

``` r
# a data_frame is returned, as is always by gitlabr functions
my_gitlab(gl_list_projects, max_page = 2) 
#> # A tibble: 60 x 116
#>    id    description name  name_with_names… path  path_with_names… created_at
#>    <chr> <chr>       <chr> <chr>            <chr> <chr>            <chr>     
#>  1 2047… ""          Supe… Евгения Шашенко… supe… jeniashasha/sup… 2020-08-1…
#>  2 2047… ""          Assi… Sahani Silva / … assi… sahanisilva1830… 2020-08-1…
#>  3 2047… "Singer.io… tap-… vividfront / me… tap-… vividfront/melt… 2020-08-1…
#>  4 2047… ""          firs… Evgeniy_shigart… firs… evgeniy.shigart… 2020-08-1…
#>  5 2047… "Semana fo… Ruby… Bruno Rodrigues… ruby… BrunoMerz/ruby-… 2020-08-1…
#>  6 2047… ""          Assi… Sahani Silva / … assi… sahanisilva1830… 2020-08-1…
#>  7 2047… "The GTK R… Remm… Scott Bradford … Remm… achmafooma/Remm… 2020-08-1…
#>  8 2047… "My projec… my_f… Dmitry Petelko … my_f… FMStudent/my_fi… 2020-08-1…
#>  9 2047… ""          ILP_… kiran kumar / I… ILP_… itzkirankumar/I… 2020-08-1…
#> 10 2047… ""          rest… dewi cahyanti /… rest… dewichynt15/res… 2020-08-1…
#> # … with 50 more rows, and 109 more variables: ssh_url_to_repo <chr>,
#> #   http_url_to_repo <chr>, web_url <chr>, forks_count <chr>, star_count <chr>,
#> #   last_activity_at <chr>, namespace.id <chr>, namespace.name <chr>,
#> #   namespace.path <chr>, namespace.kind <chr>, namespace.full_path <chr>,
#> #   namespace.avatar_url <chr>, namespace.web_url <chr>, `_links.self` <chr>,
#> #   `_links.issues` <chr>, `_links.merge_requests` <chr>,
#> #   `_links.repo_branches` <chr>, `_links.labels` <chr>, `_links.events` <chr>,
#> #   `_links.members` <chr>, packages_enabled <chr>, empty_repo <chr>,
#> #   archived <chr>, visibility <chr>, owner.id <chr>, owner.name <chr>,
#> #   owner.username <chr>, owner.state <chr>, owner.avatar_url <chr>,
#> #   owner.web_url <chr>, resolve_outdated_diff_discussions <chr>,
#> #   container_registry_enabled <chr>,
#> #   container_expiration_policy.cadence <chr>,
#> #   container_expiration_policy.enabled <chr>,
#> #   container_expiration_policy.keep_n <chr>,
#> #   container_expiration_policy.older_than <chr>,
#> #   container_expiration_policy.next_run_at <chr>, issues_enabled <chr>,
#> #   merge_requests_enabled <chr>, wiki_enabled <chr>, jobs_enabled <chr>,
#> #   snippets_enabled <chr>, service_desk_enabled <chr>,
#> #   service_desk_address <chr>, can_create_merge_request_in <chr>,
#> #   issues_access_level <chr>, repository_access_level <chr>,
#> #   merge_requests_access_level <chr>, forking_access_level <chr>,
#> #   wiki_access_level <chr>, builds_access_level <chr>,
#> #   snippets_access_level <chr>, pages_access_level <chr>,
#> #   shared_runners_enabled <chr>, lfs_enabled <chr>, creator_id <chr>,
#> #   import_status <chr>, open_issues_count <chr>, ci_default_git_depth <chr>,
#> #   public_jobs <chr>, build_timeout <chr>,
#> #   auto_cancel_pending_pipelines <chr>, ci_config_path <chr>,
#> #   only_allow_merge_if_pipeline_succeeds <chr>, request_access_enabled <chr>,
#> #   only_allow_merge_if_all_discussions_are_resolved <chr>,
#> #   remove_source_branch_after_merge <chr>,
#> #   printing_merge_request_link_enabled <chr>, merge_method <chr>,
#> #   auto_devops_enabled <chr>, auto_devops_deploy_strategy <chr>,
#> #   autoclose_referenced_issues <chr>, approvals_before_merge <chr>,
#> #   mirror <chr>, external_authorization_classification_label <chr>,
#> #   default_branch <chr>, readme_url <chr>, namespace.parent_id <chr>,
#> #   forked_from_project.id <chr>, forked_from_project.description <chr>,
#> #   forked_from_project.name <chr>,
#> #   forked_from_project.name_with_namespace <chr>,
#> #   forked_from_project.path <chr>,
#> #   forked_from_project.path_with_namespace <chr>,
#> #   forked_from_project.created_at <chr>,
#> #   forked_from_project.default_branch <chr>,
#> #   forked_from_project.ssh_url_to_repo <chr>,
#> #   forked_from_project.http_url_to_repo <chr>,
#> #   forked_from_project.web_url <chr>, forked_from_project.readme_url <chr>,
#> #   forked_from_project.forks_count <chr>,
#> #   forked_from_project.star_count <chr>,
#> #   forked_from_project.last_activity_at <chr>,
#> #   forked_from_project.namespace.id <chr>,
#> #   forked_from_project.namespace.name <chr>,
#> #   forked_from_project.namespace.path <chr>,
#> #   forked_from_project.namespace.kind <chr>,
#> #   forked_from_project.namespace.full_path <chr>,
#> #   forked_from_project.namespace.web_url <chr>, avatar_url <chr>, …
```

  - Explore one of your projects. You can set the name of the project or
    its ID. The ID is highly recommended, in particular if your project
    does not appear in the first pages of projects above.
      - Let’s explore [project
        “repo.rtask”](https://gitlab.com/statnmap/repo.rtask), with
        `ID = 20384533` on Gitlab.com

<!-- end list -->

``` r
my_project <- 20384533 #repo.rtask",
```

  - List files of the project using `gl_list_files`

<!-- end list -->

``` r
my_gitlab(gl_list_files, project = my_project)
#> # A tibble: 2 x 5
#>   id                                       name        type  path        mode  
#>   <chr>                                    <chr>       <chr> <chr>       <chr> 
#> 1 9c66eff9a1f6f34b6d9108ef07d76f8ce4c4e47f NEWS.md     blob  NEWS.md     100644
#> 2 c36b681bb31b80cbd090f07c95f09788c88629a6 example.txt blob  example.txt 100644
```

  - List issues with `gl_list_issues`

<!-- end list -->

``` r
my_gitlab(gl_list_issues, project = my_project)
#> # A tibble: 4 x 51
#>   id    iid   project_id title state created_at updated_at closed_at
#>   <chr> <chr> <chr>      <chr> <chr> <chr>      <chr>      <chr>    
#> 1 6972… 4     20384533   Impl… clos… 2020-08-1… 2020-08-1… 2020-08-…
#> 2 6972… 3     20384533   Impl… clos… 2020-08-1… 2020-08-1… 2020-08-…
#> 3 6952… 2     20384533   A se… open… 2020-08-0… 2020-08-0… <NA>     
#> 4 6952… 1     20384533   An e… open… 2020-08-0… 2020-08-0… <NA>     
#> # … with 43 more variables: closed_by.id <chr>, closed_by.name <chr>,
#> #   closed_by.username <chr>, closed_by.state <chr>,
#> #   closed_by.avatar_url <chr>, closed_by.web_url <chr>, assignees.id <chr>,
#> #   assignees.name <chr>, assignees.username <chr>, assignees.state <chr>,
#> #   assignees.avatar_url <chr>, assignees.web_url <chr>, author.id <chr>,
#> #   author.name <chr>, author.username <chr>, author.state <chr>,
#> #   author.avatar_url <chr>, author.web_url <chr>, assignee.id <chr>,
#> #   assignee.name <chr>, assignee.username <chr>, assignee.state <chr>,
#> #   assignee.avatar_url <chr>, assignee.web_url <chr>, user_notes_count <chr>,
#> #   merge_requests_count <chr>, upvotes <chr>, downvotes <chr>,
#> #   confidential <chr>, web_url <chr>, time_stats.time_estimate <chr>,
#> #   time_stats.total_time_spent <chr>, task_completion_status.count <chr>,
#> #   task_completion_status.completed_count <chr>, has_tasks <chr>,
#> #   `_links.self` <chr>, `_links.notes` <chr>, `_links.award_emoji` <chr>,
#> #   `_links.project` <chr>, references.short <chr>, references.relative <chr>,
#> #   references.full <chr>, description <chr>
```

  - Create an issue

<!-- end list -->

``` r
# create a new issue
new_feature_issue <- my_gitlab(gl_new_issue, project = my_project, "Implement new feature")

# statnmap user ID
my_id <- 4809823

# assign issue to me
my_gitlab(gl_assign_issue, 
          project = my_project,
          new_feature_issue$iid,
          assignee_id = my_id)
#> # A tibble: 1 x 44
#>   id    iid   project_id title state created_at updated_at assignees.id
#>   <chr> <chr> <chr>      <chr> <chr> <chr>      <chr>      <chr>       
#> 1 6972… 5     20384533   Impl… open… 2020-08-1… 2020-08-1… 4809823     
#> # … with 36 more variables: assignees.name <chr>, assignees.username <chr>,
#> #   assignees.state <chr>, assignees.avatar_url <chr>, assignees.web_url <chr>,
#> #   author.id <chr>, author.name <chr>, author.username <chr>,
#> #   author.state <chr>, author.avatar_url <chr>, author.web_url <chr>,
#> #   assignee.id <chr>, assignee.name <chr>, assignee.username <chr>,
#> #   assignee.state <chr>, assignee.avatar_url <chr>, assignee.web_url <chr>,
#> #   user_notes_count <chr>, merge_requests_count <chr>, upvotes <chr>,
#> #   downvotes <chr>, confidential <chr>, web_url <chr>,
#> #   time_stats.time_estimate <chr>, time_stats.total_time_spent <chr>,
#> #   task_completion_status.count <chr>,
#> #   task_completion_status.completed_count <chr>, has_tasks <chr>,
#> #   `_links.self` <chr>, `_links.notes` <chr>, `_links.award_emoji` <chr>,
#> #   `_links.project` <chr>, references.short <chr>, references.relative <chr>,
#> #   references.full <chr>, subscribed <chr>

# Verify new issue is here
my_gitlab(gl_list_issues, my_project, state = "opened")
#> # A tibble: 3 x 44
#>   id    iid   project_id title state created_at updated_at assignees.id
#>   <chr> <chr> <chr>      <chr> <chr> <chr>      <chr>      <chr>       
#> 1 6972… 5     20384533   Impl… open… 2020-08-1… 2020-08-1… 4809823     
#> 2 6952… 2     20384533   A se… open… 2020-08-0… 2020-08-0… <NA>        
#> 3 6952… 1     20384533   An e… open… 2020-08-0… 2020-08-0… <NA>        
#> # … with 36 more variables: assignees.name <chr>, assignees.username <chr>,
#> #   assignees.state <chr>, assignees.avatar_url <chr>, assignees.web_url <chr>,
#> #   author.id <chr>, author.name <chr>, author.username <chr>,
#> #   author.state <chr>, author.avatar_url <chr>, author.web_url <chr>,
#> #   assignee.id <chr>, assignee.name <chr>, assignee.username <chr>,
#> #   assignee.state <chr>, assignee.avatar_url <chr>, assignee.web_url <chr>,
#> #   user_notes_count <chr>, merge_requests_count <chr>, upvotes <chr>,
#> #   downvotes <chr>, confidential <chr>, web_url <chr>,
#> #   time_stats.time_estimate <chr>, time_stats.total_time_spent <chr>,
#> #   task_completion_status.count <chr>,
#> #   task_completion_status.completed_count <chr>, has_tasks <chr>,
#> #   `_links.self` <chr>, `_links.notes` <chr>, `_links.award_emoji` <chr>,
#> #   `_links.project` <chr>, references.short <chr>, references.relative <chr>,
#> #   references.full <chr>, description <chr>

# close issue
my_gitlab(gl_close_issue, project = my_project, new_feature_issue$iid)$state
#> [1] "closed"
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
