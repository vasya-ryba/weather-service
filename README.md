# Weather service

Show weather forecast in Tbilisi, Georgia using [wttr.in](https://github.com/chubin/wttr.in)

Example [full](http://weather.russiansingeorgia.me) / [short output](http://wttr.russiansingeorgia.me)

## What's inside

### Images
* **server** - simple nginx server displaying static file from shared volume over HTTP
````shell
docker build server -t gcr.io/<gke-project-id>/server:0.0.1  
````

* **updater** - Alpine Linux with cron job updating forecast in file
````shell
docker build updater -t gcr.io/<gke-project-id>/updater:0.0.1  
````

Run locally via Docker Compose:
````shell
docker-compose up --build -d
````

### Terraform script
Creates Kubernetes cluster in Google Cloud and deploys 2 versions of weather service
##### Prerequisites
* Google Cloud project
* gcloud auth
* Kubernetes config in `~/.kube/config`
* images server:0.0.1, updater:0.0.1, updater:0.0.3 uploaded to project Container Registry
* bucket `tf-state-wttr` in Google Cloud Storage
##### Variables
 * `project_id` - Google Cloud project ID
 * `region` - cluster region (i.g. europe-central2)
 * `zone` - cluster zone (i.g. europe-central2-a)
 * `gke_num_nodes` - number of nodes in pool
 * `repl_num` - number of pods
 * `full_output_url` - URL for full output
 * `short_output_url` - URL for short output
##### Scripts
#####`gke.tf`:
Provision GKE Cluster with separate node pool
#####`weather.tf`:
Creates 2 deployments and services: 
 * `weather-service-1`: images `server:0.0.1` + `updater:0.0.1` for full output
 * `weather-service-2`: images `server:0.0.1` + `updater:0.0.3` for short output

Creates Ingress for routing to `full_output_url` and `short_output_url`