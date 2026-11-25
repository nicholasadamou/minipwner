# Local verification

Docker is the only development prerequisite. From the repository root:

```sh
docker build -t minipwner-test .
docker run --rm --network none --read-only --cap-drop ALL \
  --security-opt no-new-privileges --tmpfs /tmp:rw,nosuid,nodev,size=128m \
  minipwner-test
```

`test.sh` runs ShellCheck on the installer and test script, checks the packaged
MiniModes shell syntax, and executes the real installer in a private temporary tree.
Restricted dependency wrappers allow only approved operations inside that tree;
the payload archive is checked before extraction. The container runs unprivileged,
offline, and read-only apart from its temporary directory. No Docker socket or
host directories are mounted.

The checks compare extracted content, copied files, permissions, and the startup
symlink. They verify repeated installation, the unchanged package, declined
restart, and rejection of real-root access, staged restarts, missing packages,
and failed commands.

These checks do not flash firmware, reboot a router, emulate OpenWrt, or validate
hardware/network behavior. Test deployment separately on compatible hardware.
There are no hosted workflows, Git hooks, JavaScript tools, or environment managers.
Documentation diagrams render directly on GitHub.
