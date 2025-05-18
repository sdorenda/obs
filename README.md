# observability

## opentofu

If you are like me and use terraform and opentofu on the same machine and want to be able to easily switch between them, you should:

- use tfswitch
- use tgswitch
- use aliases so you dont have to type so much e.g.:
```bash
alias tofp="terragrunt plan -lock=false --terragrunt-tfpath tofu"
alias tofa="terragrunt apply --terragrunt-tfpath tofu"
alias tof="terragrunt --terragrunt-tfpath tofu"
alias tofpall="terragrunt run-all plan --terragrunt-tfpath tofu -lock=false | grep -v \"Refreshing state...\\|Reading...\\|Read complete after\""
```

## rsyslog

config is a file that needs to go into a place it will find it, that may be:

/etc/rsyslog.d/99-rfc5424.conf

and contains:
$ActionForwardDefaultTemplate RSYSLOG_SyslogProtocol23Format

this will tell rsyslog to use rfc5424

