{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      core.editor = "vim";
      init.defaultBranch = "main";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
