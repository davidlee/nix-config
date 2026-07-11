{inputs, ...}: {
  flake.homeModules.danksearch = {
    imports = [
      inputs.danksearch.homeModules.dsearch
    ];
    programs.dsearch.enable = true;

    # todo: configure what to index
  };
}
