# TERRAFORM + DEBIAN 11 + LIBVIRT

## Install terraform in VM (libvirt/kvm)


```bash
sudo apt-get install jq unzip vim curl -y
# get version
export TERRA_VERSION=$(curl -sL https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r ".tag_name" | cut -c2-)
# download
wget https://releases.hashicorp.com/terraform/${TERRA_VERSION}/terraform_${TERRA_VERSION}_linux_amd64.zip

#unzip
unzip terraform_${TERRA_VERSION}_linux_amd64.zip

# path + permission
chmod +x terraform
sudo mv terraform /usr/local/bin/.

# check
terraform version
```
### Install libvirt provider

```bash
# make plugins directory
mkdir -p ~/.terraform.d/plugins && cd $_

# download
# wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.14/terraform-provider-libvirt_0.6.14_linux_amd64.zip

# get latest
curl -s https://api.github.com/repos/dmacvicar/terraform-provider-libvirt/releases/latest \
  | grep browser_download_url \
  | grep linux_amd64.zip \
  | cut -d '"' -f 4 \
  | wget -i -


# extract
unzip terraform-provider*.zip
rm *.zip
```

# Build debian netinstall iso


rename one of the files to preseed.cfg 

- preseed.cfg.crypt 
- preseed.cfg.plain

run `gen.sh` to build the **ISO**

```bash
./gen.sh
```

## Run Terraform 

```bash
terraform init
terraform plan sshfs -auto-approve
terraform apply -auto-approve
terraform destroy -auto-approve
```