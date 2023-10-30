/*
Contains:
- db_username
- db_password
- jwt_secret

Key generated with:
  age-keygen -o ~/Syncthing/KeePass/age.key

Encrypted with:
  sops --encrypt --age age1zj5u4swk9q6f2kgr5z5m30vz68hhyt5wr59zsd8z2vl6a9hexfnsd5j82w env.json > env.enc.json

Usage:
  export SOPS_AGE_KEY_FILE="$HOME/Syncthing/KeePass/age.key"
*/

data "sops_file" "cidr_env" {
  source_file = "env.enc.json"
}
