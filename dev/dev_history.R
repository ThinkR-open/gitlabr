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
devtools::check() # /!\ Tests are currently skip if no token in "dev/environment.yml"/!\
devtools::build_vignettes()

# Deal with tests ----
devtools::load_all()
do.call(Sys.setenv, yaml::yaml.load_file("dev/environment.yml")) ## load test environment variables
devtools::test() ## run all tests
testthat::test_file("tests/testthat/test_files.R") ## run test on one file

# Prepare for CRAN ----
usethis::use_release_issue()
# Test no output generated in the user files
# pkgload::load_all(export_all = FALSE)
# remotes::install_github("ropensci-review-tools/autotest")
# debugonce(autotest:::rm_not_parseable)



# Check package as CRAN
rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))

# Check content
# install.packages('checkhelper', repos = 'https://thinkr-open.r-universe.dev')
tags <- checkhelper::find_missing_tags()
View(tags)
# Check that the state is clean after check
all_files <- checkhelper::check_clean_userspace()
all_files
checkhelper::check_as_cran()

# Check spelling
# usethis::use_spell_check()
spelling::spell_check_package()

# Check URL are correct
# install.packages('urlchecker', repos = 'https://r-lib.r-universe.dev')
urlchecker::url_check()
urlchecker::url_update()

# check on other distributions

# /!\ Do not send tests/environment.yml to CRAN /!\
# There are now in "dev/", and are not sent to CRAN

# _rhub

devtools::check_rhub()
rhub::check_on_windows(check_args = "--force-multiarch")
rhub::check_on_solaris(show_status = FALSE)
rhub::check(platform = "debian-clang-devel")
rhub::check_for_cran(show_status = FALSE)

# Run locally in Docker
# docker pull rhub/debian-clang-devel
# docker run -ti rhub/debian-clang-devel bash
# docker run -v /mnt/Data/github/ThinkR-open/fusen:/home/root/toto -ti rhub/debian-clang-devel bash
# debugonce(rhub::local_check_linux)
rhub::local_check_linux(image = "rhub/debian-clang-devel")
# a55df815-38f2-4854-a3bc-29cdcac878cc-2

rstudioapi::navigateToFile(system.file(package = "rhub", "bin", "rhub-linux-docker.sh"))
# docker container start -i 7181196d-bc3c-4fc8-a0e8-dc511150335d-2
# docker exec -it 7181196d-bc3c-4fc8-a0e8-dc511150335d-2 bash
# https://www.thorsten-hans.com/how-to-run-commands-in-stopped-docker-containers/
# /opt/R-devel/bin/R


rhub::check(platform = "windows-x86_64-devel", show_status = FALSE)

# _win devel
devtools::check_win_devel()
devtools::check_win_release()
devtools::check_mac_release()

# /!\ Do not send tests/environment.yml to CRAN /!\
# There are now in "dev/", and are not sent to CRAN

# Update NEWS
# Bump version manually and add list of changes

# Add comments for CRAN
usethis::use_cran_comments(open = rlang::is_interactive())

# Upgrade version number
usethis::use_version(which = c("patch", "minor", "major", "dev")[1])

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
