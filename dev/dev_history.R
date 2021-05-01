usethis::use_build_ignore("dev_history.R")
usethis::use_build_ignore("dev/")
usethis::use_build_ignore("README.Rmd")
usethis::use_git_ignore("tests/environment.yml")

# Doc
usethis::use_vignette("projects")
usethis::use_roxygen_md()
roxygen2md::roxygen2md()

# Add CI
usethis::use_github_action_check_standard()
usethis::use_github_action("pkgdown")
usethis::use_github_action("test-coverage")

# Check pr
# To download a PR locally so that you can experiment with it, run pr_fetch(<pr_number>). 
# If you make changes, run pr_push() to push them back to GitHub. 
# After you have merged the PR, run pr_finish() to delete the local branch.
usethis::pr_fetch(24)
usethis::pr_push()

# Test pkgdown
usethis::use_build_ignore("_pkgdown.yml")
usethis::use_git_ignore("public")
usethis::use_build_ignore("public/")
options(rmarkdown.html_vignette.check_title = FALSE)
pkgdown::build_site()

# Development
attachment::att_amend_desc() #extra.suggests = "R.rsp")
devtools::load_all()
devtools::test()
devtools::check() # /!\ Tests are currently skip /!\
devtools::build_vignettes()
