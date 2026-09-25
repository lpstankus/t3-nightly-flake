# T3 Code desktop nightly flake

This flake packages the upstream Linux x86_64 AppImage with Nix. Its GitHub workflow checks upstream releases every six hours, verifies the package builds, and commits a new version and SHA-256 when a nightly is available. The check runs in this packaging repository; it does not update machines that use the flake.

Add this repository as a flake input in your NixOS configuration. In your Home Manager module:

```nix
{
  imports = [ inputs.t3-nightly.homeManagerModules.default ];
  programs.t3codeNightly.enable = true;
}
```

This installs the package and manages its visible `com.t3tools.T3Code.desktop`
launcher and URL handlers. It prevents T3's startup registration from replacing
the launcher with a hidden entry pointing at an unwrapped Electron executable.
An existing generated launcher may need to be backed up before the first Home
Manager activation. Remove any old `xdg.desktopEntries."com.t3tools.T3Code"`
override so there is only one owner of the launcher.

The package alone is also available as
`inputs.t3-nightly.packages.x86_64-linux.default`, but the Home Manager module is
recommended for persistent GNOME integration. With the managed launcher, T3 may
log that its own URL-handler rewrite failed; Home Manager already supplies the
correct handler and the app continues normally.

From `/etc/nixos`, `nix flake update t3-nightly` updates the lock file to the newest
published packaging commit. `nixos-rebuild switch --flake /etc/nixos#nixos`
installs it. Neither command runs automatically.

The workflow needs GitHub Actions enabled and workflow permissions set to **Read and write permissions** in the repository settings. A protected default branch can block its push; configure a permitted bot update path if branch protection is enabled. You can run `python3 scripts/update.py --check` to inspect the latest nightly without changing the package.
