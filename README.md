# Ephemeral GKE + Cloud SQL Deployment on GCP v0.01 (alpha)

This README outlines the Terraform configuration for a GCP deployment with a WordPress application. It includes:

* Network creation (VPC, Subnets, and Firewall Rules)
* Cloud SQL database cluster setup (MySQL instance)
* GKE cluster with a Node Pool and LoadBalancer
* Contimnaerized WordPress web applicaton deployment on the cluster

# Deployment Concepts

**Automation Approach:** The automaton concept is to create literally everything using infrastrucure as code (IaC), including the VPC itself, subnets, firewal rules, GKE clusters, applications, load balancers, and Cloud SQL instances. There is no fixed infrastructure whatsoever. There are no manual steps, i.e., no use of the `gcloud` CLI, Google Cloud Console, or other tools that require post-automation actions of any kind. The basic approach is inspired by serverless (e.g., Cloud Functions).
**Easy Scalability:** This repository contains the Terraform code to deploy WordPress application on Google Kubernetes Engine (GKE) using a Cloud SQL database. The concept is to leverage Platform as a Service (PaaS) for easy scalability, e.g., Kubermnetes Horizontal Pod Autoscaling. The front-end applicatoon can be scaled globally in a horizontal way.
**Ephemeral Deployments:** The automation is intended to deploy infrastrcture and applications, execute applicatoon code, run tests and collect test result data, then destroy the entire solution, retaining only the data. There are several advantages to an ephemeral infrastructure aproach:
* **Immutable Infrastructure** Application containers are not patced. They are destroyed and recreated.
* **Privacy and Segregation** For multiple enterp[rise customers each customer can be segregated by cluster, of by VPC, or by GCP project to addresses a subset of concerns related to handing sensitive data.
* **Enhanced Security** The solution inherits the security of ephemerality and immutable infrastructure and does not require human access to environments (unless tests are actually running, there's virtually nothing for hackers to attack).
 
![tfpgv2](https://github.com/user-attachments/assets/39f0f669-5c9e-4470-95a4-a1a3a9109699)

### Directory Structure

```
├── applications.tf
├── backend.tf
├── databases.tf
├── kubernetes.tf
├── networks.tf
├── providers.tf
├── terraform.tfvars
└── variables.tf
```

## File Details

**providers.tf:**
* Defines the Google Cloud Provider for Terraform

**variables.tf:**
* Declares variables to configure the deployment:
* `db_password   : DB root password
* `db_user       : DB root user
* `gcp_project   : GCP Project ID
* `gcp_region    : GCP Region
* `gcp_sa        : GCP Service account
* `gcp_vpc_name  : VPC network
* `gcp_zone      : GCP Zone (primary)
* `gcp_zone_list : GCP Zone list (for HA)
* `gke_cluster   : GKE cluster name
* `gke_vm_type   : Machine type for GKE node pool

**terraform.tfvars:**
* Sets the values for the declared variables

**backend.tf:**
* Configures Terraform state storage in Google Cloud Storage (GCS)

**networks.tf:**
* Creates the VPC network (`gcp_vpc_name`)
* Creates two subnets:
* `subnet0`: For the GKE cluster (frontend)
* Defines firewall rules for:
* Allowing ICMP, HTTP, and HTTPS traffic to the frontend subnet
* Allowing inbound and outbound PSC connections with Cloud SQL

**databases.tf:**
* Creates a MySQL database instance (`mysql-database`) in the backend subnet:
* Configured with SSD disk
* Creates a user `root` with specified password

**kubernetes.tf:**
* Creates the GKE cluster in the frontend subnet
* Deploys preemptible nodes with the specified type
* Configures the cluster with service account and OAuth scopes for logging and monitoring

**applications.tf:**
* Creates a Persistent Volume Claim (PVC) for WordPress
* Deploys WordPress application as a Deployment
* Deploys two replicas
* Mounts the PVC
* Sets environment variables for database connection
* Creates LoadBalancer service
* Exposes port 80 on the LoadBalancer for HTTP traffic

### Scaling Plan

To scale the solution to serve millions of users, several approaches can be used:

* More GKE nodes and regional clusters can be deployed to handle increased traffic. In the v0.01 version, preemptible nodes are defined to reduce costs.
* The Cloud SQL database PaaS service can be scaled up with larger VM types and scaled out using larger clusters. Altarnatively, a more scalable database service like Google Cloud Spanner could be used for increased performance, scalability, and availability.
* A Content Delivery Network (CDN) can be used to cache static content and improve performance and latency.
* More advanced GCP load balancers can be used to distribute traffic more efficiently across multiple front-end instances.
* Performance can be optimized to ensure efficient resource utilization.

## Future Objectives

* **Enforce strict network access control rules:** Limit the source ranges for firewall rules to trusted IP addresses or networks.
* **Implement robust database security:** Use user accounts and roles with least-privilege permissions to control database access.
* **Use an ingress controller:** Deploy an ingress controller for efficient traffic management and security features.
* **Secure sensitive information:** Store passwords and other confidential data in a secrets management service.
* **Enable authentication for the cluster:** Implement strong authentication mechanisms for accessing the cluster.
* **Implement additional monitoring:** The current deployment relies entirely on built-in GCP monitoring capabilities which canbe configured to provide additional functionality. However, built-in tools are not adequate for production operations. Additional services, such as Datadog and PagerDuty will be needed to go live.

## Security Concerns in v0.01

* **Firewall Rules:** The firewall rules allow all IP addrtesses (0.0.0.0/0) to connect to the front-end on HTTP, HTTPS,. This is a **security risk**, as it exposes the cluster to potential attacks. The demo application (WordPress) is notorious for its security vulnerabilities.
* **Database Access Control:** While the firewall rules restrict MySQL access to the frontend subnet, there is no explicit user or role-based access control for the database instance. The best practice is to use Google's Private Service Connect (PSC) networking option.
* **No separate ingress controller** for this deployment (version 0.01). This means the front-end and back-end deployments use the default Kubernetes networking and rely solely on firewall rules for security. In a real-world application, a dedicated ingress controller should be deployed and managed to enhance security.

## Project Status (v0.01):
As it stands that defined solution deploys and runs and should work if IPv4 firewall rules are updated post deployment. This violates the 100% automation objective. Google Private Service Connect (PSC) has not been enabled (although related code appears in the databases.tf, networks.tf, and kubernetes.tf files).

## License

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.

