Day 12 – Jenkins setup + credentials

1) Jenkins accessible locally:
   - Jenkins running in Docker on http://localhost:8080.

2) Pipeline run succeeds:
   - Job: training-site
   - Source: Jenkinsfile in repo
   - Stages: Checkout (git) + Run tests (`make test`)

3) Credentials referenced, not hardcoded:
   - Jenkins credential created: ID = git-credentials-devops (username + password).
   - Jenkinsfile uses:
       environment { GIT_CRED_ID = 'git-credentials-devops' }
       git(..., credentialsId: env.GIT_CRED_ID)
   - No tokens/passwords stored in Git.
