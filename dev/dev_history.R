usethis::use_build_ignore("dev_history.R")
usethis::use_build_ignore("dev/")
usethis::use_build_ignore("README.Rmd")
usethis::use_git_ignore("tests/environment.yml")
usethis::use_git_ignore("README_cache/")
usethis::use_build_ignore("README_cache/")

# Doc
usethis::use_vignette("projects")
usethis::use_vignette("gitlabr-v2")
usethis::use_roxygen_md()
roxygen2md::roxygen2md()

# Add CI
usethis::use_github_action_check_standard()
usethis::use_github_action("pkgdown")
usethis::use_github_action("test-coverage")
usethis::use_coverage()

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

# Development ----
attachment::att_amend_desc() #extra.suggests = "glue")
devtools::load_all()
devtools::test()
devtools::check() # /!\ Tests are currently skip /!\
devtools::build_vignettes()


# Prepare for CRAN ----
usethis::use_release_issue()
# Test no output generated in the user files
# pkgload::load_all(export_all = FALSE)
# remotes::install_github("ropensci-review-tools/autotest")
# debugonce(autotest:::rm_not_parseable)

local <- utils::fileSnapshot (".", timestamp = tempfile("timestamp"), md5sum = TRUE)
home <- utils::fileSnapshot ("~", timestamp = tempfile("timestamp"), md5sum = TRUE)

# run tests or whatever, then ...
# x <- autotest::autotest_package(test = TRUE)
devtools::test()
devtools::run_examples()
# vignettes
dircheck <- tempfile("check")
dir.create(dircheck)
rcmdcheck::rcmdcheck(check_dir = dircheck)
# browseURL(dircheck)

the_dir <- list.files(file.path(dircheck), pattern = ".Rcheck", full.names = TRUE)
# Same tests, no new files
all(list.files(file.path(the_dir, "tests", "testthat")) %in%
      list.files(file.path(".", "tests", "testthat")))

devtools::build_vignettes()
devtools::clean_vignettes()

utils::changedFiles(local, md5sum = TRUE)
utils::changedFiles(home, md5sum = TRUE)

DT::datatable(x)

# Check package as CRAN
rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))

# Check content
# remotes::install_github("ThinkR-open/checkhelper")
tags <- checkhelper::find_missing_tags()
View(tags)

# Check spelling
# usethis::use_spell_check()
spelling::spell_check_package()

# Check URL are correct
# remotes::install_github("r-lib/urlchecker")
urlchecker::url_check()
urlchecker::url_update()

# check on other distributions
# _rhub
devtools::check_rhub()
rhub::check_on_windows(check_args = "--force-multiarch")
rhub::check_on_solaris()
rhub::check(platform = "debian-clang-devel")
rhub::check_for_cran()

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


rhub::check(platform = "windows-x86_64-devel")

# _win devel
devtools::check_win_devel()
devtools::check_win_release()

# Update NEWS
# Bump version manually and add list of changes

# Add comments for CRAN
usethis::use_cran_comments(open = rlang::is_interactive())

# Upgrade version number
usethis::use_version(which = c("patch", "minor", "major", "dev")[1])

# Verify you're ready for release, and release
devtools::release()


