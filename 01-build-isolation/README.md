# Case #1 - Build Isolation

- [Case #1 - Build Isolation](#case-1---build-isolation)
  - [Goal](#goal)
  - [Stack](#stack)
  - [Checkpoints](#checkpoints)
  - [Result](#result)
  - [Contacts](#contacts)

## Goal

Build process has to run automatically, including when there is no Internet access and external dependencies are unavailable.

## Stack

![Gitlab](https://img.shields.io/badge/Gitlab-FC6D26.svg?style=for-the-badge&logo=gitlab&logoColor=white)
![SonatypeNexus](https://img.shields.io/badge/Nexus-0FAF6C?style=for-the-badge&logo=sonatype&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Checkpoints

1. Create three virtual machines with Ubuntu OS: *gitlab*, *build*, *nexus*;
2. [Install Gitlab](https://about.gitlab.com/install/) on the *gitlab* virtual machine;
3. Install [gitlab-runner](https://docs.gitlab.com/runner/) on the *build* virtual machine and register it in Gitlab;
4. Create a project in Gitlab and write a Dockerfile and [pipeline for building](https://docs.gitlab.com/ee/ci/) a Docker container. You can use [this repository](https://github.com/docker/docker-gs-ping.git) for this task;
5. [Install Nexus](https://help.sonatype.com/en/installation-methods.html) on the *nexus* virtual machine;
6. Create a Docker Hosted repository in Nexus for storing Docker images;
7. Add a new job to the pipeline for uploading the built images to Nexus;
8. Create a [Docker Proxy repository](https://help.sonatype.com/en/proxy-repository-for-docker.html) in Nexus to cache Docker images from other sources;
9. Add the use of Docker-proxy ([mirroring](https://docs.docker.com/docker-hub/mirror/)) with Nexus to the build job;
10. Create a [Golang Proxy repository](https://help.sonatype.com/en/go-repositories.html) in Nexus to cache Golang dependencies;
11. Add proxy usage in the Dockerfile for building the Golang project.

## Result

When pushing new changes to the repository, the image build should automatically start via Gitlab CI/CD. The build should successfully complete even without Internet access. After building, the image should be automatically saved to Nexus. Using the Nexus UI, you can see the uploaded image.

<div align="center">

  ![Result diagram dark](img/01-build-isolation-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/01-build-isolation-light.png#gh-light-mode-only)

</div>

## Contacts

Feel free to ask questions in [our Telegram chat](https://t.me/+nSELCyIX8ltlNjU6)! We will be happy to help🥰
