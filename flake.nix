{
  description = "Typst development environment with tinymist LSP and Neovim integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Small Neovim plugin: typst helpers + tinymist LSP setup
          typst-nvim-plugin = pkgs.vimUtils.buildVimPlugin {
            pname = "typst-nvim";
            version = "0.1.0";
            src = ./plugin;
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.typst
              pkgs.tinymist
              pkgs.zathura
            ];

            shellHook = ''
              echo "typst $(typst --version)"
              echo "tinymist available: $(which tinymist)"
              echo ""
              echo "Neovim plugin at: ${typst-nvim-plugin}"
              echo "Add it to your neovim runtimepath or copy plugin/typst.lua"
              echo "into your own config."
            '';
          };
        }
      );

      # Expose the plugin as a package so you can reference it from your
      # NixOS/home-manager neovim config, e.g.:
      #   programs.neovim.plugins = [ typst-flake.packages.${system}.typst-nvim-plugin ];
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          typst-nvim-plugin = pkgs.vimUtils.buildVimPlugin {
            pname = "typst-nvim";
            version = "0.1.0";
            src = ./plugin;
          };
        }
      );
    };
}
