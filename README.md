# k8s-frontend-basic

This project creates a container that presents a basic web page built using [Next.js](https://nextjs.org) and delivered by [Nginx](https://nginx.org) for deployment into [Kubernetes](https://kubernetes.io). It is intended to be used as part of a lab exercise or an intructor-led walkthrough.

When running it presents a basic web page displaying a confirmation message:

<img src="https://static.noomedia.com/images/README/k8s-frontend-basic/screenshot.png" width="750">

## Verifying

If [Node.js](https://nodejs.org) is installed locally, you can run the following commands from within the cloned directory to verify that the application works:

```bash
npm install
npm run dev
```

This will start a local web server running on port `3000`. The application can then be verified by visiting [http://localhost:3000](http://localhost:3000) in a web browser.

## Building

To build the container image you will need to have [Docker](https://www.docker.com) installed. To build the image locally, run the following shell script inside the `k8s-frontend-basic` directory:

```bash
./docker-build.sh
```

If the build completes successfully, you will then be asked if you want to push the image. For this to succeed you will need to be authenticated to the specified registry with the appropriate account.

If you want to change the fully-qualified image name (including the image registry) edit the `container.json` file within the `public/data` directory.

⚠️ You should not edit the `docker-build.sh` file directly.


This is because the `container.json` file is used by both the Docker build script and the Next.js application at run time.


* `registry` and `namespace` are _optional_
* `repository` and `tag` are _mandatory_

Note that the values should not end with a trailing slash.

```json
{
  "image": {
    "registry": "docker.io",
    "namespace": "trainingdemos",
    "repository": "k8s-frontend-basic",
    "tag": "1.0"
  }
}
```
## Running in Docker

A container image for this project has been made available on the [Docker Hub](https://hub.docker.com/r/trainingdemos/k8s-frontend-basic) for public use. To run the image using Docker you can use the following command:

```bash
docker run --rm -p 80:80 trainingdemos/k8s-frontend-basic
```

This will start an Nginx web server running on port `80` to serve the application. You can verify that the website is working by visiting [http://localhost](http://localhost) in a web browser.

## Deploying to Kubernetes

The `containerPort` in the Pod spec should be set to port `80` and then access to the Pod should be opened up using a Service object along with a NodePort or Ingress.

Here is an example Pod object configuration:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: k8s-frontend-basic
  labels:
    frontend: basic
spec:
  containers:
  - name: k8s-basic-frontend
    image: trainingdemos/k8s-frontend-basic:latest
    ports:
    - containerPort: 80
```

## License

[MIT](https://choosealicense.com/licenses/mit/) (See LICENSE file)