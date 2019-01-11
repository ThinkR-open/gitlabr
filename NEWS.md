# gitlabr 1.1.6

* `gl_create_issue` is introduced as new alias for `gl_new_issue`
* tests are migrated and adapated to test server https://test-gitlab.points-of-interest.cc and to gitlab version 11.6. More specifically a private access tokens is used and login via username and password is no longer possible.

# gitlabr 0.9 (2017-04-24)

* Support for Gitlab API v4 (default from Gitlab version 9.0 onwards) was added. Gitlab API v4 is now the default used by gitlabr, but using the old API (v3) is still possible, see details section "API version" of the documentation of `gl_connection`.
  * Several convenience functions now have a `force_api_v3` parameter to force old API version logic.
  * Issues are now identified by project-wide id and not global iid, according to API v4 logic.
  * Function `gl_builds` was replaced by `gl_pipelines` and `gl_jobs` to reflect API v4 logic.
* `push_to_remotes` parameter was added to `use_gitlab_ci` such that gitlab CI can be used conveniently for pushing to remote repositories.
* Examples were added to almost all function reference pages.
* In case of Server Error (HTTP Status 5xx), gitlabr now performs up to 3 retries, waiting 25 secondes in between. This is mostly to catch errors due to slow server responses, when the packages test suite is run.


# gitlabr 0.8

*There is no gitlabr 0.8. Version number 0.9 was used to align with Gitlab version 9.0, for which this version is appropriate.*

# gitlabr 0.7 (2017-03-06)

* All functions were renamed to a new scheme starting with "gl_"
* A shiny module with gitlab login was added
* CI access functions were added
* Added a `NEWS.md` file to track changes to the package.



