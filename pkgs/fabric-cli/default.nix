{ lib, buildGoModule, fetchFromGitHub, meson, ninja }:

buildGoModule rec {
  pname = "fabric-cli";
  version = "0.0.2-unstable-2025-08-24";

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric-cli";
    rev = "9f5ce4d46e146e2d3689de730cda78c75a123fb9";
    hash = "sha256-C4JO82RMuEh+S+MUUHuBaPuDhv48QKBlxRqYgrjyqPk=";
  };

  vendorHash = "sha256-5luc8FqDuoKckrmO2Kc4jTmDmgDjcr3D4v5Z+OpAOs4=";

  # fabric-cli uses meson as its build system, but for Nix we build
  # directly with `go build` via buildGoModule. We skip meson entirely.
  # The Go source lives in src/
  subPackages = [ "src" ];

  # Rename the binary from "src" to "fabric-cli"
  postInstall = ''
    mv $out/bin/src $out/bin/fabric-cli
  '';

  meta = with lib; {
    description = "An alternative super-charged CLI for Fabric";
    homepage = "https://github.com/Fabric-Development/fabric-cli";
    license = licenses.agpl3Only;
    mainProgram = "fabric-cli";
  };
}
