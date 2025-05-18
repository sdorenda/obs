.PHONY: proxy proxy-artifactory proxy-kubernetes proxy-grafana login-google install-gateway-crds test

login-google:
	gcloud auth login
	gcloud auth application-default login

proxy:
	gcloud compute ssh --zone "europe-west3-a" "nzd-proxy-europe-west3" --tunnel-through-iap --project "nzd-smanke-proxy-tfdy"

proxy-artifactory:
	sudo gcloud compute ssh --zone europe-west3-a nzd-proxy-europe-west3 --tunnel-through-iap --project nzd-smanke-proxy-tfdy -- -NL 443:10.89.195.193:443 -o ServerAliveInterval=5

proxy-kubernetes:
	gcloud compute ssh --zone europe-west3-a nzd-proxy-europe-west3 --tunnel-through-iap --project nzd-smanke-proxy-tfdy -- -NL 16443:10.89.131.129:6443 -o ServerAliveInterval=5

# https://gateway-api.sigs.k8s.io/guides/
install-gateway-crds:
	kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/experimental-install.yaml
	kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.2/docs/content/reference/dynamic-configuration/kubernetes-gateway-rbac.yml

test:
	logger -T -n gw.observability.test.pndrs.de -P 54526 --rfc5424 moep

proxy-grafana:
	gcloud compute ssh --zone europe-west3-a nzd-proxy-europe-west3 --tunnel-through-iap --project nzd-smanke-proxy-tfdy -- -NL 18443:10.89.141.1:443 -o ServerAliveInterval=5

clean-cache: ## Clean terragrunt cache
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;