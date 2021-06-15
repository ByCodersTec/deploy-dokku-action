# Custom dokku deploy for GitHub Actions (BYCODERS)

Deploy an application to bycoders dokku server over SSH.

## Usage

To use the action add the following lines to your `.github/workflows/main.yml`

```yaml
name: deploy

on: pull_request

jobs:
  deploy:
    runs-on: ubuntu-18.04
    steps:
      - uses: actions/checkout@v1
      - name: Deploy the application
        uses: ByCodersTec/deploy-dokku-action@main
        with:
          PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          PUBLIC_KEY: ${{ secrets.SSH_PUBLIC_KEY }}
          HOST: ${{ secrets.DOKKU_HOST }}
          PROJECT: project-name
          BRANCH: ${{ github.head_ref }}
          PROJECT_TYPE: ruby
```

### Required Variables

* **PRIVATE_KEY**: Your SSH private key, preferably from Secrets.
* **PUBLIC_KEY**: Your SSH public key, preferably from Secrets.
* **HOST**: The host the action will SSH to run the git push command. ie, `your.site.com`.
* **PROJECT**: The project name is used to define the app name.
* **BRANCH**: Repository branch that should be used for deploy, `master` is set by default.
* **PROJECT_TYPE**: (ruby, node) set buildpack according to the project type
* **REDIS**: (Optional) if true, set up a redis instance (Make sure that your app is using default REDIS_URL env variable)
* **ELASTICSEARCH**: (Optional) if true, set up a elasticsearch instance (Make sure that your app is using default ELASTICSEARCH_URL env variable)