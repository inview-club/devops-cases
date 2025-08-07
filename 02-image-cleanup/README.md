# Case №2 - Image Cleanup 🧹

- [Case №2 - Image Cleanup 🧹](#case-2---image-cleanup-)
  - [Goal](#goal)
  - [Stack](#stack)
  - [Checkpoints](#checkpoints)
  - [Result](#result)
  - [Contacts](#contacts)

## Goal

Artifacts created during development should be deleted once they are no longer used to prevent rapid storage overflow of artifact storage.

## Stack

![Gitlab](https://img.shields.io/badge/Gitlab-FC6D26.svg?style=for-the-badge&logo=gitlab&logoColor=white)
![SonatypeNexus](https://img.shields.io/badge/Nexus-0FAF6C?style=for-the-badge&logo=sonatype&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Checkpoints

1. Create three virtual machines with Ubuntu OS: *gitlab*, *build*, *nexus*;
2. [Install GitLab](https://about.gitlab.com/install/) on the *gitlab* virtual machine;
3. [Install gitlab-runner](https://docs.gitlab.com/runner/) on the *build* virtual machine and register it in GitLab;
4. Create a project in GitLab and write a Dockerfile and [pipeline for building](https://docs.gitlab.com/ee/ci/) a Docker container. You can use [this repository](https://github.com/docker/docker-gs-ping.git) for this task;
5. [Install Nexus](https://help.sonatype.com/en/installation-methods.html) on the *nexus* virtual machine;
6. Create a Docker Hosted repository in Nexus for storing Docker images;
7. Add a new job to the pipeline for uploading the built images to Nexus;
8. Add a job to the pipeline to delete previously uploaded Docker images from Nexus, which should run [on a schedule](https://docs.gitlab.com/ee/ci/pipelines/schedules.html) or when a GitLab Environment is stopped;
9. Configure scheduled [tasks in Nexus](https://help.sonatype.com/en/tasks.html) to delete unused layers and blobs.

## Result

Cleanup of images in Nexus should run on schedule or when the GitLab Environment is stopped. The repository size should decrease after removing images.

## Contacts

Need help? Write to [our Telegram chat](https://t.me/+nSELCyIX8ltlNjU6) 🫶
