vim.lsp.config('nixd', {
  cmd = { "nixd" },
  filetypes = { "nix" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import (builtins.getFlake(toString ./.)).inputs.nixpkgs { }",
      },
      formatting = {
        command = { "alejandra" },
      },
      options = {
        nixos = {
          expr = "let flake = builtins.getFlake(toString ./.); in flake.nixosConfigurations.nixos-btw.options",
        },
        home_manager = {
          expr = "let flake = builtins.getFlake(toString ./.); in flake.nixosConfigurations.nixos-btw.options.home-manager.users.type.functor.payload.options",
        },
      },
    },
  },
})

