# Contributing to gitlabr

You're welcome to contribute to gitlabr by editing the source code, adding more convenience functions, filing issues, etc. This document compiles some information helpful in that process.

Please also note the [Code of Conduct](CONDUCT.md).


## Setup a local development environment

If you want to run the test suite locally, you need to setup a a Gitlab instance for testing. Then, in the file `tests/environment.yml` configuration variables are recorded about how to connect to the gitlab instance. [tests/environment.yml.example](tests/environment.yml.example) contains an example configuration for a server that is, however, not publicly available for a testing.

## How to create a test server

The gitlab test suite expects certain entities (user, project, files) to be present in the test server. Here is how to setup a test server:

- install & make gitlab instance reachable at a certain address (The easiest way is the to use the a docker image of the gitlab version of interest.)
- create a user
- generate a private access token for the user
- note the server, user and access token in the environment.yml or environment variables
- create a project called `testor`, owned by the user `testuser`, and containing a README.md file
- give it a CI file that writes to a "test.txt" file
- create an issue #1 with a comment
- comment on a commit and note its SHA1 in the environment.yml as variable named 'COMMENTED_COMMIT'
- do not create more than 100 users

### How to run the test suite

When the test server is set up as described above tests can be run with the following R code that loads the recorded environment variables and runs the test code:

```{r}
library(devtools)
library(yaml)
do.call(Sys.setenv, yaml.load_file("tests/environment.yml")) ## load test environment variables
test() ## run tests
```

### API version

The test suite is intended for use with Gitlab API v4, compatibility with API v3 is no longer maintained. Still, you can switch to run the tests against API v3, by setting the environment variable `GITLABR_TEST_API_VERSION` to value `v3`. Note that API v3 is not present in recent gitlab versions!
