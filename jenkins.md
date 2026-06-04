Today's Task Documentation
Task overview
Today’s task focused on understanding Jenkins in a practical DevOps context and applying it to a PHP Pimcore project. The work covered Jenkins fundamentals, 
CI/CD pipeline flow, test selection strategy, language-specific testing tools, and the design of a ready-to-use Jenkinsfile for Pimcore with conditional execution and deployment logic.

Objectives
Understand what Jenkins is and how it is used in DevOps workflows.

Learn how Jenkins decides which tests to run in a Jenkinsfile.

Understand how testing differs across programming languages while keeping the same core test categories.

Build a Jenkinsfile for a PHP Pimcore application using proper test stages and when conditions.

Study each section of the Jenkinsfile in detail, including build, test, package, and deploy behavior.

Work completed
1. Studied Jenkins concepts
Jenkins was reviewed as an open-source automation server used for building, testing, and deploying software. Its importance in DevOps was understood in terms of 
CI/CD automation, repeatability, integration with tools, and reducing manual work in the software delivery process.

2. Learned how test selection works in Jenkins
The task included understanding that Jenkins does not automatically decide which tests to run. Instead, the Jenkinsfile defines stages and commands, and test execution 
is controlled by parameters, branches, pull requests, environment conditions, and when blocks.

The following test categories were discussed:

Unit tests

Integration tests

Smoke tests

Regression tests

End-to-end tests

These test types are chosen based on the stage of the pipeline and the purpose of the run, such as commit validation, main branch validation, nightly execution, 
or release preparation.

3. Compared testing across programming languages
It was understood that test concepts remain the same across languages, but frameworks and commands differ depending on the language and ecosystem. Java commonly uses 
JUnit and Mockito, Python commonly uses pytest or unittest, and JavaScript commonly uses Jest, Mocha, Cypress, or Playwright.

A comparison table was prepared to map test types, frameworks, and example Jenkins commands for Java, Python, and JavaScript.

4. Built a Jenkinsfile for PHP Pimcore
A ready-to-use declarative Jenkinsfile was created for a PHP Pimcore project. Pimcore supports testing with PHPUnit-based setups and also documents Codeception as 
a valid testing approach, which made both tools relevant in the pipeline design.

The Jenkinsfile included:

agent any

pipeline options

build parameters

shared environment variables

Checkout stage

Prepare PHP stage using Composer

optional Prepare frontend stage using npm

Code quality stage using phpstan and phpcs when available

Unit tests stage

Integration tests stage

Smoke tests stage

Regression tests stage

Package stage

Deploy to dev, Deploy to staging, and Deploy to prod stages

post actions for JUnit reports and artifact archiving.

5. Understood Jenkinsfile conditions and deployment logic
The Jenkinsfile was studied in detail section by section. This included understanding how parameters such as TEST_SUITE, RUN_FRONTEND_BUILD, RUN_DEPLOY, and
 DEPLOY_ENV control the pipeline, and how when, anyOf, allOf, branch, and changeRequest() are used to decide whether a stage should run.

It was also understood that deployment logic should be restricted by environment and branch, and production deployment should include a manual approval step to reduce risk.

Key learning points
Jenkins is used to automate build, test, package, and deployment workflows.

Test execution in Jenkins is controlled explicitly by pipeline design rather than guessed automatically.

Test types are common across languages, but frameworks and commands differ by ecosystem.

Pimcore testing can be implemented using PHPUnit or Codeception depending on project setup.

Declarative Jenkins pipelines support parameters, environment variables, conditional stages, and post-build actions.

Production deployments should have stronger controls than lower environments.

Outcome
By the end of today’s task, a clear understanding was developed of how Jenkins is used in DevOps, how tests are selected inside Jenkins pipelines, how test tooling 
varies across languages, and how to design a practical Jenkinsfile for a PHP Pimcore project with configurable test, packaging, and deployment stages.


