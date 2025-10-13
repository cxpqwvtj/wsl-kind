set DISTRO=Ubuntu-24.04

@echo off

rem WSLに%DISTRO%がインストールされていない場合はインストールする
rem 実行可能かテストする
wsl -d %DISTRO% -- echo "test" >nul 2>&1
if %errorlevel% neq 0 (
    echo %DISTRO% がインストールされていません。インストールを開始します...
    wsl --install -d %DISTRO% --no-launch
    wsl --set-default %DISTRO%
    wsl -l -v
    echo インストールが完了しました。Windowsを再起動してください。
    echo 続行するにはEnterキーを押してください...
    pause >nul
    exit 0
) else (
    echo %DISTRO% は既にインストールされています。
    echo WSLのデフォルト起動ディストリビューションを %DISTRO% に設定します...
    wsl --set-default %DISTRO%
    wsl -l -v
)

echo %DISTRO% を起動します...
wsl -u root -- bash -c "if ! id user >/dev/null 2>&1; then echo 'userユーザーを作成します。' && useradd -m -s /bin/bash user && echo 'user:user' | chpasswd && usermod -aG sudo user && echo '[boot]' > /etc/wsl.conf && echo 'systemd=true' >> /etc/wsl.conf && echo '[user]' >> /etc/wsl.conf && echo 'default=user' >> /etc/wsl.conf; fi"
wsl -u root -- bash -c "if ! [ -f /etc/sudoers.d/user ]; then echo userユーザーにsudoなし実行権限を付与します。 && echo 'user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/user && chmod 440 /etc/sudoers.d/user; fi"
wsl --terminate %DISTRO%

set CURRENT_DIR=%CD%
set WSL_PATH=%CURRENT_DIR:\=/%
set WSL_PATH=%WSL_PATH:C:=/mnt/c%

wsl -- bash -c "mkdir -p ~/dev && cd ~/dev && if [ ! -d 'wsl-kind' ]; then echo 'Windows側のwsl-kindをcloneします...'; git clone '%WSL_PATH%'; else echo 'wsl-kindは既に存在します。クローンをスキップします。'; fi"

rem setup-wsl-git.bat ファイルが存在する場合は実行する
if exist "%CD%\setup-wsl-git.bat" (
    echo setup-wsl-git.bat を実行します...
    call "%CD%\setup-wsl-git.bat"
    echo setup-wsl-git.bat の実行が完了しました。
)

echo WSLの初期設定を実行します...
set RETRY_COUNT=0
:RETRY_SETUP
wsl --cd ~/dev/wsl-kind -- ./setup-wsl.sh
set SETUP_RESULT=%errorlevel%

if %SETUP_RESULT% equ 2 (
    if %RETRY_COUNT% lss 3 (
        set /a RETRY_COUNT+=1
        echo setup-wsl.shが再起動を要求しました（試行回数: %RETRY_COUNT%/3）
        echo ターミナルを再起動してスクリプトを再実行します...
        timeout /t 15 /nobreak >nul
        goto RETRY_SETUP
    ) else (
        echo 最大再試行回数に達しました。手動で確認してください。
    )
)

rem sudoers.d から user ファイルを削除
wsl -- bash -c "if [ -f /etc/sudoers.d/user ]; then echo '/etc/sudoers.d/user ファイルを削除します...' && sudo rm /etc/sudoers.d/user && echo '/etc/sudoers.d/user ファイルを削除しました。'; fi"

echo ""
echo WSLの初期設定wsl-install.batが完了しました。
