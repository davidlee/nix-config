# Outer profile for the user's own machines (DEC-033). Sets defaults only
# (mkDefault), so a host that imports it can override any of them with a plain
# definition. Portable: the editors and every cli-derived feature; none of
# their records has platforms. personal-linux and personal-darwin import it.
{lib, ...}: {
  feature.editor.emacs.enable = lib.mkDefault true;
  feature.editor.neovim.enable = lib.mkDefault true;
  feature.editor.kakoune.enable = lib.mkDefault true;
  feature.editor.misc.enable = lib.mkDefault true;
  feature.notes.terminal.enable = lib.mkDefault true;
  feature.dev.scm.enable = lib.mkDefault true;
  feature.dev.build.enable = lib.mkDefault true;
  feature.dev.runtimes.enable = lib.mkDefault true;
  feature.dev.runners.enable = lib.mkDefault true;
  feature.dev.tools.enable = lib.mkDefault true;
  feature.docs.diagrams.enable = lib.mkDefault true;
  feature.docs.typeset.enable = lib.mkDefault true;
  feature.docs.markdown.enable = lib.mkDefault true;
  feature.docs.help.enable = lib.mkDefault true;
  feature.data.structured.enable = lib.mkDefault true;
  feature.data.hex.enable = lib.mkDefault true;
  feature.files.manage.enable = lib.mkDefault true;
  feature.files.disk.enable = lib.mkDefault true;
  feature.files.archive.enable = lib.mkDefault true;
  feature.files.search.enable = lib.mkDefault true;
  feature.files.sync.enable = lib.mkDefault true;
  feature.net.tools.enable = lib.mkDefault true;
  feature.web.terminal.enable = lib.mkDefault true;
  feature.system.monitor.enable = lib.mkDefault true;
  feature.system.process.enable = lib.mkDefault true;
  feature.text.tools.enable = lib.mkDefault true;
  feature.text.pagers.enable = lib.mkDefault true;
  feature.text.dictionary.enable = lib.mkDefault true;
  feature.office.calc.enable = lib.mkDefault true;
  feature.office.calendar.enable = lib.mkDefault true;
  feature.security.credentials.enable = lib.mkDefault true;
  feature.security.research.enable = lib.mkDefault true;
  feature.media.view.enable = lib.mkDefault true;
  feature.media.convert.enable = lib.mkDefault true;
  feature.graphics.color.enable = lib.mkDefault true;
  feature.comms.feeds.enable = lib.mkDefault true;
  feature.fun.toys.enable = lib.mkDefault true;
  feature.terminal.utils.enable = lib.mkDefault true;
  feature.terminal.zsh.enable = lib.mkDefault true;
  feature.terminal.nushell.enable = lib.mkDefault true;
  feature.terminal.amenities.enable = lib.mkDefault true;
}