```
  pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        ansiColor('xterm')
    }

    parameters {
        choice(
            name: 'TEST_SUITE',
            choices: ['unit', 'integration', 'smoke', 'regression', 'all'],
            description: 'Select which test suite to run'
        )
        booleanParam(
            name: 'RUN_FRONTEND_BUILD',
            defaultValue: true,
            description: 'Run frontend asset build'
        )
        booleanParam(
            name: 'RUN_DEPLOY',
            defaultValue: false,
            description: 'Deploy after successful pipeline'
        )
        choice(
            name: 'DEPLOY_ENV',
            choices: ['none', 'dev', 'staging', 'prod'],
            description: 'Target environment for deployment'
        )
    }

    environment {
        APP_ENV = 'test'
        COMPOSER_ALLOW_SUPERUSER = '1'
        PHPUNIT = 'vendor/bin/phpunit'
        CODECEPTION = 'vendor/bin/codecept'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare PHP') {
            steps {
                sh '''
                    php -v
                    composer --version
                    composer install --no-interaction --prefer-dist
                '''
            }
        }

        stage('Prepare frontend') {
            when {
                expression { return params.RUN_FRONTEND_BUILD }
            }
            steps {
                sh '''
                    if [ -f package.json ]; then
                      npm ci
                      npm run build
                    else
                      echo "No package.json found, skipping frontend build"
                    fi
                '''
            }
        }

        stage('Code quality') {
            steps {
                sh '''
                    if [ -f vendor/bin/phpstan ]; then
                      vendor/bin/phpstan analyse || exit 1
                    else
                      echo "phpstan not configured, skipping"
                    fi

                    if [ -f vendor/bin/phpcs ]; then
                      vendor/bin/phpcs || exit 1
                    else
                      echo "phpcs not configured, skipping"
                    fi
                '''
            }
        }

        stage('Unit tests') {
            when {
                anyOf {
                    expression { return params.TEST_SUITE == 'unit' }
                    expression { return params.TEST_SUITE == 'all' }
                    changeRequest()
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                sh '''
                    if [ -f ${PHPUNIT} ]; then
                      ${PHPUNIT} --testsuite Unit --log-junit reports/phpunit-unit.xml
                    else
                      echo "PHPUnit not found"
                      exit 1
                    fi
                '''
            }
        }

        stage('Integration tests') {
            when {
                anyOf {
                    expression { return params.TEST_SUITE == 'integration' }
                    expression { return params.TEST_SUITE == 'all' }
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                sh '''
                    mkdir -p reports
                    if [ -f ${PHPUNIT} ]; then
                      ${PHPUNIT} --testsuite Integration --log-junit reports/phpunit-integration.xml
                    elif [ -f ${CODECEPTION} ]; then
                      ${CODECEPTION} run integration --xml
                    else
                      echo "Neither PHPUnit nor Codeception integration setup found"
                      exit 1
                    fi
                '''
            }
        }

        stage('Smoke tests') {
            when {
                anyOf {
                    expression { return params.TEST_SUITE == 'smoke' }
                    expression { return params.TEST_SUITE == 'all' }
                    branch 'main'
                }
            }
            steps {
                sh '''
                    mkdir -p reports
                    if [ -f ${PHPUNIT} ]; then
                      ${PHPUNIT} --group smoke --log-junit reports/phpunit-smoke.xml
                    elif [ -f ${CODECEPTION} ]; then
                      ${CODECEPTION} run acceptance --group smoke --xml
                    else
                      echo "No smoke test setup found"
                      exit 1
                    fi
                '''
            }
        }

        stage('Regression tests') {
            when {
                anyOf {
                    expression { return params.TEST_SUITE == 'regression' }
                    expression { return params.TEST_SUITE == 'all' }
                    branch 'main'
                }
            }
            steps {
                sh '''
                    mkdir -p reports
                    if [ -f ${PHPUNIT} ]; then
                      ${PHPUNIT} --log-junit reports/phpunit-regression.xml
                    elif [ -f ${CODECEPTION} ]; then
                      ${CODECEPTION} run --xml
                    else
                      echo "No regression test setup found"
                      exit 1
                    fi
                '''
            }
        }

        stage('Package') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                sh '''
                    mkdir -p build
                    tar -czf build/pimcore-app.tar.gz .
                '''
            }
        }

        stage('Deploy to dev') {
            when {
                allOf {
                    expression { return params.RUN_DEPLOY }
                    expression { return params.DEPLOY_ENV == 'dev' }
                }
            }
            steps {
                sh '''
                    echo "Deploying to dev..."
                    # ./deploy.sh dev
                '''
            }
        }

        stage('Deploy to staging') {
            when {
                allOf {
                    expression { return params.RUN_DEPLOY }
                    expression { return params.DEPLOY_ENV == 'staging' }
                    branch 'main'
                }
            }
            steps {
                sh '''
                    echo "Deploying to staging..."
                    # ./deploy.sh staging
                '''
            }
        }

        stage('Deploy to prod') {
            when {
                allOf {
                    expression { return params.RUN_DEPLOY }
                    expression { return params.DEPLOY_ENV == 'prod' }
                    branch 'main'
                }
            }
            steps {
                input message: 'Approve production deployment?', ok: 'Deploy'
                sh '''
                    echo "Deploying to production..."
                    # ./deploy.sh prod
                '''
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: 'reports/*.xml, tests/_output/*.xml'
            archiveArtifacts artifacts: 'build/*.tar.gz, reports/*.xml', allowEmptyArchive: true
        }
        success {
            echo 'Pipeline completed successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}

```







