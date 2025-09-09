#! /bin/bash
if [[ -f /etc/startup_was_launched ]]; then exit 0; fi
apt update
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
apt install curl apt-transport-https ca-certificates gnupg -y
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 
apt update 
apt-get install google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin -y
gcloud composer environments run ${composer_name} \
    --location ${location} \
    users create -- \
    -u accounts.google.com:"$(gcloud iam service-accounts describe ${dbt_deploy_sa_user} --format="value(oauth2ClientId)")" \
    -e ${dbt_deploy_sa_user} \
    -f ${dbt_deploy_sa_user} \
    -l - -r Op --use-random-password

export KUBECONFIG=/tmp/config
gcloud container clusters get-credentials ${composer_gke_name} --zone ${zone} --project ${project}
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: default-sa-airflow-cluster-r
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create", "get", "watch", "list", "exec", "delete"]
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["create", "get", "watch", "list", "exec", "delete"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["create", "get", "watch", "list", "exec", "delete"]
EOF
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: default-sa-airflow-cluster-rb
subjects:
- kind: ServiceAccount
  name: default
  namespace: "$(kubectl get ns --no-headers -o custom-columns=":metadata.name" | grep -E "composer.*$")"
- kind: ServiceAccount
  name: default
  namespace: airflow-tasks
roleRef:
  kind: ClusterRole
  name: default-sa-airflow-cluster-r
  apiGroup: rbac.authorization.k8s.io
EOF

touch /etc/startup_was_launched