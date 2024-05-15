# Zellij

## Session resurrection

> https://github.com/zellij-org/zellij/pull/2801

## Saving zellij session to a file
```bash
zellij --session inventive-diplodocus action dump-layout >z-session.ks
```

## Restoring zellij session from a file
```bash
zellij --layout z-session.ks
```
