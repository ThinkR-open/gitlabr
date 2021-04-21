single_list <- list(id = 301L, description = NULL, name = "theproject", name_with_namespace = "thegroup / theproject", 
     path = "theproject", path_with_namespace = "thegroup/theproject", 
     created_at = "2021-04-20T12:25:29.283Z", default_branch = NULL, 
     tag_list = list(), ssh_url_to_repo = "ssh://git@gitlab.com/thegroup/theproject.git", 
     http_url_to_repo = "https://gitlab.com/thegroup/theproject.git", 
     web_url = "https://gitlab.com/thegroup/theproject", readme_url = NULL, 
     avatar_url = NULL, forks_count = 0L, star_count = 0L, last_activity_at = "2021-04-20T12:25:29.283Z", 
     namespace = list(id = 3L, name = "thegroup", path = "thegroup", 
                      kind = "group", full_path = "thegroup", parent_id = NULL, 
                      avatar_url = NULL, web_url = "https://gitlab.com/groups/thegroup"), 
     `_links` = list(self = "https://gitlab.com/api/v4/projects/301", 
                     issues = "https://gitlab.com/api/v4/projects/301/issues", 
                     merge_requests = "https://gitlab.com/api/v4/projects/301/merge_requests", 
                     repo_branches = "https://gitlab.com/api/v4/projects/301/repository/branches", 
                     labels = "https://gitlab.com/api/v4/projects/301/labels", 
                     events = "https://gitlab.com/api/v4/projects/301/events", 
                     members = "https://gitlab.com/api/v4/projects/301/members"), 
     packages_enabled = TRUE, empty_repo = TRUE, archived = FALSE, 
     visibility = "private", resolve_outdated_diff_discussions = FALSE, 
     container_registry_enabled = TRUE, container_expiration_policy = list(
       cadence = "1d", enabled = TRUE, keep_n = 10L, older_than = "90d", 
       name_regex = NULL, name_regex_keep = NULL, next_run_at = "2021-04-21T12:25:29.298Z"), 
     issues_enabled = TRUE, merge_requests_enabled = TRUE, wiki_enabled = TRUE, 
     jobs_enabled = TRUE, snippets_enabled = TRUE, service_desk_enabled = FALSE, 
     service_desk_address = NULL, can_create_merge_request_in = TRUE, 
     issues_access_level = "enabled", repository_access_level = "enabled", 
     merge_requests_access_level = "enabled", forking_access_level = "enabled", 
     wiki_access_level = "enabled", builds_access_level = "enabled", 
     snippets_access_level = "enabled", pages_access_level = "private", 
     emails_disabled = NULL, shared_runners_enabled = TRUE, lfs_enabled = TRUE, 
     creator_id = 6L, import_status = "none", import_error = NULL, 
     open_issues_count = 0L, runners_token = "gFZwfULZda5VgT7kJCEB", 
     ci_default_git_depth = 50L, public_jobs = TRUE, build_git_strategy = "fetch", 
     build_timeout = 3600L, auto_cancel_pending_pipelines = "enabled", 
     build_coverage_regex = NULL, ci_config_path = NULL, shared_with_groups = list(), 
     only_allow_merge_if_pipeline_succeeds = FALSE, allow_merge_on_skipped_pipeline = NULL, 
     request_access_enabled = TRUE, only_allow_merge_if_all_discussions_are_resolved = FALSE, 
     remove_source_branch_after_merge = TRUE, printing_merge_request_link_enabled = TRUE, 
     merge_method = "merge", suggestion_commit_message = NULL, 
     auto_devops_enabled = TRUE, auto_devops_deploy_strategy = "continuous", 
     autoclose_referenced_issues = TRUE, repository_storage = "default", 
     permissions = list(project_access = NULL, group_access = list(
       access_level = 50L, notification_level = 3L)))


test_that("is_single_row works in this case", {
  expect_true(gitlabr:::is_single_row(single_list))
})

# test that it works for a single project
project_info <- gitlab(req = paste0("projects/", test_project_id),
                       verb = httr::GET)

