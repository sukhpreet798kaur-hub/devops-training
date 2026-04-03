

## 1. Triggers

- Enabled **Poll SCM** on my Jenkins pipeline job.
- Schedule used:

  ```text
  H/2 * * * *
  ```

- This makes Jenkins check the Git repo every 2 minutes and start a build automatically when there is a new commit.
- Verified by pushing a commit to GitHub and seeing a build start with “Started by an SCM change” in the console log.

## 2. Pipeline Parameters

Added parameters at the top of the Jenkinsfile:

```groovy
parameters {
    choice(
        name: 'ENVIRONMENT',
        choices: ['dev', 'staging', 'prod'],
        description: 'Target environment'
    )
    string(
        name: 'APP_VERSION',
        defaultValue: '1.0.0',
        description: 'Application version or tag'
    )
    booleanParam(
        name: 'SIMULATE_FAILURE',
        defaultValue: false,
        description: 'If true, deliberately fail the pipeline'
    )
}
```

- `ENVIRONMENT`: lets me choose where this build is targeted (dev/staging/prod).
- `APP_VERSION`: free text to record app version or tag.
- `SIMULATE_FAILURE`: checkbox used to deliberately fail the build for testing.

These parameters appear in **Build with Parameters** and can be accessed inside the pipeline via `params.ENVIRONMENT`, `params.APP_VERSION`, and `params.SIMULATE_FAILURE`.

## 3. Controlled Failure (Simulate Failure)

Created a stage that fails on purpose when `SIMULATE_FAILURE` is true:

```groovy
stage('Simulate failure') {
    steps {
        script {
            if (params.SIMULATE_FAILURE) {
                error("SIMULATE_FAILURE is true, failing build on purpose.")
            } else {
                echo "SIMULATE_FAILURE is false, continuing normally."
            }
        }
    }
}
```

### Evidence

- **Failing build:**
  - Ran pipeline with `SIMULATE_FAILURE = true`.
  - Build stopped in `Simulate failure` stage with message:
    - `SIMULATE_FAILURE is true, failing build on purpose.`
  - Overall build result: **FAILED**.

- **Fixed build:**
  - Ran pipeline again with `SIMULATE_FAILURE = false`.
  - Stage printed “continuing normally” and the pipeline continued to:
    - build Docker image,
    - run container + smoke tests,
    - archive artifacts.
  - Overall build result: **SUCCESS**.

## 4. Notification Stage (Placeholder)

Configured `post` block to print different messages on success and failure:

```groovy
post {
    success {
        echo "Build SUCCESS for ${env.JOB_NAME} #${env.BUILD_NUMBER} (ENV=${params.ENVIRONMENT}, VERSION=${params.APP_VERSION})"
    }
    failure {
        echo "Build FAILED for ${env.JOB_NAME} #${env.BUILD_NUMBER} (ENV=${params.ENVIRONMENT}, VERSION=${params.APP_VERSION})"
    }
    always {
        echo "Running cleanup..."
        sh 'docker rm -f myapp-test || true'
        sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
        cleanWs()
    }
}
```

- This acts as a simple notification mechanism (can be replaced later with real email/Slack).
- Also ensures each build cleans up its Docker container, image, and workspace.

## 5. Summary

- Auto-trigger: **Poll SCM** with `H/2 * * * *`.
- Parameters: `ENVIRONMENT`, `APP_VERSION`, `SIMULATE_FAILURE`.
- Controlled failure: `Simulate failure` stage using `SIMULATE_FAILURE` boolean.
- Notifications: `post` block with different messages for success and failure plus cleanup.
