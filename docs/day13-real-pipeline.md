
Create a real CI pipeline in Jenkins with these stages:

- Checkout
- Lint (basic)
- Build Docker image
- Run container + smoke tests
- Archive artifacts
- Cleanup (after build)

---

## Jenkinsfile

The Jenkinsfile is stored in the repo and configured as “Pipeline script from SCM” in Jenkins.

Main parts:

1. **Checkout**  
   - Uses `checkout scm` to pull the latest code from Git.  
   - Ensures all later stages run on the same commit.

2. **Lint (basic)**  
   - Runs a simple lint/syntax check (e.g. `php -l app/site/index.php` or `echo "Running lint..."`).  
   - Purpose: catch basic issues early before building Docker images.

3. **Build Docker image**  
   - Command (inside Jenkinsfile):  
     ```sh
     docker build -f docker/Dockerfile -t myapp:build-$BUILD_NUMBER .
     ```  
   - Builds a Docker image of the app using the repo’s Dockerfile.

4. **Run container + smoke tests**  
   - Starts a container from the image:  
     ```sh
     docker rm -f myapp-test || true
     docker run -d --name myapp-test -p 8081:8080 myapp:build-$BUILD_NUMBER
     sleep 5
     ```  
   - Runs a simple HTTP check (smoke test):  
     ```sh
     curl -f http://localhost:8081/ || exit 1
     ```  
   - If the app does not respond with 2xx, the build fails here.

5. **Archive artifacts (logs + build-info)**  
   - Collects useful files for debugging and history:  
     ```sh
     mkdir -p build-info
     docker logs myapp-test > build-info/app.log || true
     echo "IMAGE=myapp:build-$BUILD_NUMBER" > build-info/build-info.txt
     ```  
   - Archives them in Jenkins:  
     ```groovy
     archiveArtifacts artifacts: 'build-info/**', fingerprint: true
     ```  
   - Result: logs and build info are available on the Jenkins build page.

6. **Cleanup (post section)**  
   - Runs after the build (success or failure):  
     ```groovy
     post {
       always {
         sh 'docker rm -f myapp-test || true'
         sh "docker rmi myapp:build-$BUILD_NUMBER || true"
         cleanWs()
       }
     }
     ```  
   - Removes test container, removes image, and cleans the workspace.

---

## Evidence for Day 13

1. **Jenkinsfile committed**  
   - `ci/Jenkinsfile` (or `Jenkinsfile`) is in the repository and used by the Jenkins job.

2. **Artifacts archived**  
   - After a build, Jenkins shows artifacts under “Build Artifacts”:  
     - `build-info/app.log` (container logs)  
     - `build-info/build-info.txt` (image tag).

3. **Cleanup runs after build**  
   - In the build console log, you can see the post steps running:  
     - `docker rm -f myapp-test`  
     - `docker rmi myapp:build-...`  
     - `cleanWs()`  
   - `docker ps` on the Jenkins node shows no leftover `myapp-test` container after the build.

