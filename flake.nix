{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv";    
  };

  outputs = { self, nixpkgs, nixpkgs-ruby, flake-utils, devenv }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rubyVersion = nixpkgs.lib.strings.removePrefix "ruby-"
          (nixpkgs.lib.fileContents ./.ruby-version);

      in
      {
        devShells = with pkgs; {
          default = mkShell {
            motd = "Ruby version is2 ${rubyVersion}";
            buildInputs = [
              nixpkgs-ruby.packages.${system}."ruby-${rubyVersion}"
              bundix
            ];
          };
          ruby_3_1 = mkShell {
            motd = "Ruby version is 3.1.2";
            buildInputs = [
              nixpkgs-ruby.packages.${system}."ruby-3.1.2"
              bundix
            ];
          };
          ruby_3_0 = mkShell {
            motd = "Ruby version is 3.0.4";
            buildInputs = [
              nixpkgs-ruby.packages.${system}."ruby-3.0.4"
              bundix
            ];
          };
        };
      });
}
