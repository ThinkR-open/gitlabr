usethis::use_build_ignore("dev_history.R")
usethis::use_build_ignore("dev/")
usethis::use_build_ignore("README.Rmd")
usethis::use_git_ignore("dev/environment.yml")
usethis::use_git_ignore("README_cache/")
usethis::use_build_ignore("README_cache/")
usethis::use_git_ignore("cran-comments.md")
usethis::use_git_ignore("pkgdown/")

# Doc
usethis::use_vignette("projects")
usethis::use_vignette("gitlabr-v2")
usethis::use_roxygen_md()
roxygen2md::roxygen2md()
usethis::use_code_of_conduct()

# Add CI
usethis::use_github_action("check-standard")
usethis::use_github_action("pkgdown")
usethis::use_github_action("test-coverage")
usethis::use_coverage()
usethis::use_github_action(url = "https://github.com/DavisVaughan/extrachecks-html5/blob/main/R-CMD-check-HTML5.yaml")

# Check pr ----
# To download a PR locally so that you can experiment with it, run pr_fetch(<pr_number>).
# If you make changes, run pr_push() to push them back to GitHub.
# After you have merged the PR, run pr_finish() to delete the local branch.
usethis::pr_fetch(24)
usethis::pr_push()

# Test pkgdown
pkgdown::check_pkgdown()
usethis::use_build_ignore("_pkgdown.yml")
usethis::use_git_ignore("public")
usethis::use_build_ignore("public/")
options(rmarkdown.html_vignette.check_title = FALSE)
pkgdown::build_site()

# Development ----
attachment::att_amend_desc(
  update.config = TRUE,
  extra.suggests = c("shiny", "DT"),
  pkg_ignore = c("shiny", "DT")
)
devtools::load_all()
devtools::test()
devtools::check()
devtools::check(args = c("--no-tests"))
devtools::build_vignettes()

# Deal with tests ----
devtools::load_all()
## load test environment variables
do.call(Sys.setenv, yaml::yaml.load_file("dev/environment.yml"))
devtools::test() ## run all tests
testthat::test_file("tests/testthat/test_files.R") ## run test on one file

# Checks for CRAN release ----

## Prepare for CRAN ----

# Check package coverage
covr::package_coverage()
covr::report()

# _Check in interactive test-inflate for templates and Addins
pkgload::load_all()
devtools::test()
testthat::test_dir("tests/testthat/")

# Run examples in interactive mode too
devtools::run_examples()

# Check package as CRAN
devtools::check(args = c("--no-manual", "--as-cran"))

# Check content
# install.packages('checkhelper', repos = 'https://thinkr-open.r-universe.dev')
checkhelper::find_missing_tags()

# _Check that you let the house clean after the check, examples and tests
all_files <- checkhelper::check_clean_userspace() # ok si ce qui reste c'est dans tmpdir()
all_files


# Check spelling
# usethis::use_spell_check()
spelling::spell_check_package() # regarder s'il y a des typos

# Check URL are correct - No redirection
# install.packages('urlchecker', repos = 'https://r-lib.r-universe.dev')
urlchecker::url_check()
urlchecker::url_update() # corrige les redirections


# Check as cran:
# probleme rencontre: cf https://github.com/ThinkR-open/checkhelper/issues/79
withr::with_options(list(repos = c(CRAN = "https://cran.rstudio.com")), {
  callr::default_repos()
  checkhelper::check_as_cran()
})
checkhelper::check_as_cran()


# check on other distributions
# _rhub v2
rhub::rhub_setup() # Commit, push, merge
rhub::rhub_doctor()
rhub::rhub_platforms()
rhub::rhub_check() # launch manually

# _win devel CRAN
devtools::check_win_devel()
# _win release CRAN
devtools::check_win_release()
# _macos CRAN
# Need to follow the URL proposed to see the results
devtools::check_mac_release()

# Check reverse dependencies
# remotes::install_github("r-lib/revdepcheck")
usethis::use_git_ignore("revdep/")
usethis::use_build_ignore("revdep/")

devtools::revdep()
library(revdepcheck)
# In another session
id <- rstudioapi::terminalExecute("Rscript -e 'revdepcheck::revdep_check(num_workers = 4)'")
rstudioapi::terminalKill(id)
# See outputs
revdep_details(revdep = "pkg")
revdep_summary() # table of results by package
revdep_report() # in revdep/
# Clean up when on CRAN
revdep_reset()

# Update NEWS
# Bump version manually and add list of changes

# Upgrade version number
usethis::use_version(which = c("patch", "minor", "major", "dev")[2])

# Add comments for CRAN
# Need to .gitignore this file
usethis::use_cran_comments(open = rlang::is_interactive())
# Why we have `\dontrun{}`

usethis::use_git_ignore("cran-comments.md")
usethis::use_git_ignore("CRAN-SUBMISSION")

# Verify you're ready for release, and release
devtools::release()


# Thanks for article
library(purrr)
repos <- gh::gh("/repos/ThinkR-open/gitlabr/stats/contributors")
map(repos, "author") %>% map("login")

map_chr(repos, ~ paste0(
  # "[&#x0040;",
  "[",
  pluck(.x, "author", "login"),
  "](",
  pluck(.x, "author", "html_url"),
  ")"
)) %>%
  glue::glue_collapse(sep = ", ", last = " and ")
