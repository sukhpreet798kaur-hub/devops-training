# Scheduler Deployment in Jenkins

## Task Objective

Implement a scheduled Jenkins Pipeline that runs automatically at a fixed time using cron syntax, so build, test, validation, or deployment steps can execute without
manual triggering.

## What is Scheduler Deployment in Jenkins?

In Jenkins, scheduler deployment means configuring a job or pipeline so that it runs automatically on a defined schedule instead of waiting for a manual **Build Now**
 action.
This is usually done using Jenkins build triggers with cron syntax, either from the Jenkins UI or directly inside the `Jenkinsfile` using the `triggers` directive.

## Where It Is Used in Real Projects

Scheduled Jenkins pipelines are commonly used for:

- Nightly builds and deployments to staging.
- Daily Kubernetes manifest validation or health checks.
- Off-hours test execution or regression runs.
- Periodic cleanup, backup, or maintenance jobs.

## Prerequisites

Before implementing this task, make sure the following are ready:

- Jenkins is installed and accessible from the browser.
- A Jenkins Pipeline job exists, or a new one can be created.
- Your source code and `Jenkinsfile` are stored in Git if you want Pipeline as Code.
- If deployment is included, Jenkins must already have access to Docker, Kubernetes, or required credentials.

## Recommended Approach

The recommended production approach is to define the schedule inside the `Jenkinsfile` using the `triggers` block, because it keeps the scheduling logic in version control
with the pipeline code.
The Jenkins UI option **Build periodically** is useful for testing or legacy jobs, but `Jenkinsfile` scheduling is generally easier to track and maintain.

## Method 1: Scheduler in Jenkinsfile

### Step 1: Create a Pipeline Job

1. Open the Jenkins dashboard.
2. Click **New Item**.
3. Enter a job name, for example `scheduled-deployment-pipeline`.
4. Select **Pipeline** as the project type.
5. Click **OK**.

### Step 2: Configure Pipeline Script from SCM

1. Open the job configuration page.
2. Go to the **Pipeline** section.
3. In **Definition**, choose **Pipeline script from SCM**.
4. In **SCM**, choose **Git**.
5. Enter your repository URL.
6. Enter the branch name, for example `main`.
7. Set the script path as `Jenkinsfile` if the file is in the repository root.
8. Save the job.

### Step 3: Add the Trigger in Jenkinsfile

Use a declarative pipeline like this:

```groovy
pipeline {
    agent any

    triggers {
        cron('0 2 * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'echo "Running scheduled pipeline"'
            }
        }

        stage('Deploy') {
            steps {
                sh 'echo "Deploy step goes here"'
            }
        }
    }
}
```

In this example, `triggers { cron('0 2 * * *') }` tells Jenkins to run the pipeline every day at 2:00 AM.

### Step 4: Understand the Cron Format

Jenkins cron syntax contains 5 fields:

```text
MINUTE HOUR DAY_OF_MONTH MONTH DAY_OF_WEEK
```

Examples:

- `0 2 * * *` → every day at 2:00 AM.
- `H/5 * * * *` → every 5 minutes, where `H` spreads load automatically.
- `0 10 * * 1-5` → Monday to Friday at 10:00 AM.

### Step 5: Run Once Manually

After adding a trigger in the `Jenkinsfile`, run the job manually once so Jenkins registers the pipeline and its schedule correctly.

### Step 6: Verify Scheduled Execution

1. Open the job in Jenkins.
2. Check **Build History** after the scheduled time.
3. Open **Console Output** to confirm the run started automatically.

## Method 2: Scheduler from Jenkins UI

This method is useful for temporary or simple jobs.

### Step 1: Open the Jenkins Job

1. Go to Jenkins dashboard.
2. Open the job you want to schedule.
3. Click **Configure**.

### Step 2: Enable Build Periodically

1. Find the **Build Triggers** section.
2. Check **Build periodically**.
3. In the schedule box, enter a cron expression such as:

```text
H/5 * * * *
```

This runs the job every 5 minutes using Jenkins hash-based scheduling.

4. Click **Save**.

## Best Option for Real Projects

For real projects, the best option is usually the `Jenkinsfile` trigger method because it is part of Pipeline as Code, easy to version, and reproducible across Jenkins environments.[1][4][9] The Jenkins UI method is easier for quick experiments, but it is less visible to the team and not stored in Git by default.[3][2]

## Real Deployment Example

If the task is to schedule a deployment to Kubernetes, your `Jenkinsfile` can look like this:

```groovy
pipeline {
    agent any

    triggers {
        cron('0 2 * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Manifest Validation') {
            steps {
                sh 'kubectl apply --dry-run=server -f k8s/deployment.yaml'
                sh 'kubectl apply --dry-run=server -f k8s/service.yaml'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }
    }
}
```

This pipeline checks out code, validates manifests, and deploys them every day at 2:00 AM.

## Troubleshooting Tips

- If the job does not run, check whether the cron syntax is valid.
- If the trigger is inside `Jenkinsfile`, run the job manually once after saving it.
- If using SCM, confirm Jenkins can access the repository and the `Jenkinsfile` path is correct.
- Check **Console Output** and **Build History** for schedule confirmation and errors.

