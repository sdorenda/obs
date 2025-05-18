docker:
	docker buildx build -t remote-syslog-test:v1 .
	kind load docker-image remote-syslog-test:v1 --name edp
	
