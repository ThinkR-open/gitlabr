usethis::use_build_ignore("dev_history.R")
usethis::use_build_ignore("dev/")
usethis::use_build_ignore("README.Rmd")
usethis::use_build_ignore("tests/testthat/.gitlab-ci.yml")
usethis::use_git_ignore("tests/environment.yml")

# Add CI
usethis::use_github_action_check_standard()
usethis::use_github_action("pkgdown")

# Development
attachment::att_amend_desc(extra.suggests = "R.rsp")
devtools::test()
devtools::check()
