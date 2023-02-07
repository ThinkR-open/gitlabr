# Contributing to {gitlabr}

You're welcome to contribute to {gitlabr} by editing the source code, adding more convenience functions, filing issues, etc. This document compiles some information helpful in that process.

Please also note the [Code of Conduct](CONDUCT.md).


## Setup a development environment

The {gitlabr} test suite expects certain entities (user, project, files, comments) to be present in the test server. 
Below are the guidelines to setup a GitLab instance and the local file `dev/environment.yml`. 
Note that <https://gitlab.com/statnmap/testor.main> was created following these guidelines. 


1. Install & make GitLab instance reachable at a certain address. The easiest ways are to use either a Docker image of the GitLab version of interest or directly use <https://gitlab.com>. 

2. Create a file named `environment.yml` and save it in the `dev/` directory of your clone of {gitlabr}.
  + See `environment.yml.example` as the template to fill as follows

3. Create a user on your GitLab instance
  + Add your username in `environment.yml` as `GITLABR_TEST_LOGIN`
  + Add your user ID in `environment.yml` as `GITLABR_TEST_LOGIN_ID` (numeric)
    + Go to your profile (e.g. https://gitlab.com/profile) and look up for your User ID
  + Add your user password in `environment.yml` as `GITLABR_TEST_PASSWORD`
  
4. Generate a private access token for the user that grants all read/write access to the  API 
  + For instance on gitlab.com: https://gitlab.com/profile/personal_access_tokens
  + Tick the fist checkboxes (the `api` scope) 
  + Add the token in the `environment.yml` or environment variables as "GITLABR_TEST_TOKEN"
  
  
**=> From now on, you can use "dev/create_testor_on_gitlab.R" script to automate required repository content for steps 5 - 11.**
  
  
5. Create a project called `testor`, owned by the user, and containing a `README.md` file
  + New Project > Initialize with a README
  + be sure that the main branch is called `main`
  + Add the project name in the `environment.yml` as variable named "GITLABR_TEST_PROJECT_NAME"

6. Get the ID of the project and add it in `environment.yml` as variable named "GITLABR_TEST_PROJECT_ID"
  + Project Overview > Details
  + The Project ID is under the name of your project
  
7. Add/modify and commit the `README.md`:
```md
# testor

Repository to test R package [{gitlabr}](https://github.com/ThinkR-open/gitlabr)
```

8. Go to Repository > Branches and create a branch named "for-tests".


9. Add and commit a CI file (`.gitlab-ci.yml`) in the main/master branch that includes a job named `testing` that should minimally create `public/test.txt` as an artifact, we recommend using the following `.gitlab-ci.yml` file:

```yaml 
testing:
  script: echo 'test 1 2 1 2' > 'test.txt'
  artifacts:
    paths:
      - test.txt
```

10. Create a commit (or use the commit just created), add a follow-up comment and add its 40-character SHA-1 hash in the `environment.yml` as variable named 'COMMENTED_COMMIT', to do so:
  + Go to Repository > Commits
  + Copy the <SHA1> of the relevant commit 
  + Click on the relevant commit 
  + Write a comment 
  + Add its <sha1> in 'COMMENTED_COMMIT' in `environment.yml`
  
11. Create a first issue (#1) with a follow-up comment
  + Go to Issues > List > New issue
  + Add a title and a description for the issue then click on `Submit issue`
  + Then add a follow-up comment to this issue


 
### How to run the test suite

When the test server is set up as described above, tests can be run with the following R code that loads the recorded environment variables and runs the test code:

```{r}
devtools::load_all()
do.call(Sys.setenv, yaml::yaml.load_file("dev/environment.yml")) ## load test environment variables
devtools::test() ## run all tests
testthat::test_file("tests/testthat/test_ci.R") ## run test on one file
```


### How to check the package with GitHub Actions on your own fork

For GitHub users, it is possible to directly use [GitHub Actions](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions) to test whether the package can be build smoothly before creating a PR. To do so, they should add the following environmental variables (the ones listed in `environment.yml`) as [encrypted secrets](https://docs.github.com/en/free-pro-team@latest/actions/reference/encrypted-secrets),

- GITLABR_TEST_LOGIN
- GITLABR_TEST_LOGIN_ID
- GITLABR_TEST_PASSWORD
- GITLABR_TEST_TOKEN
- GITLABR_TEST_URL

Also, another encrypted secrets named `REPO_GHA_PAT` is required, it should include a 
[personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) that has access to your GitHub repositories.

Note that the current GitHub Actions use different projects to test OS separately, in parallel.
This means the following environmental variables will not work with your fork:

- GITLABR_TEST_PROJECT_ID
- GITLABR_TEST_PROJECT_NAME
- COMMENTED_COMMIT

This value are directly set in the core of the action. If you really want to run GitHub Actions on your own fork before opening a PR, you can run "dev/create_testor_on_gitlab.R" to create the different CI repositories and modify the matrix of configuration in the corresponding CI configuration file.  
However, you will need to put back original values to open a PR.  

<!--
You may need to temporarily modify the Actions OS matrix to fit your needs. 
I recommend to keep only one OS tested to avoid unit tests to be run in parallel on the same repository.
To do so, you can comment all but one OS in ".github/workflows/R-CMD-check.yaml", and change the values of the variable according to your configuration.
-->


### API version

The test suite is intended for use with GitLab API v4, compatibility with API v3 is no longer maintained. Still, you can switch to run the tests against API v3, by setting the environment variable `GITLABR_TEST_API_VERSION` to value `3`. Note that API v3 is not present in recent GitLab versions!

### API limitation

Note that GitLab.com has some limitations : https://docs.gitlab.com/ee/user/gitlab_com/index.html#gitlabcom-specific-rate-limits
Authenticated API traffic (for a given user) [From 2021-02-12]: 2,000 requests per minute 
