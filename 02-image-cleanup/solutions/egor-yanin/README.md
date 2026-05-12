# Report for Case №2

Completed by Egor Yanin

### Starting Point

I begin from point 7; all previous suffering is described [here](https://github.com/inview-club/devops-cases/tree/main/01-build-isolation/solutions/egerius)

## Deleting Previously Uploaded Docker Images from Nexus

```yaml
cleanup-image:
  stage: cleanup
  image: alpine:latest
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
    - if: $CI_ENVIRONMENT_ACTION == "stop"
  script:
    - apk add --no-cache curl jq

    - IMAGE_NAME="demo-app"
    - REGISTRY="192.168.1.102:5000"

    - TAGS=$(curl -s http://$REGISTRY/v2/$IMAGE_NAME/tags/list | jq -r '.tags[]')

    - |
      for TAG in $TAGS; do
        echo "Deleting $IMAGE_NAME:$TAG"

        DIGEST=$(curl -sI \
          -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
          http://$REGISTRY/v2/$IMAGE_NAME/manifests/$TAG \
          | grep Docker-Content-Digest | awk '{print $2}' | tr -d $'\r')

        if [ -n "$DIGEST" ]; then
          curl -X DELETE http://$REGISTRY/v2/$IMAGE_NAME/manifests/$DIGEST
        fi
      done
````

<img width="1497" height="164" alt="изображение_2026-05-12_224600664" src="https://github.com/user-attachments/assets/fcd65f24-1091-43a9-b31c-cfdf59c60e51" />

## Configuring Scheduled Nexus Tasks for Removing Unused Layers and Blobs

<img width="1435" height="40" alt="image" src="https://github.com/user-attachments/assets/39e7ff3a-36fe-4fa1-8855-710468c8caf8" />

I also added a cleanup policy:

<img width="1024" height="366" alt="image" src="https://github.com/user-attachments/assets/00afa558-e588-4746-b064-5e7981ac2f76" />

<img width="777" height="236" alt="image" src="https://github.com/user-attachments/assets/fd095242-c745-46e0-ae19-871727822b7d" />

## Versioning and Working with CHANGELOG.md

```yaml
versioning:
  stage: version
  image: alpine:latest
  script:
    - apk add --no-cache git
    - git fetch --tags

    - LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    - VERSION=${LAST_TAG#v}

    - echo "LAST_TAG=$LAST_TAG" > version.env
    - echo "VERSION=$VERSION" > version.env
```

```yaml
changelog:
  stage: version
  image: alpine:latest
  script:
    - apk add --no-cache git

    - git fetch --tags
    - LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    - echo "# Changelog" > CHANGELOG.md
    - echo "" >> CHANGELOG.md

    - git log $LAST_TAG..HEAD --pretty=format:"- %s" >> CHANGELOG.md

  artifacts:
    paths:
      - CHANGELOG.md
```

# Final Pipeline

<img width="1475" height="485" alt="image" src="https://github.com/user-attachments/assets/d25b5063-d4f5-48b8-89e9-4c604dff667b" />
