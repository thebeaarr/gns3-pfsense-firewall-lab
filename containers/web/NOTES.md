# Docker Build — How it works

## The command
```bash
docker build -t gns3-web .
```
```
-t gns3-web  → tags/names the image as "gns3-web"
.            → tells Docker to find the Dockerfile in the current directory
```

---

## Phase 1 — Docker reads your Dockerfile
Docker opens the Dockerfile in the current directory and reads it **top to bottom** like a recipe.

---

## Phase 2 — Processes each instruction as a layer

```
Step 1/5 → FROM debian:latest
           Docker checks: "do I have debian:latest locally?"
           If NO  → downloads it from hub.docker.com
           If YES → uses the cached version
           Result → base layer created ✅

Step 2/5 → RUN apt update && apt install ...
           Docker spins up a TEMPORARY container from the base
           Runs the apt commands inside it
           Installs nginx, curl, ping, etc...
           Saves the result as a new layer
           Destroys the temporary container
           Result → packages layer created ✅

Step 3/5 → RUN echo ... > /var/www/html/index.html
           Another temporary container spins up
           Creates the HTML file inside it
           Saves result as new layer
           Result → webpage layer created ✅

Step 4/5 → EXPOSE 80
           Just writes metadata — no container needed
           Result → port documented ✅

Step 5/5 → CMD ["nginx", "-g", "daemon off;"]
           Just writes metadata — no container needed
           Result → startup command saved ✅
```

---

## Phase 3 — Final image is assembled

Docker stacks all layers together into one image:

```
┌─────────────────────────────┐
│  CMD nginx daemon off       │  ← layer 5
├─────────────────────────────┤
│  EXPOSE 80                  │  ← layer 4
├─────────────────────────────┤
│  index.html created         │  ← layer 3
├─────────────────────────────┤
│  nginx + tools installed    │  ← layer 2
├─────────────────────────────┤
│  debian:latest              │  ← layer 1 (base)
└─────────────────────────────┘
         = gns3-web image ✅
```

---

## Phase 4 — Image is tagged and stored locally

Docker saves the final image with the name `gns3-web`. Verify with:
```bash
docker images
```
```
REPOSITORY   TAG      IMAGE ID       CREATED          SIZE
gns3-web     latest   38fe5a15a273   15 seconds ago   175MB
```

---

## Key concepts to remember

```
IMAGE     → static blueprint (like an ISO file)
            created by → docker build
            stored in  → your local machine

CONTAINER → a running instance of an image (like a running VM)
            created by → docker run
            in GNS3    → created automatically when you start a node

LAYER     → each instruction in Dockerfile creates one layer
            layers are CACHED → if nothing changed, Docker reuses them
            fewer layers = smaller image size
```

---

## The full lifecycle in your lab

```
Dockerfile         →   docker build   →   IMAGE (gns3-web)
(your recipe)          (cooking it)        (the dish, ready to serve)
                                               ↓
                                           GNS3 drags it onto canvas
                                               ↓
                                           CONTAINER starts running
                                               ↓
                                      nginx serves your web page ✅
```

---
