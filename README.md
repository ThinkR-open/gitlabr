
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {gitlabr}

<!-- badges: start -->

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/gitlabr)](https://cran.r-project.org/package=gitlabr)
![CRAN Downloads Badge](https://cranlogs.r-pkg.org/badges/gitlabr) [![R
build
status](https://github.com/statnmap/gitlabr/workflows/R-CMD-check/badge.svg)](https://github.com/statnmap/gitlabr/actions)
<!-- badges: end -->

**There are multiple breaking changes in {gitlabr} v2, please refer to
the corresponding vignette:
<https://statnmap.github.io/gitlabr/articles/gitlabr-v2.html>**

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
devtools::install_github("statnmap/gitlabr")
```

See the [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on how to
run tests locally and contributor information.

## Recommended GitLab versions

GitLab 11.6 or higher is generally recommended when using {gitlabr}
version 1.1.6 or higher. This {gitlabr} version uses the GitLab API v4.

## Quick Start Example

R code using {gitlabr} to perform some common GitLab actions can look
like this

-   Create a TOKEN on your Gitlab instance with scopes: `api`

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

``` r
# a tibble is returned, as is always by {gitlabr} functions
gl_list_projects(max_page = 2) 
#> # A tibble: 40 x 125
#>    id     description  name   name_with_names… path  path_with_names… created_at
#>    <chr>  <chr>        <chr>  <chr>            <chr> <chr>            <chr>     
#>  1 27001… ""           ffmpe… Grumbulon / ffm… ffmp… grumbulon/ffmpe… 2021-05-2…
#>  2 27001… "A minimal … freed… Ryan Gonzalez /… free… refi64/freedesk… 2021-05-2…
#>  3 27001… "new-cpac 2… New C… anuntachai doun… new-… arwng/new-cpac-… 2021-05-2…
#>  4 27001… ""           cart-… playlister / ca… cart… playlister1/car… 2021-05-2…
#>  5 27001… ""           tinap… Максим Орлов / … tina… maaxorlov/tinap… 2021-05-2…
#>  6 27001… ""           track… playlister / tr… trac… playlister1/tra… 2021-05-2…
#>  7 27001… ""           andro… juliano osmir /… andr… julianoosmir/an… 2021-05-2…
#>  8 27001… ""           iti_c… Bri WS / iti_co… iti_… briws/iti_count… 2021-05-2…
#>  9 27001… ""           users… playlister / us… user… playlister1/use… 2021-05-2…
#> 10 27001… ""           test-… Ibrahim Hz / te… test… ibrahimhz/test-… 2021-05-2…
#> # … with 30 more rows, and 118 more variables: default_branch <chr>,
#> #   ssh_url_to_repo <chr>, http_url_to_repo <chr>, web_url <chr>,
#> #   forks_count <chr>, star_count <chr>, last_activity_at <chr>,
#> #   namespace.id <chr>, namespace.name <chr>, namespace.path <chr>,
#> #   namespace.kind <chr>, namespace.full_path <chr>,
#> #   namespace.avatar_url <chr>, namespace.web_url <chr>,
#> #   container_registry_image_prefix <chr>, _links.self <chr>,
#> #   _links.issues <chr>, _links.merge_requests <chr>,
#> #   _links.repo_branches <chr>, _links.labels <chr>, _links.events <chr>,
#> #   _links.members <chr>, packages_enabled <chr>, empty_repo <chr>,
#> #   archived <chr>, visibility <chr>, owner.id <chr>, owner.name <chr>,
#> #   owner.username <chr>, owner.state <chr>, owner.avatar_url <chr>,
#> #   owner.web_url <chr>, resolve_outdated_diff_discussions <chr>,
#> #   container_registry_enabled <chr>,
#> #   container_expiration_policy.cadence <chr>,
#> #   container_expiration_policy.enabled <chr>,
#> #   container_expiration_policy.keep_n <chr>,
#> #   container_expiration_policy.older_than <chr>,
#> #   container_expiration_policy.name_regex <chr>,
#> #   container_expiration_policy.next_run_at <chr>, issues_enabled <chr>,
#> #   merge_requests_enabled <chr>, wiki_enabled <chr>, jobs_enabled <chr>,
#> #   snippets_enabled <chr>, service_desk_enabled <chr>,
#> #   service_desk_address <chr>, can_create_merge_request_in <chr>,
#> #   issues_access_level <chr>, repository_access_level <chr>,
#> #   merge_requests_access_level <chr>, forking_access_level <chr>,
#> #   wiki_access_level <chr>, builds_access_level <chr>,
#> #   snippets_access_level <chr>, pages_access_level <chr>,
#> #   operations_access_level <chr>, analytics_access_level <chr>,
#> #   shared_runners_enabled <chr>, lfs_enabled <chr>, creator_id <chr>,
#> #   import_status <chr>, open_issues_count <chr>, ci_default_git_depth <chr>,
#> #   ci_forward_deployment_enabled <chr>, public_jobs <chr>,
#> #   build_timeout <chr>, auto_cancel_pending_pipelines <chr>,
#> #   ci_config_path <chr>, only_allow_merge_if_pipeline_succeeds <chr>,
#> #   restrict_user_defined_variables <chr>, request_access_enabled <chr>,
#> #   only_allow_merge_if_all_discussions_are_resolved <chr>,
#> #   remove_source_branch_after_merge <chr>,
#> #   printing_merge_request_link_enabled <chr>, merge_method <chr>,
#> #   auto_devops_enabled <chr>, auto_devops_deploy_strategy <chr>,
#> #   autoclose_referenced_issues <chr>, approvals_before_merge <chr>,
#> #   mirror <chr>, external_authorization_classification_label <chr>,
#> #   requirements_enabled <chr>, security_and_compliance_enabled <chr>,
#> #   readme_url <chr>, avatar_url <chr>, forked_from_project.id <chr>,
#> #   forked_from_project.description <chr>, forked_from_project.name <chr>,
#> #   forked_from_project.name_with_namespace <chr>,
#> #   forked_from_project.path <chr>,
#> #   forked_from_project.path_with_namespace <chr>,
#> #   forked_from_project.created_at <chr>,
#> #   forked_from_project.default_branch <chr>,
#> #   forked_from_project.ssh_url_to_repo <chr>,
#> #   forked_from_project.http_url_to_repo <chr>,
#> #   forked_from_project.web_url <chr>, forked_from_project.readme_url <chr>,
#> #   forked_from_project.avatar_url <chr>,
#> #   forked_from_project.forks_count <chr>, …
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

-   List files of the project using `gl_list_files`

``` r
gl_list_files(project = my_project)
#> # A tibble: 2 x 5
#>   id                                       name        type  path        mode  
#>   <chr>                                    <chr>       <chr> <chr>       <chr> 
#> 1 9c66eff9a1f6f34b6d9108ef07d76f8ce4c4e47f NEWS.md     blob  NEWS.md     100644
#> 2 c36b681bb31b80cbd090f07c95f09788c88629a6 example.txt blob  example.txt 100644
```

-   List issues with `gl_list_issues`

``` r
gl_list_issues(project = my_project)
#> # A tibble: 15 x 54
#>    id     iid   project_id title      state  created_at  updated_at  closed_at  
#>    <chr>  <chr> <chr>      <chr>      <chr>  <chr>       <chr>       <chr>      
#>  1 81134… 15    20384533   Implement… closed 2021-03-17… 2021-03-17… 2021-03-17…
#>  2 73853… 14    20384533   Implement… closed 2020-11-04… 2020-11-04… 2020-11-04…
#>  3 72498… 13    20384533   Implement… closed 2020-10-10… 2020-10-10… 2020-10-10…
#>  4 72498… 12    20384533   Implement… closed 2020-10-10… 2020-10-10… 2020-10-10…
#>  5 72498… 11    20384533   Implement… closed 2020-10-10… 2020-10-10… 2020-10-10…
#>  6 72498… 10    20384533   Implement… closed 2020-10-10… 2020-10-10… 2020-10-10…
#>  7 72494… 9     20384533   Implement… closed 2020-10-10… 2020-10-10… 2020-10-10…
#>  8 72494… 8     20384533   Implement… closed 2020-10-10… 2020-10-10… 2020-10-10…
#>  9 72492… 7     20384533   Implement… closed 2020-10-10… 2020-10-10… 2020-10-10…
#> 10 71869… 6     20384533   Implement… closed 2020-09-29… 2020-09-29… 2020-09-29…
#> 11 69721… 5     20384533   Implement… closed 2020-08-11… 2020-08-11… 2020-08-11…
#> 12 69721… 4     20384533   Implement… closed 2020-08-11… 2020-08-11… 2020-08-11…
#> 13 69721… 3     20384533   Implement… closed 2020-08-11… 2020-08-11… 2020-08-11…
#> 14 69525… 2     20384533   A second … opened 2020-08-06… 2020-08-06… <NA>       
#> 15 69525… 1     20384533   An exampl… opened 2020-08-06… 2020-08-06… <NA>       
#> # … with 46 more variables: closed_by.id <chr>, closed_by.name <chr>,
#> #   closed_by.username <chr>, closed_by.state <chr>,
#> #   closed_by.avatar_url <chr>, closed_by.web_url <chr>, assignees.id <chr>,
#> #   assignees.name <chr>, assignees.username <chr>, assignees.state <chr>,
#> #   assignees.avatar_url <chr>, assignees.web_url <chr>, author.id <chr>,
#> #   author.name <chr>, author.username <chr>, author.state <chr>,
#> #   author.avatar_url <chr>, author.web_url <chr>, type <chr>,
#> #   assignee.id <chr>, assignee.name <chr>, assignee.username <chr>,
#> #   assignee.state <chr>, assignee.avatar_url <chr>, assignee.web_url <chr>,
#> #   user_notes_count <chr>, merge_requests_count <chr>, upvotes <chr>,
#> #   downvotes <chr>, confidential <chr>, issue_type <chr>, web_url <chr>,
#> #   time_stats.time_estimate <chr>, time_stats.total_time_spent <chr>,
#> #   task_completion_status.count <chr>,
#> #   task_completion_status.completed_count <chr>, blocking_issues_count <chr>,
#> #   has_tasks <chr>, _links.self <chr>, _links.notes <chr>,
#> #   _links.award_emoji <chr>, _links.project <chr>, references.short <chr>,
#> #   references.relative <chr>, references.full <chr>, description <chr>
```

-   Create an issue

``` r
# create a new issue
new_feature_issue <- gl_new_issue(project = my_project, title = "Implement new feature")

# statnmap user ID
my_id <- 4809823

# assign issue to me
gl_assign_issue(project = my_project,
                issue_id = new_feature_issue$iid,
                assignee_id = my_id)
#> # A tibble: 1 x 47
#>   id     iid   project_id title    state  created_at   updated_at   assignees.id
#>   <chr>  <chr> <chr>      <chr>    <chr>  <chr>        <chr>        <chr>       
#> 1 87890… 16    20384533   Impleme… opened 2021-05-28T… 2021-05-28T… 4809823     
#> # … with 39 more variables: assignees.name <chr>, assignees.username <chr>,
#> #   assignees.state <chr>, assignees.avatar_url <chr>, assignees.web_url <chr>,
#> #   author.id <chr>, author.name <chr>, author.username <chr>,
#> #   author.state <chr>, author.avatar_url <chr>, author.web_url <chr>,
#> #   type <chr>, assignee.id <chr>, assignee.name <chr>,
#> #   assignee.username <chr>, assignee.state <chr>, assignee.avatar_url <chr>,
#> #   assignee.web_url <chr>, user_notes_count <chr>, merge_requests_count <chr>,
#> #   upvotes <chr>, downvotes <chr>, confidential <chr>, issue_type <chr>,
#> #   web_url <chr>, time_stats.time_estimate <chr>,
#> #   time_stats.total_time_spent <chr>, task_completion_status.count <chr>,
#> #   task_completion_status.completed_count <chr>, blocking_issues_count <chr>,
#> #   has_tasks <chr>, _links.self <chr>, _links.notes <chr>,
#> #   _links.award_emoji <chr>, _links.project <chr>, references.short <chr>,
#> #   references.relative <chr>, references.full <chr>, subscribed <chr>

# Verify new issue is here
gl_list_issues(project = my_project, state = "opened")
#> # A tibble: 3 x 47
#>   id     iid   project_id title      state  created_at  updated_at  assignees.id
#>   <chr>  <chr> <chr>      <chr>      <chr>  <chr>       <chr>       <chr>       
#> 1 87890… 16    20384533   Implement… opened 2021-05-28… 2021-05-28… 4809823     
#> 2 69525… 2     20384533   A second … opened 2020-08-06… 2020-08-06… <NA>        
#> 3 69525… 1     20384533   An exampl… opened 2020-08-06… 2020-08-06… <NA>        
#> # … with 39 more variables: assignees.name <chr>, assignees.username <chr>,
#> #   assignees.state <chr>, assignees.avatar_url <chr>, assignees.web_url <chr>,
#> #   author.id <chr>, author.name <chr>, author.username <chr>,
#> #   author.state <chr>, author.avatar_url <chr>, author.web_url <chr>,
#> #   type <chr>, assignee.id <chr>, assignee.name <chr>,
#> #   assignee.username <chr>, assignee.state <chr>, assignee.avatar_url <chr>,
#> #   assignee.web_url <chr>, user_notes_count <chr>, merge_requests_count <chr>,
#> #   upvotes <chr>, downvotes <chr>, confidential <chr>, issue_type <chr>,
#> #   web_url <chr>, time_stats.time_estimate <chr>,
#> #   time_stats.total_time_spent <chr>, task_completion_status.count <chr>,
#> #   task_completion_status.completed_count <chr>, blocking_issues_count <chr>,
#> #   has_tasks <chr>, _links.self <chr>, _links.notes <chr>,
#> #   _links.award_emoji <chr>, _links.project <chr>, references.short <chr>,
#> #   references.relative <chr>, references.full <chr>, description <chr>

# close issue
gl_close_issue(project = my_project, issue_id = new_feature_issue$iid)$state
#> [1] "closed"
```

### Use additionnal requests

If an API request is not already available in {gitlabr}, function
`gitlab()` allows to use any request of the GitLab API
\[<https://docs.gitlab.com/ce/api/>\].

For instance, the API documentation shows how to create a new project in
\[<https://docs.gitlab.com/ee/api/projects.html#create-project>\]:

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

## Further information

-   For a comprehensive overview & introduction see the
    `vignette("quick-start-guide-to-gitlabr")`
-   When writing custom extensions (“convenience functions”) for
    {gitlabr} or when you experience any trouble, the very extensive
    [GitLab API documentation](http://doc.gitlab.com/ce/api/) can be
    helpful.

# Contributing to {gitlabr}

You’re welcome to contribute to {gitlabr} by editing the source code,
adding more convenience functions, filing issues, etc.
[CONTRIBUTING.md](CONTRIBUTING.md) compiles some information helpful in
that process.

Please also note the [Code of Conduct](CONDUCT.md).
