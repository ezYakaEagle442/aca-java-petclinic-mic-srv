# Check the JDK version & Installation

## Java-WSL2
```sh
# sudo apt install openjdk-11-jre-headless=11.0.13+8-0ubuntu1~20.04

# https://docs.microsoft.com/en-us/java/openjdk/download
wget https://aka.ms/download-jdk/microsoft-jdk-11.0.13.8.1-linux-x64.tar.gz
tar -xvf microsoft-jdk-11.0.13.8.1-linux-x64.tar.gz


# download public keys
curl -sL https://download.visualstudio.microsoft.com/download/pr/b90071e2-e0cf-4411-98be-dbeb09d67bf0/8622862bcd54206e158c5abca0582c9b/464279_464280_aoc_20210208.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft-mariner-jdk.asc.gpg > /dev/null

wget https://download.visualstudio.microsoft.com/download/pr/b90071e2-e0cf-4411-98be-dbeb09d67bf0/8622862bcd54206e158c5abca0582c9b/464279_464280_aoc_20210208.asc 
gpg --import 464279_464280_aoc_20210208.asc
gpg --list-keys

# verify signatures
# https://aka.ms/download-jdk/microsoft-jdk-11.0.13.8.1-linux-x64.tar.gz.sha256sum.txt
wget https://aka.ms/download-jdk/microsoft-jdk-11.0.13.8.1-linux-x64.tar.gz.sig
gpg --show-keys /etc/apt/trusted.gpg.d/microsoft-mariner-jdk.asc.gpg
gpg --fingerprint
gpg --verify microsoft-jdk-11.0.13.8.1-linux-x64.tar.gz.sig 464279_464280_aoc_20210208.asc

# Edit the .profile file
vim .profile
JAVA_HOME="$HOME/jdk-11.0.13+8"
PATH="$JAVA_HOME/bin:$PATH"

. .profile

java -version
whereis java
which java
# sudo update-alternatives --config java

```

## Java-Chocolatey
```sh
choco install microsoft-openjdk --Yes --accept-license --version 11.0.11.9
# choco install openjdk --Yes --accept-license --version 11.0.2.01
```
# Maven setup
```sh
choco install maven --Yes --confirm --accept-license
# choco install gradle --Yes --confirm --accept-license

```

# Naming conventions
See also [See also https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/considerations/naming-and-tagging](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/considerations/naming-and-tagging)

# Mardown docs

