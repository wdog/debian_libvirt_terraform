# TERRAFORM + DEBIAN 11 + LIBVIRT

rename the files to preseed.cft

- preseed.cfg.crypt 
- preseed.cfg.plain


```
# generate modified netinstall iso 
./gen.sh
```

```
terraform init
terraform plan sshfs -auto-approve
terraform apply -auto-approve
terraform destroy -auto-approve
```