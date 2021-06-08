(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"${OS}_${ARCH}" &&
  "$KREW" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl krew

## https://kubernetes.github.io/ingress-nginx/kubectl-plugin/
kubectl krew install ingress-nginx
kubectl ingress-nginx --help

## https://github.com/kvaps/kubectl-node-shell 
kubectl krew index add kvaps https://github.com/kvaps/krew-index
kubectl krew install kvaps/node-shell

## https://github.com/ahmetb/kubectx#installation
kubectl krew install ctx
kubectl krew install ns

## https://github.com/dirathea/kubectl-unused-volumes
kubectl krew install unused-volumes

## https://github.com/rajatjindal/kubectl-whoami

## https://github.com/yashbhutwala/kubectl-df-pv
curl https://krew.sh/df-pv | bash

## https://github.com/corneliusweig/ketall
kubectl krew install get-all

## https://github.com/steveteuber/kubectl-graph
kubectl krew install graph

## https://github.com/elsesiy/kubectl-view-secret
kubectl krew install view-secret
