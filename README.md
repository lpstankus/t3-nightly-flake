# T3 Code desktop nightly flake

This flake packages the upstream Linux x86_64 AppImage with Nix. Its GitHub workflow checks upstream releases every six hours, verifies the package builds, and commits a new version and SHA-256 when a nightly is available. The check runs in this packaging repository; it does not update machines that use the flake.

Add this repository as a flake input in your NixOS configuration, then install `inputs.t3-nightly.packages.x86_64-linux.default` through Home Manager or NixOS. `nix flake update --flake /etc/nixos` updates the lock file to the newest published packaging commit. `nixos-rebuild switch --flake /etc/nixos#nixos` installs it. Neither command runs automatically.

The workflow needs GitHub Actions enabled and workflow permissions set to **Read and write permissions** in the repository settings. A protected default branch can block its push; configure a permitted bot update path if branch protection is enabled. You can run `python3 scripts/update.py --check` to inspect the latest nightly without changing the package.