- [https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
- [https://daringfireball.net/projects/markdown/](https://daringfireball.net/projects/markdown/)
- [https://docs.microsoft.com/en-us/contribute/markdown-reference](https://docs.microsoft.com/en-us/contribute/markdown-reference)

# Azure Cloud Shell

You can use the Azure Cloud Shell accessible at <https://shell.azure.com> once you login with an Azure subscription.
See also [https://azure.microsoft.com/en-us/features/cloud-shell/](https://azure.microsoft.com/en-us/features/cloud-shell/)

**/!\ IMPORTANT** Create a storage account for CloudShell in the Region where you plan to deploy your resources and accordingly.
Ex: run CloudShell in France Central Region if you plan do deploy your resources in France Central Region

**/!\ IMPORTANT** CloudShell session idle TimeOut is 20 minutes, you may find WSL/Powershell ISE more confortale.
[https://feedback.azure.com/forums/598699-azure-cloud-shell/suggestions/32240851-fix-increase-cloudshell-timeout](https://feedback.azure.com/forums/598699-azure-cloud-shell/suggestions/32240851-fix-increase-cloudshell-timeout)

[https://medium.com/@navneet.ts/azure-nugget-give-the-cloud-shell-timeout-a-timeout-c486dc544bc3](https://medium.com/@navneet.ts/azure-nugget-give-the-cloud-shell-timeout-a-timeout-c486dc544bc3)

## Uploading and editing files in Azure Cloud Shell

- You can use `vim <file you want to edit>` in Azure Cloud Shell to open the built-in text editor.
- You can upload files to the Azure Cloud Shell by dragging and dropping them
- You can also do a `curl -o filename.ext https://file-url/filename.ext` to download a file from the internet.

# You can Install [Chocolatey](https://chocolatey.org/install) on Windows
```sh
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Logs at C:\ProgramData\chocolatey\logs\chocolatey.log 
# Files cached at C:\Users\%USERNAME%\AppData\Local\Temp\chocolatey
```
# How to install Windows Subsystem for Linux (WSL)

```sh
# https://chocolatey.org/packages/wsl
# choco install wsl --Yes --confirm --accept-license --verbose 
# choco install wsl-ubuntu-1804 --Yes --confirm --accept-license --verbose

choco install wsl2 --Yes --confirm --accept-license
choco install wsl-ubuntu-2004 --Yes --confirm --accept-license --verbose

```

## Upgrade to to WSL 2
See [https://docs.microsoft.com/en-us/windows/wsl/install-win10#update-to-wsl-2](https://docs.microsoft.com/en-us/windows/wsl/install-win10#update-to-wsl-2)
Pre-req: Windows 10, updated to version 2004, **Build 19041** or higher.

```sh
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# reboot
wsl --set-default-version 2

# The update from WSL 1 to WSL 2 may take several minutes to complete depending on the size of your targeted distribution. If you are running an older (legacy) installation of WSL 1 from Windows 10 Anniversary Update or Creators Update, you may encounter an update error. Follow these instructions to uninstall and remove any legacy distributions.

wsl -l -o
wsl --list --verbose
wsl --set-version <distribution name> <versionNumber>
wsl --setdefault <distribution name>

```

## Setup PowerShell in WSL
See :
- [https://docs.microsoft.com/fr-fr/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#ubuntu-1804](https://docs.microsoft.com/fr-fr/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#ubuntu-1804)
- [https://www.saggiehaim.net/powershell/install-powershell-7-on-wsl-and-ubuntu](https://www.saggiehaim.net/powershell/install-powershell-7-on-wsl-and-ubuntu)

https://github.com/PowerShell/PowerShell/blob/master/docs/building/linux.md

```sh
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Enable the "universe" repositories
sudo add-apt-repository universe

# Install PowerShell
sudo apt-get install -y powershell

# restart WSL
pwsh

Get-PSRepository
Install-Module -Name Az

# Create Folder
# sudo mkdir /usr/share/PowerShell
# Change Working Dir
cd /usr/share/PowerShell

# https://github.com/PowerShell/PowerShell/releases/tag/v7.2.1
# sudo wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-7.2.1-linux-x64.tar.gz
# sudo wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-7.2.1-linux-alpine-x64.tar.gz
# sudo tar xzvf powershell-6.1.5-linux-alpine-x64.tar.gz
# sudo rm /usr/share/PowerShell/powershell-6.1.5-linux-alpine-x64.tar.gz

cd #HOME
 
# Edit the .profile file
vim .profile # PATH="$PATH:/usr/share/PowerShell"

# restart WSL
pwsh

```


## How to install Kubectl client into Subsystem for Linux (WSL)

```sh
sudo apt-get install -y apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list 
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
kubectl api-versions

```

## How to install Terraform on Ubuntu or WSL
[see this blog](https://techcommunity.microsoft.com/t5/azure-developer-community-blog/configuring-terraform-on-windows-10-linux-sub-system/ba-p/393845)
[https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started)
```sh
TF_VER=1.1.2
echo "Installing TF version " $TF_VER
sudo apt-get install unzip
wget https://releases.hashicorp.com/terraform/$TF_VER/terraform_${TF_VER}_linux_amd64.zip -O terraform.zip;
unzip terraform.zip
sudo mv terraform /usr/local/bin
rm terraform.zip
terraform version
```

## How to installb HELM on Uuntu or WSL
```sh
# https://helm.sh/docs/intro/install/
# https://git.io/get_helm.sh

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm version
```

# How to install Git bash for Windows 

```sh
# https://chocolatey.org/packages/git.install
# https://gitforwindows.org/
choco install git.install --Yes --confirm --accept-license

```
## Git Troubleshoot

[https://www.illuminiastudios.com/dev-diaries/ssh-on-windows-subsystem-for-linux](https://www.illuminiastudios.com/dev-diaries/ssh-on-windows-subsystem-for-linux)
[https://help.github.com/en/enterprise/2.20/user/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent](https://help.github.com/en/enterprise/2.20/user/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

Check the fingerprint of you SSH key in GitHub with the SSH Key used by git.

If your GIT repo URL starts with HTTPS (ex: "https://github.com/<!XXXyour-git-homeXXX!/spring-petclinic.git"), git CLI will always prompt for password.
When MFA is enabled on GitHub and that you plan to use SSH Keys, you have to use: 
git clone git@github.com:your-git-home/spring-petclinic.git

```sh
eval `ssh-agent -s`
eval $(ssh-agent -s) 
sudo service ssh status
# sudo service ssh --full-restart
ssh-add /home/~username/.ssh/githubkey
ssh-keygen -l -E MD5 -f /home/~username/.ssh/githubkey
ssh -T git@github.com
```

## How to install AZ CLI with Chocolatey
```sh
# https://chocolatey.org/packages/azure-cli
choco install azure-cli --Yes --confirm --accept-license --version 2.32.0
```

## How to install Terraform with Chocolatey
```sh
choco install terraform --Yes --confirm --accept-license
choco upgrade terraform --Yes --confirm --accept-license
```

## Install Azure Bicep CLI

see :
- [https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli)

```sh
az -v
az bicep install
az bicep upgrade
az bicep version
az bicep --help
```

## How to install HELM from RedHat

See [https://docs.openshift.com/aro/4/cli_reference/helm_cli/getting-started-with-helm-on-openshift-container-platform.html](https://docs.openshift.com/aro/4/cli_reference/helm_cli/getting-started-with-helm-on-openshift-container-platform.html)
```sh
# https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest
```

## How to install HELM with Chocolatey
```sh
# https://chocolatey.org/packages/kubernetes-helm
choco install kubernetes-helm --Yes --confirm --accept-license
```

## How to install Kubectl client with Chocolatey
```sh
# https://chocolatey.org/packages/kubernetes-cli
choco install kubernetes-cli --Yes --confirm --accept-license
```


## To run Docker in WSL
The most important part is dockerd will only run on an elevated console (run as Admin) and cgroup should be always mounted before running the docker daemon.

See also :
- [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)
- [https://github.com/Microsoft/WSL/issues/2291](https://github.com/Microsoft/WSL/issues/2291)
- [https://www.reddit.com/r/bashonubuntuonwindows/comments/8cvr27/docker_is_running_natively_on_wsl/](https://www.reddit.com/r/bashonubuntuonwindows/comments/8cvr27/docker_is_running_natively_on_wsl/)
- [https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly](https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly)


run Docker daemon with parameter --iptables=false
you should set this parameter in the configuration file : sudo vim /etc/docker/daemon.json like this:
{
  "iptables":false
}

```sh

#uninstall old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Download and add Docker's official public PGP key.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Verify the fingerprint.
sudo apt-key fingerprint 0EBFCD88

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -Y
apt-cache madison docker-ce

sudo apt update
sudo apt upgrade
# sudo apt install docker.io
sudo docker --version

# sudo cgroupfs-mount
# sudo usermod -aG docker $USER

# https://askubuntu.com/questions/1380051/docker-unrecognized-service-when-installing-cuda
service --status-all
sudo service docker start
sudo service docker status

sudo docker run hello-world

```

## Kube Tools

```sh
# https://kubernetes.io/docs/reference/kubectl/cheatsheet/

# AKS
source <(kubectl completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc 
alias k=kubectl
complete -F __start_kubectl k

# ARO
source <(oc completion bash)
echo "source <(oc completion bash)" >> ~/.bashrc 
complete -F __start_oc oc

alias kn='k config set-context --current --namespace '

export gen="--dry-run=client -o yaml"
# ex: k run nginx --image nginx $gen

# Get K8S resources
alias kp="k get pods -o wide"
alias kd="k get deployment -o wide"
alias ks="k get svc -o wide"
alias kno="k get nodes -o wide"

# Describe K8S resources 
alias kdp="k describe pod"
alias kdd="k describe deployment"
alias kds="k describe service"

```

Optionnaly : If you want to run PowerShell
You can use Backtick ` to escape new Line in ISE

```sh
# If you run kubectl in PowerShell ISE , you can also define aliases :
function k([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl $params }
function kubectl([Parameter(ValueFromRemainingArguments = $true)]$params) { Write-Output "> kubectl $(@($params | ForEach-Object {$_}) -join ' ')"; & kubectl.exe $params; }
function k([Parameter(ValueFromRemainingArguments = $true)]$params) { Write-Output "> k $(@($params | ForEach-Object {$_}) -join ' ')"; & kubectl.exe $params; }
```

## VIM tips

See [vim cheatsheet](https://devhints.io/vim)

```sh
# set ts=2 : ts stands for tabstop. It sets the tab width to 2 spaces.
# sts stands for softtabstop. Insert ou delete 2 spaces with tab or back keys.
# sw stands for shiftwidth. Number of spaces used during indentation > or <
# set et : et stands for expandtab. While in insert mode, it replaces tabs by spaces
vi ~/.vimrc
set ts=2 sw=2 et sts=2
. ~/.vimrc
```


## You can use any tool to run SSH & AZ CLI
```sh

sudo apt-get install -y apt-transport-https
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

##### git bash for windows based on Ubuntu
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt-get update
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | 
    sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update
apt search azure-cli 
apt-cache search azure-cli 
apt list azure-cli -a
sudo apt-get install azure-cli

sudo apt-get update && sudo apt-get install --only-upgrade -y azure-cli
sudo apt-get upgrade azure-cli
az version
az upgrade

az login

```


## Containerd Tools

See :
- [https://docs.microsoft.com/en-us/azure/aks/cluster-configuration#containerd-limitationsdifferences](https://docs.microsoft.com/en-us/azure/aks/cluster-configuration#containerd-limitationsdifferences)
- [https://github.com/kubernetes-sigs/cri-tools](https://github.com/kubernetes-sigs/cri-tools#install-crictl)

```sh
CRICTL_VERSION="v1.22.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$CRICTL_VERSION-linux-amd64.tar.gz
crictl --help
crictl -v
```

Optionnaly : If you want to run PowerShell
You can use Backtick ` to escape new Line in ISE

```sh
# If you run kubectl in PowerShell ISE , you can also define aliases :
function k([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl $params }
function kubectl([Parameter(ValueFromRemainingArguments = $true)]$params) { Write-Output "> kubectl $(@($params | ForEach-Object {$_}) -join ' ')"; & kubectl.exe $params; }
function k([Parameter(ValueFromRemainingArguments = $true)]$params) { Write-Output "> k $(@($params | ForEach-Object {$_}) -join ' ')"; & kubectl.exe $params; }
```