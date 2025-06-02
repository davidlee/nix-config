{inputs, pkgs, ...}: let
  utils = inputs.nixCats.utils;
in {
  imports = [
    inputs.nixCats.nixosModules.default
  ];
  config = {
    # this value, nixCats is the defaultPackageName you pass to mkNixosModules
    # it will be the namespace for your options.
    nixCats = {
      enable = true;
      # nixpkgs_version = inputs.nixpkgs;
      # this will add an overlay for any plugins
      # in inputs named "plugins-pluginName" to pkgs.neovimPlugins
      # It will not apply to overall system, just nixCats.
      addOverlays = [
        (utils.standardPluginOverlay inputs)
      ];
      # see the packageDefinitions below.
      # This says which of those to install.
      packageNames = ["myNixModuleNvim"];

      luaPath = ./.;

      # the .replace vs .merge options are for modules based on existing configurations,
      # they refer to how multiple categoryDefinitions get merged together by the module.
      # for useage of this section, refer to :h nixCats.flake.outputs.categories
      categoryDefinitions.replace = {
        pkgs,
        settings,
        categories,
        extra,
        name,
        mkPlugin,
        ...
      } @ packageDef: {

        lspsAndRuntimeDeps = with pkgs; {
          # debug = with pkgs; [ ];
          general =[
            lazygit
            ripgrep
            fzf
            fd
            universal-ctags
            ast-grep
            imagemagick
          ];

          python = [
            ruff
          ];

          shell = [
            shfmt
          ];
          
          git = [
            gh
          ];

          ruby = [
            rubocop
            ruby-lsp
          ];
          
          typescript = [
            typescript-language-server
          ];
          
          erlang = [
            beam27Packages.erlang-ls
          ];
          
          rust = [
            rust-analyzer
          ];
          
          zig = [
            zls
            zig-shell-completions
          ];
          
          markdown = [
            marksman
            markdown-oxide
            markdownlint-cli2
          ];
          
          lua = [
            lua-language-server
            stylua
            luarocks
            lua5_1
          ];
          
          nix = [
            nixd
            alejandra
          ];
          
          go = [
            gofumpt
            gopls
            golint
            golangci-lint
            gotools
            go-tools
            go
            delve
          ];
          
        };

        #
        # vimPlugins
        # 
        startupPlugins = {
        
          debug = with pkgs.vimPlugins; [
            nvim-nio
          ];
          
          general = with pkgs.vimPlugins; {
          
            always = [
              lze
              lzextras
              snacks-nvim
              # onedark-nvim
              # vim-sleuth
            ];
            
            extra = [
              oil-nvim
              nvim-web-devicons
            ];
          };

          # themer = with pkgs; [
          #   # you can even make subcategories based on categories and settings sets!
          #   (builtins.getAttr packageDef.categories.colorscheme {
          #       "onedark" = onedark-vim;
          #       "catppuccin" = catppuccin-nvim;
          #       "catppuccin-mocha" = catppuccin-nvim;
          #       "tokyonight" = tokyonight-nvim;
          #       "tokyonight-day" = tokyonight-nvim;
          #     }
          #   )
          # ];
        };
        
      # not loaded automatically at startup.
      # use with packadd and an autocommand in config to achieve lazy loading
      # or a tool for organizing this like lze or lz.n!
      # to get the name packadd expects, use the
      # `:NixCats pawsible` command to see them all
        optionalPlugins = {
        
          debug = with pkgs.vimPlugins; {
            # it is possible to add default values.
            # there is nothing special about the word "default"
            # but we have turned this subcategory into a default value
            # via the extraCats section at the bottom of categoryDefinitions.
            default = [
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
            ];
            
            go = [ 
              nvim-dap-go 
            ];
          };
        
          lang = with pkgs.vimPlugins; {
            typescript = [
            
            ];
            
            markdown = [
              markdown-preview-nvim
              vim-markdown-toc
            ];

            go = [

            ];

            lua = [
              lazydev-nvim
            ];

          };

          lsp = with pkgs.vimPlugins; [
            nvim-lspconfig
          ];

          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
            # This is for if you only want some of the grammars
            # (nvim-treesitter.withPlugins (
            #   plugins: with plugins; [
            #     nix
            #     lua
            #   ]
            # ))
          ];
            
          general = with pkgs.vimPlugins; {
         
            always = [
              nvim-surround
            ];

            extra =  [
              # If it was included in your flake inputs as plugins-hlargs,
              # this would be how to add that plugin in your config.
              # pkgs.neovimPlugins.hlargs
            ];
            
            completion = [
              luasnip
              cmp-cmdline
              blink-cmp
              blink-compat
              colorful-menu-nvim
            ];

            frameworks = [
              mini-nvim
            ];
            
            ui = [
              lualine-nvim
              gitsigns-nvim
              lualine-lsp-progress
              nvim-web-devicons
              colorful-menu-nvim
            ];

            amenities = [
              fidget-nvim
              which-key-nvim
              vim-startuptime
              vim-sleuth
              oil-nvim
            ];

            editor = [
              comment-nvim
              undotree
              indent-blankline-nvim
              undotree
            ];

            movement = [
              fzf-lua
              leap-nvim
            ];
            
            git = [
              vim-fugitive
              vim-rhubarb
            ];

            lint = [
              nvim-lint
            ];

            format = [
              conform-nvim
              vim-prettier
            ];

            # lang.lua?
            neonixdev = [
              lazydev-nvim
            ];
          };
        };
        
        # shared libraries to be added to LD_LIBRARY_PATH
        # variable available to nvim runtime
        sharedLibraries = {
          general = with pkgs; [
            # libgit2
          ];
        };
        environmentVariables = {
          # test = {
          #   CATTESTVAR = "It worked!";
          # };
        };
        extraWrapperArgs = {
          # test = [
          #   ''--set CATTESTVAR2 "It worked again!"''
          # ];
        };
        # lists of the functions you would have passed to
        # python.withPackages or lua.withPackages

        # get the path to this python environment
        # in your lua config via
        # vim.g.python3_host_prog
        # or run from nvim terminal via :!<packagename>-python3
        python3.libraries = {
          test = _: [];
        };
        # populates $LUA_PATH and $LUA_CPATH
        extraLuaPackages = {
          test = [(_: [])];
        };
      };

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions.replace = {
        # These are the names of your packages
        # you can include as many as you wish.
        myNixModuleNvim = {
          pkgs,
          name,
          ...
        }: {
          # they contain a settings set defined above
          # see :help nixCats.flake.outputs.settings
          settings = {
            suffix-path = true;
            suffix-LD = true;
            wrapRc = false;
            # unwrappedCfgPath = "/path/to/config";

            # IMPORTANT:
            # your alias may not conflict with your other packages.
            aliases = [ "vi" "vim" "ncats" ];
            neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
          };

          # TODO do these refer to startupPlugins? optionalPlugins? ...
          
          # and a set of categories that you want
          # (and other information to pass to lua)
          categories = {
            general = true;
            python = true;
            shell = true;
            git = true;
            lua = true;
            nix = true;
            go = false;
          };
          
        };
      };
    };
  };
}
