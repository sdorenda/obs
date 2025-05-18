REPO?=sandrom
APP_NAME=fastapi-testapp
VERSION?=0.0.19

docker:
	docker buildx build --platform linux/amd64 -t ${REPO}/${APP_NAME}:${VERSION} .
	docker push ${REPO}/${APP_NAME}:${VERSION}

k8s:
	kubectl delete pod fastapi-testapp
	kubectl apply -f testapp-pod.yaml

all: docker k8s
