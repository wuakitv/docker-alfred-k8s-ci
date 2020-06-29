FROM debian:10

# Environment variables
ENV ARGOCD_VERSION=v1.5.7
ENV KUBEVAL_VERSION=0.15.0
ENV KUBE_SCORE_VERSION=1.7.1
ENV KUSTOMIZE_VERSION=v3.5
ENV SOPS_VERSION=v3.5.0
ENV XDG_CONFIG_HOME=/root/.config
ENV KUSTOMIZE_PLUGIN_HOME=$XDG_CONFIG_HOME/kustomize/plugin

RUN apt-get update && apt-get install -y curl gawk git && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install ArgoCD CLI
RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd

# Install Kubeval
RUN curl -sSL -o kubeval-linux-amd64.tar.gz https://github.com/instrumenta/kubeval/releases/download/$KUBEVAL_VERSION/kubeval-linux-amd64.tar.gz && \
    tar xf kubeval-linux-amd64.tar.gz -C /usr/local/bin/ && chmod +x /usr/local/bin/kubeval && rm kubeval-linux-amd64.tar.gz

# Install Kube-Score
RUN curl -sSL -o kube_score.tar "https://github.com/zegl/kube-score/releases/download/v${KUBE_SCORE_VERSION}/kube-score_${KUBE_SCORE_VERSION}_linux_386.tar.gz" && \
    tar xf kube_score.tar -C /usr/local/bin/ && chmod +x /usr/local/bin/kube-score && rm kube_score.tar

# Install Kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/release-kustomize-${KUSTOMIZE_VERSION}/hack/install_kustomize.sh"  | bash && \
    mv kustomize /usr/local/bin/ && chmod +x /usr/local/bin/kustomize

# Install Mozilla SOPS
RUN curl -sSL -o /usr/local/bin/sops https://github.com/mozilla/sops/releases/download/$SOPS_VERSION/sops-$SOPS_VERSION.linux && \
    chmod +x /usr/local/bin/sops

# Install Kustomize SimpleSOPS plugin
RUN mkdir -p $XDG_CONFIG_HOME/kustomize/plugin/rakuten.tv/v1/simplesops && \
    curl -sSL -o $XDG_CONFIG_HOME/kustomize/plugin/rakuten.tv/v1/simplesops/SimpleSOPS https://raw.githubusercontent.com/wuakitv/kustomize-simplesops/master/SimpleSOPS && \
    chmod +x $XDG_CONFIG_HOME/kustomize/plugin/rakuten.tv/v1/simplesops/SimpleSOPS

# Add the CI test script
ADD . /
RUN chmod +x /start.sh

# Create the workspace
RUN mkdir /usr/src/k8s
WORKDIR /usr/src/k8s
RUN git clone $GIT_URL && cd !$:t
