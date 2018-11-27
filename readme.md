## Useful Scripts

A collection of bash scripts to help developer in their dayly working.

### General Scripts

#### alias-create

To use the command:

1. create a file that contains the aliases you want to create
```bash
cat > aliases_profile << EOF
new-alias='ssh user@192.168.0.1'
EOF
```
2. execute the command _alias-create_
```bash
alias-create -f aliases_profile
```
3. load the new alias created with the following command
```bash
source ~./.bash_profile
```

### Liferay Scripts