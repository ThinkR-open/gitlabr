pkgload::load_all()

# Define main branch (currently gitlab is only for "main" by default in unit tests)
main_branch <- get_main()
if (main_branch != "main") {
  stop("For unit tests, only 'main' should be the main branch of the project")
}

# Set connection
set_gitlab_connection(
  gitlab_url = "https://gitlab.com",
  private_token = Sys.getenv("GITLAB_COM_TOKEN")
)

# 5. Create a project called `testor`, owned by the user
project_info <- gl_new_project(name = "testor.macos", 
                               default_branch = main_branch,
                               initialize_with_readme = TRUE)

# Verify branches
all_branches <- gl_list_branches(project = project_info$id)
if (all_branches$name == "master") {
  message("Change from master to main for tests")
  
  gl_create_branch(project = project_info$id, branch = "main", ref = "master")
  gl_edit_project(project = project_info$id, default_branch = "main") # Change default_branch = "main"
  gl_delete_branch(project = project_info$id, branch = "master")
  # Verify
  project_info <- gl_get_project(test_project)
  testthat::expect_equal(project_info$default_branch, "main")
}

# browseURL(project_info$web_url)

# 6. Get the ID of the project
message("Add variable in your tests/environment.yml: GITLABR_TEST_PROJECT_NAME: ", project_info$name)
message("Add variable in your tests/environment.yml: GITLABR_TEST_PROJECT_ID: ", project_info$id)

# 7. Add/modify and commit the `README.md`:
content_md <- paste("
# testor

Repository to test R package [{gitlabr}](https://github.com/statnmap/gitlabr)
")

gl_push_file(
  project = project_info$id,
  file_path = "README.md",
  content = content_md,
  commit_message = "Update README",
  branch = main_branch,
  overwrite = TRUE)

# 8. Go to Repository > Branches and create a branch named "for-tests".
gl_create_branch(project = project_info$id, branch = "for-tests", ref = main_branch)
# gl_list_branches(project = project_info$id)

# 9. Add and commit a CI file (`.gitlab-ci.yml`)
content_ci <- paste("
testing:
  script: echo 'test 1 2 1 2' > 'test.txt'
  artifacts:
    paths:
      - test.txt
")

gl_push_file(
  project = project_info$id,
  file_path = ".gitlab-ci.yml",
  content = content_ci,
  commit_message = "Add CI to the main branch",
  branch = main_branch,
  overwrite = TRUE)

# 10. Create a commit (or use the commit just created), add a follow-up comment
commits_in_main <- gl_get_commits(project = project_info$id, ref_name = "main")
gl_comment_commit(project = project_info$id, 
                  id = commits_in_main$id[1], 
                  text = "Write a comment")

message("Add variable in tests/environment.yml: COMMENTED_COMMIT: ", comment_infos = commits_in_main$id[1])

# 11. Create a first issue (#1) with a follow-up comment
issue_info <- gl_create_issue(project = project_info$id, title = "Dont close issue 1", description = "An example issue to not close for tests")
gl_comment_issue(project = project_info$id, id = issue_info$iid, text = "A comment on issue to not close")

# Remind environment variables to add in "tests/environment.yml"
message("Add variable in your tests/environment.yml: GITLABR_TEST_PROJECT_NAME: ", project_info$name)
message("Add variable in your tests/environment.yml: GITLABR_TEST_PROJECT_ID: ", project_info$id)
message("Add variable in your tests/environment.yml: COMMENTED_COMMIT: ", comment_infos = commits_in_main$id[1])

# Unset connection
unset_gitlab_connection()
