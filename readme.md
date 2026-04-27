# diary

Simple personal journal manager.

## installation

Installation and uninstallation can be performed with `make`.

```console
$ git clone https://github.com/cowtoolz/diary && cd diary
# make install
# make uninstall
```

## usage

Create a new entry and start editing:

```console
$ diary
[INFO] Created new entry ~/diary/2026/04/27.md
```

### configuration

By default, diary is configured for daily journaling. Configuration for diary is done with environment variables.

- `DIARY_DIR`: The root of your journal and `diary.conf`. You should set this globally (in your `.profile`, `.zshrc`, etc). Defaults to `~/diary`.

A `diary.conf` will be created in your `DIARY_DIR`; edit it to override the default configuration. See [`sample.conf`](./sample.conf) for an example.

- `EDITOR`: The editor command used to write the entry. Can be set in `diary.conf` to override your global `EDITOR`. Must accept the format `EDITOR entry_path`.
- `ENTRY_PATH`: Determines the path of entries. Defaults to `$(date '+%Y/%m/%d').md` (which will create entries at e.g. `$DIARY_DIR/2026/04/27.md`).
- `PREFILL`: Prefill the entry with some text. Defaults to the current date and time (e.g. `# Monday 27 April, 2026 11:37 AM`).
- `PREFILL_EDIT`: Prefill to append when continuing an existing entry (i.e. using diary again in the same day). Empty by default.
- `USE_EDITOR`: Whether or not to open `EDITOR` after creating the entry. Defaults to `true` if `EDITOR` is set.
- `HOOK`: A command to run after editing is finished. Disabled by default.
