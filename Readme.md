Take Away Assessment
Task 2
* Install the terraform on ubuntu , check with terraform --version
* Create AWS access for terraform
    * IAM , Add user provide programatic access , Attach existing policy - Administrator access
    * Save the access key id and Secret key.
    * aws configure , and provide access key, secret key and region name.
* Create GCP access for terraform
    * Login to gcp cloud console and create new project.
    * Create a service account, Grant Compute Admin role.
    * Under the actions , Create new key chose json as format and save locally.
* commands to run
    * terraform init (Initializes & gets the details of the provider).
    * terraform validate (to check for the syntax of the teraform script).
    * terraform plan (to see what resources are being created from this teraform script).
    * terraform apply (type yes and this creates the resources).
      
Task 3 

* network_monitor.sh needs have execute permission(chomd +x network_monitor.sh).
* The path location for the log file could be changed to the desired location by editig LOG_FILE inside the script.
* command to run the script ./network_monitor.sh <ipaddress> <hostanme> 
