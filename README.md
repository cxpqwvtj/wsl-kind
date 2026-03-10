# wsl-kind

Ubuntu-24.04 をインストールする。

```bat
wsl --install -d Ubuntu-24.04 --no-launch
rem 新規インストールした場合はWindowsを再起動

rem userユーザー作成
wsl -u root -- bash -c "if ! id user >/dev/null 2>&1; then echo 'userユーザーを作成します。' && useradd -m -s /bin/bash user && echo 'user:user' | chpasswd && usermod -aG sudo user && echo '[boot]' > /etc/wsl.conf && echo 'systemd=true' >> /etc/wsl.conf && echo '[user]' >> /etc/wsl.conf && echo 'default=user' >> /etc/wsl.conf; fi"
rem sudoでパスワード入力なし設定にする
wsl -u root -- bash -c "if ! [ -f /etc/sudoers.d/user ]; then echo userユーザーにsudoなし実行権限を付与します。 && echo 'user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/user && chmod 440 /etc/sudoers.d/user; fi"
```

ここからWSL上で実行する

```bash
# git clone
git clone https://github.com/cxpqwvtj/wsl-kind.git
# gtiのセットアップ
# setup-wsl-git.sh を作成して実行する
./setup-wsl-git.sh
# WSLのセットアップ
./setup-wsl.sh
# クラスターの作成のみ
# kind create cluster --config=./kind-config.yaml
# kubeconfigコピー
cat ~/.kube/config | clip.exe
```

## その他のコマンド

sudo実行時にパスワードを必要とする設定に戻す

```bash
# WSL上で実行する
sudo rm /etc/sudoers.d/user
```

ディストリビューションが複数する場合はデフォルトを設定

```bat
wsl --set-default Ubuntu-24.04
```

ディストリビューション削除

```bat
wsl --unregister Ubuntu-24.04
```
