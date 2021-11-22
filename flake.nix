{
  description = "Linear vectors in Idris 2";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.idris2-pkgs.url = "github:claymager/idris2-pkgs";

  outputs = { self, nixpkgs, idris2-pkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-darwin" "x86_64-linux" "i686-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ idris2-pkgs.overlay ]; };
        inherit (pkgs.idris2-pkgs._builders) idrisPackage devEnv;
        linear-vector = idrisPackage ./. { };
      in
      {
        defaultPackage = linear-vector;

        packages = { inherit linear-vector; };

        devShell = pkgs.mkShell {
          buildInputs = [ (devEnv linear-vector) ];
        };
      }
    );
}
