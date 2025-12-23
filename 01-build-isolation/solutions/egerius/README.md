# Report for Case #1

**Completed (and underestimated my own abilities) by Egor Yanin**

This is a story about how a seemingly simple task can stretch over several weeks due to non-obvious issues.  

![problems](https://github.com/user-attachments/assets/3cde370f-4080-467a-9310-622d3d61e56d)

### Getting Started

The first step was creating and setting up virtual machines. For GitLab, I used an existing Ubuntu VM with 10 GB of RAM, while the other two machines were Ubuntu Server with 2 GB each for Nexus and GitLab Runner. For a laptop with 16 GB of RAM, this wasn’t a trivial task, and it would later show its consequences, but for now, everything seemed to go smoothly.

### Early Warnings

For the application, I used the suggested repository `docker-gs-ping`. Initially, everything went well — GitLab installed and even seemed to run. However, the fact that the machine was not fresh but pre-used showed up in an unpleasant way. GitLab’s Nginx conflicted with the Nginx already installed on the machine. I had to stop the local Nginx, and then everything started… right?

### Networking…

GitLab was accessible, I logged in, changed the password, and tried registering the runner. However, the runner could not reach GitLab, and I suddenly remembered that I hadn’t configured the network settings of the VMs at all. I quickly set up a network bridge, found the VMs’ IPs, and everything started working.  

But… a few days later, the IPs changed. That’s when I remembered DHCP. I quickly assigned static IPs using MAC address filtering, and from that point on, the network stopped causing problems.

### Dind (Docker-in-Docker)

```
ERROR: Cannot connect to the Docker daemon at tcp://docker:2375. Is the docker daemon running?
```


I feel like I’ll be haunted by this error in my dreams. It tormented me for hours — and it was entirely my own doing when I started this case.  

Everything began at step 7: `Add a new job to the pipeline for uploading the built images to Nexus`. I researched online and decided to use Docker-in-Docker for building images. This led to the following configuration:

```yml
stages:
  - build
  - push

image: docker:24

services:
  - name: docker:dind
    command: ["--insecure-registry=192.168.1.50:5000"]

variables:
  DOCKER_TLS_CERTDIR: ""

build_image:
  stage: build
  script:
    - docker build -t demo-app:latest .
    - docker tag demo-app:latest $NEXUS_REGISTRY/demo-app:latest

push_image:
  stage: push
  script:
    - echo "$NEXUS_PASSWORD" | docker login $NEXUS_REGISTRY -u "$NEXUS_USER" --password-stdin
    - docker push $NEXUS_REGISTRY/demo-app:latest
```
I put the variables in the project’s CI/CD settings on GitLab. Everything seemed fine — until the error above appeared. I spent over 3 hours on this, searching GitLab forums, consulting AI, and committing the file 12 times.

Eventually, I realized the runner didn’t have enough resources to start Docker properly, and a simple sleep 30 command helped me debug the chain of errors and fix the file.

### Success

There were many smaller errors due to inattention, lack of knowledge, or inexperience, but I learned quickly. In the end, I finally saw the green light — the job ran successfully.

Here’s the final `gitlab-ci.yml`:

```yml
image: docker:latest

variables:
  DOCKER_HOST: unix:///var/run/docker.sock
  DOCKER_TLS_CERTDIR: ""
  IMAGE_NAME: demo-app
  IMAGE_TAG: $CI_COMMIT_SHORT_SHA
  DOCKER_BUILDKIT: "1"
  GOPROXY: "http://192.168.1.104:8081/repository/go-proxy/,direct"

stages:
  - build
  - push

build-image:
  stage: build
  services: []
  script:
    - docker info
    - docker build -f Dockerfile.multistage -t 192.168.1.104:5000/$IMAGE_NAME:$IMAGE_TAG .

push-image:
  stage: push
  script:
    - echo "$NEXUS_PASSWORD" | docker login 192.168.1.104:5000 -u "$NEXUS_USER" --password-stdin
    - docker push 192.168.1.104:5000/$IMAGE_NAME:$IMAGE_TAG

```

Nexus Repositories
<img width="1548" height="544" alt="image" src="https://github.com/user-attachments/assets/09022ae3-b0ab-4fca-b78b-a3e9875d5230" />

`docker-hosted` contains demo-app images

`docker-proxy` proxies Docker images for offline access

`go-proxy` caches Golang dependencies

The pipeline works even without internet on the runner machine, so I consider the case completed.