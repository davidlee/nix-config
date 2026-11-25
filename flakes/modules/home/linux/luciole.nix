{inputs, ...}: {
  imports = [inputs.luciole.homeModules.default];

  programs.luciole = {
    enable = true;
    settings = {
      browser = {
        view_mode = "grid";
        show_hidden = false;
      };
    };
  };
}
