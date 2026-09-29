# Uninstall

**Uninstalling has not been tested on this plugin.** The commands below come from the Claude Code plugin documentation ([Manage installed plugins](https://code.claude.com/docs/en/discover-plugins#manage-installed-plugins) and [Manage marketplaces](https://code.claude.com/docs/en/discover-plugins#manage-marketplaces)), and we checked each one against that page. Nobody has run them on this plugin yet. If one fails, please tell us on the [issues page](https://github.com/nestedmind/larceny/issues).

Remove the plugin, inside Claude Code:

```
/plugin uninstall larceny@larceny
```

This opens the plugin panel and leaves it open. Press Esc to close it. You can also run `/plugin`, open the Installed tab, select the plugin and choose uninstall. From a shell, `claude plugin uninstall larceny@larceny` does the same without the panel. If you installed it for a project, add `--scope project`.

To keep the plugin but turn it off, run `/plugin disable larceny@larceny`. Turn it back on with `/plugin enable larceny@larceny`.

Optionally, remove the marketplace too:

```
/plugin marketplace remove larceny
```

The docs warn that removing a marketplace uninstalls any plugins you installed from it.

Uninstalling does not touch what the plugin's work left behind. Clean these up by hand if they exist:

- Custom agent files in each project's `.claude/agents/` folder. If you renamed the coordinator, a coder, the reviewer, the advisor or the teacher during onboarding, onboarding wrote one `<name>.md` file per renamed persona into that folder. Uninstalling does not remove them, and once the plugin is gone they point at skills that no longer exist. Larceny's files are the ones whose names match the values of `coders:` (its first name is the coordinator), `reviewer:`, `advisor:` and `teacher:` in that project's `.larceny/config.md`. Do this before you delete `.larceny/`, because its config names the files. Delete only those files, because other agent files in the folder may not come from Larceny.
- The `.larceny/` folder in each project where you ran onboarding, and the `.gitignore` line that ignores it.
- An `"agent": "larceny:scofield"` line in `.claude/settings.json`, if you opted in to run Scofield as the main session.
- Coder worktrees and branches in your projects.
- Token files under `~/.config/larceny/`, if you set up persona accounts. Also delete those tokens on GitHub.
- The global crew file `~/.config/larceny/global-config.md`, if you saved your crew globally. It sits in the same folder as the token files. If you set `LARCENY_CONFIG_DIR`, look there.
