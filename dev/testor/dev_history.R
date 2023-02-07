usethis::use_build_ignore("dev_history.R")
usethis::use_gitlab_ci()
usethis::use_build_ignore(".gitlab-ci.yml")
usethis::use_gpl3_license()

usethis::use_r("fake_fun")

attachment::att_amend_desc()

covr::gitlab(quiet = FALSE)
