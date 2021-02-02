# Contributing to {gitlabr}

You're welcome to contribute to {gitlabr} by editing the source code, adding more convenience functions, filing issues, etc. This document compiles some information helpful in that process.

Please also note the [Code of Conduct](CONDUCT.md).


## Setup a development environment

The {gitlabr} test suite expects certain entities (user, project, files, comments) to be present in the test server. 
Below are the guidelines to setup a GitLab instance and the local file `tests/environment.yml`. 
Note that <https://gitlab.com/KevCaz/testor> was created following these guidelines. 


1. Install & make GitLab instance reachable at a certain address. The easiest ways are to use either a Docker image of the GitLab version of interest or directly use <https://gitlab.com>. 

2. Create a file named `environment.yml` and save it in the `tests/` directory of your clone of {gitlabr}.
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
  
5. Create a project called `testor`, owned by the user, and containing a `README.md` file
  + New Project > Initialize with a README
  + Add this name in the `environment.yml` as variable named "GITLABR_TEST_PROJECT_NAME"
  
6. Get the ID of the project and add it in `environment.yml` as variable named "GITLABR_TEST_PROJECT_ID"
  + Project Overview > Details
  + The Project ID is under the name of your project
  
7. Add and commit a CI file (`.gitlab-ci.yml`) that includes a job named `testing` that should minimally create `public/test.txt` as an artifact, we recommend using the following `.gitlab-ci.yml` file:

```yaml 
testing:
  script: echo 'test 1 2 1 2' > 'test.txt'
  artifacts:
    paths:
      - test.txt
```

8. Create a commit (or use the commit just created), add a follow-up comment and add its 40-character SHA-1 hash in the `environment.yml` as variable named 'COMMENTED_COMMIT', to do so:
  + Go to Repository > Commits
  + Copy the <SHA1> of the relevant commit 
  + Click on the relevant commit 
  + Write a comment 
  
9. Create a first issue (#1) with a follow-up comment
  + Go to Issues > List > New issue
  + Add a title and a description for the issue then click on `Submit issue`
  + Then add a follow-up comment to this issue

10. Go to Repository > Branches and create a branch named "for-tests".



  
### How to run the test suite

When the test server is set up as described above, tests can be run with the following R code that loads the recorded environment variables and runs the test code:

```{r}
devtools::load_all()
do.call(Sys.setenv, yaml::yaml.load_file("tests/environment.yml")) ## load test environment variables
devtools::test() ## run all tests
testthat::test_file("tests/testthat/test_ci.R") ## run test on one file
```


### How to check the package with GitHub Actions on your own fork

For GitHub users, it is possible to directly use [GitHub Actions](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions) to test whether the package can be build smoothly before creating a PR. To do so, they should add the following environmental variables (the ones listed in `environment.yml`) as [encrypted secrets](https://docs.github.com/en/free-pro-team@latest/actions/reference/encrypted-secrets),

- COMMENTED_COMMIT
- GITLABR_TEST_LOGIN
- GITLABR_TEST_LOGIN_ID
- GITLABR_TEST_PASSWORD
- GITLABR_TEST_PROJECT_ID
- GITLABR_TEST_PROJECT_NAME
- GITLABR_TEST_TOKEN
- GITLABR_TEST_URL

Also, another encrypted secrets named `REPO_GHA_PAT` is required, it should include a 
[personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) that has access to your GitHub repositories.





### API version

The test suite is intended for use with GitLab API v4, compatibility with API v3 is no longer maintained. Still, you can switch to run the tests against API v3, by setting the environment variable `GITLABR_TEST_API_VERSION` to value `3`. Note that API v3 is not present in recent GitLab versions!
