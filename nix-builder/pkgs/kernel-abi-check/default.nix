{
  lib,
  rustPlatform,
}:

let
  version =
    (builtins.fromTOML (builtins.readFile ../../../kernel-abi-check/kernel-abi-check/Cargo.toml))
    .package.version;
  cargoFlags = [
    "-p"
    "kernel-abi-check"
  ];
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "kernel-abi-check";

  src =
    let
      sourceFiles =
        file:
        file.name == "Cargo.toml"
        || file.name == "Cargo.lock"
        || file.name == "manylinux-policy.json"
        || file.hasExt "rs"
        || file.name == "stable_abi.toml";
    in
    import ../crate-dirs.nix {
      inherit lib sourceFiles;
    };

  cargoLock = {
    lockFile = ../../../Cargo.lock;
    outputHashes = {
      "huggingface-hub-0.0.1" = "sha256-0HjQUEAH/EiG8/1snEWYRteidR+zJq0yct164+6K+IY=";
    };
  };

  cargoBuildFlags = cargoFlags;
  cargoTestFlags = cargoFlags;

  setupHook = ./kernel-abi-check-hook.sh;

  meta = {
    description = "Check glibc and libstdc++ ABI compat";
  };
}
