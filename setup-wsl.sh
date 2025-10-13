#!/bin/bash

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# ログファイルを設定（標準出力と標準エラー出力の両方をteeでリダイレクト）
LOG_FILE="setup-wsl-$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_DIR/$LOG_FILE")
exec 2>&1

echo "=== setup-wsl.sh 実行開始 $(date) ==="
echo "ログファイル: $LOG_FILE"

# Dockerがインストールされていない場合はインストール
if ! command -v docker &> /dev/null; then
    echo "Dockerがインストールされていません。インストールを開始します..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    sudo gpasswd -a $USER docker
    echo "Dockerのインストールが完了しました。"
    exit 2 # 再起動を促すために終了コード2で終了
else
    echo "Dockerは既にインストールされています。"
fi

# kindがインストールされていない場合はインストール
if ! command -v kind &> /dev/null; then
    echo "kindがインストールされていません。インストールを開始します..."
    # https://kind.sigs.k8s.io/docs/user/quick-start/
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    echo "kindのインストールが完了しました。"
else
    echo "kindは既にインストールされています。"
fi

# kubectlがインストールされていない場合はインストール
if ! command -v kubectl &> /dev/null; then
    echo "kubectlがインストールされていません。インストールを開始します..."
    # https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    kubectl version --client
    echo "kubectlのインストールが完了しました。"
else
    echo "kubectlは既にインストールされています。"
fi

# kindのセットアップ
if ! kind get clusters 2>/dev/null; then
    echo "kind clusterのセットアップを開始します..."
    kind create cluster --config=./kind-config.yaml
    echo "kind clusterのセットアップが完了しました。"
else
    echo "kind clusterは既にセットアップされています。"
fi

echo "=== setup-wsl.sh 実行完了 $(date) ==="
