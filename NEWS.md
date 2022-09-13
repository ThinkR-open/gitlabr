# gitlabr 2.0.1

New features

* Connection now uses the token as "header" instead of being sent clearly in the URL (#66, @ei-ds) 
* `gl_list_group_projects()` lists projects of a group (@Yoshinobu-Ishizaki)

Minor changes

* doc HTML5 re-created with last version of roxygen2

# gitlabr 2.0.0

Breaking changes

* Default branch is named `main` whenever required.
  + This can be changed with `gitlabr_options_set("gitlabr.main", "master")`
* All project-specific functions get `project` as first parameter. Changes apply to:
  + `gl_get_comments()`,`gl_to_issue_id()`, `gl_get_issue_comments()`, `gl_get_commit_comments()`,
  `gl_edit_comment()`, `gl_edit_issue_comment()`, `gl_edit_commit_comment()`
  + `gl_repository()`
  + `gl_get_issue()`, `gl_to_issue_id()`, `gl_new_issue()`, `gl_create_issue()`, `gl_edit_issue()`, `gl_close_issue()`,
  `gl_reopen_issue()`, `gl_assign_issue()`, `gl_unassign_issue()`
* Changed use of `api_version = "v4"` by `api_version = 4`
* Changed use of `force_api_v3 = TRUE` by `api_version = 4` for deprecation by default

Major

* New use of `use_gitlab_ci()` with pre-defined templates
* Add new functions to manage projects: `gl_get_project()`, `gl_new_project()`, `gl_edit_project()`,
 `gl_delete_project()`
* Update documentation: recommend using `gl_*` functions

Minor

* `gl_archive()` is used to archive a project (not to download an archive)
* fix use of `max_page` with `gl_()` functions calling `gitlab()`
* Correction of api that downloaded twice the first page when `page == "all"`
* Reduce `max_page` in examples and tests to retrieve content to allow to work with big GitLab servers like Gitlab.com
* Change maintainer
* Update CONTRIBUTING for tests with Gitlab.com
* `update_gitlabr_code()` removed


# gitlabr 1.1.6

* `gl_create_issue` is introduced as new alias for `gl_new_issue`
* tests are migrated and adapted to test server https://test-gitlab.points-of-interest.cc and to gitlab version 11.6. More specifically a private access tokens is used and login via username and password is no longer possible.

# gitlabr 0.9 (2017-04-24)

* Support for Gitlab API v4 (default from Gitlab version 9.0 onward) was added. Gitlab API v4 is now the default used by gitlabr, but using the old API (v3) is still possible, see details section "API version" of the documentation of `gl_connection`.
  * Several convenience functions now have a `force_api_v3` parameter to force old API version logic.
  * Issues are now identified by project-wide id and not global iid, according to API v4 logic.
  * Function `gl_builds` was replaced by `gl_pipelines` and `gl_jobs` to reflect API v4 logic.
* `push_to_remotes` parameter was added to `use_gitlab_ci` such that gitlab CI can be used conveniently for pushing to remote repositories.
* Examples were added to almost all function reference pages.
* In case of Server Error (HTTP Status 5xx), gitlabr now performs up to 3 retries, waiting 25 seconds in between. This is mostly to catch errors due to slow server responses, when the packages test suite is run.


# gitlabr 0.8

*There is no gitlabr 0.8. Version number 0.9 was used to align with Gitlab version 9.0, for which this version is appropriate.*

# gitlabr 0.7 (2017-03-06)

* All functions were renamed to a new scheme starting with "gl_"
* A shiny module with gitlab login was added
* CI access functions were added
* Added a `NEWS.md` file to track changes to the package.



