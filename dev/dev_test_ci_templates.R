# Template for package testing ----

devtools::load_all()
# >> Create a GitLab project
set_gitlab_connection(
  gitlab_url = test_url,
  private_token = test_private_token,
  api_version = test_api_version
)
test_pkg_gitlab <- gitlabr::gl_new_project(name = "test-pkg-ci")
# >> Create a local package
temp_pkg <- tempfile("test.ci.pkgfusen")
fusen::create_fusen(
  path = temp_pkg, template = "full",
  open = FALSE, with_git = TRUE
)
usethis::with_project(temp_pkg, {
  fusen::fill_description(
    pkg = temp_pkg,
    fields = list(Title = "Dummy Package")
  )
  usethis::use_mit_license()
  fusen::inflate(flat_file = "dev/flat_full.Rmd", open_vignette = FALSE)
})
# >> Add gitlab-ci & Commit
usethis::with_project(temp_pkg, {
  use_gitlab_ci(type = "check-coverage-pkgdown")
  gert::git_add(".")
  gert::git_commit_all("Add gitlab-ci")
  gert::git_remote_add(
    test_pkg_gitlab$http_url_to_repo,
    name = "origin"
  )
})
# >> Push
gert::git_push(repo = temp_pkg)
# In VSCode password prompt is on top of the window
# >>> If push does not work directly the first time,
# run output in Terminal:
glue::glue("cd {temp_pkg}")
# Then
# git push -u origin main

# >> Check the CI on GitLab - You may need to activate it manually

# >> Modify the CI file and push again if needed
pkgload::load_all()
usethis::with_project(temp_pkg, {
  # Add gitlab-ci
  use_gitlab_ci(type = "check-coverage-pkgdown")
  gert::git_add(".")
  gert::git_commit_all("Add gitlab-ci again")
  gert::git_push()
})

# Test templates are up-to-date
testthat::test_file("tests/testthat/test_ci.R")
# _ Delete the project
gl_delete_project(test_pkg_gitlab$id)
unlink(temp_pkg, recursive = TRUE)
usethis::proj_set(path = ".", force = FALSE)

# Template for bookdown testing ----

devtools::load_all()
# >> Create a GitLab project
set_gitlab_connection(
  gitlab_url = test_url,
  private_token = test_private_token,
  api_version = test_api_version
)
test_book_gitlab <- gitlabr::gl_new_project(name = "test-book-ci")

# >> Create a book
temp_book <- tempfile("test.ci.book")
bookdown::create_bs4_book(temp_book)

# >> Start git, add gitlab-ci & Commit
withr::with_dir(temp_book, {
  gert::git_init()
  use_gitlab_ci(type = "bookdown")
  gert::git_add(".")
  gert::git_commit_all("Add gitlab-ci")
  gert::git_remote_add(
    test_book_gitlab$http_url_to_repo,
    name = "origin"
  )
})
# >> Push
gert::git_push(repo = temp_book)
# In VSCode password prompt is on top of the window
# >>> If push does not work directly the first time,
# run output in Terminal:
glue::glue("cd {temp_book}")
# Then
# git push -u origin main

# >> Check the CI on GitLab - You may need to activate it manually

# >> Modify the CI file and push again if needed
pkgload::load_all()
usethis::with_project(temp_book, {
  # Add gitlab-ci
  use_gitlab_ci(type = "bookdown")
  gert::git_add(".")
  gert::git_commit_all("Add gitlab-ci again")
  gert::git_push()
})

# Test templates are up-to-date
testthat::test_file("tests/testthat/test_ci.R")
# _ Delete the project
gl_delete_project(test_pkg_gitlab$id)
unlink(temp_book, recursive = TRUE)
