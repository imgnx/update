# `update`

Utility Processing, Dispatching, And Transformation Engine

Powered with 🥄 by \[[**@imgnx**](https://github.com/imgnx)\]

<p align="left">
    <a href="https://github.com/imgnx/up">
        <img src="https://opengraph.githubassets.com/1/imgnx/up" alt="up GitHub repository Open Graph image" width="200" />
    </a>
</p>

<!-- prettier-ignore -->
`up` is designed to help you manage and update your scripts easily. It watches your source code for changes, compiles it, and installs it on your `$PATH`.

<div style="font-size: 1.5em;"><b>Installation</b></div>

Setup.sh

```sh
curl -s https://raw.githubusercontent.com/imgnx/up/main/setup.sh | bash -s -- "$HOME/bin/up"
```

```sh
# Ensure $HOME/bin is on your PATH



```

<div style="display: flex; gap: 0.5em; align-items: center;">
<a href="https://github.com/imgnx/up/blob/main/LICENSE">
    <img alt="GitHub license" src="https://img.shields.io/github/license/imgnx/up" />
</a>
<a href="https://github.com/imgnx/up/issues">
    <img alt="GitHub issues" src="https://img.shields.io/github/issues/imgnx/up" />
</a>
<a href="https://github.com/imgnx/up/stargazers">
    <img alt="GitHub stars" src="https://img.shields.io/github/stars/imgnx/up?style=social" />
</a>
<a href="https://github.com/imgnx/up/network/members">
    <img alt="GitHub forks" src="https://img.shields.io/github/forks/imgnx/up?style=social" />
</a>
</div>

## Usage

### Command

<pre>
<span style="color: #BBB">up</span> <span style="color: cyan">[&lt;source&gt;]</span> <span style="color: yellow">&lt;handle&gt;</span> <span style="color: magenta">[-ufo]</span>
<code>
<span style="color: #BBB">up</span> <sub style="color:#808080;">[command]</sub>
<span>&lt;source&gt;</span> <sub style="color:#808080;">[optional: directory/file to watch]</sub>
<span>&lt;handle&gt;</span> <sub style="color:#808080;">[optional: command to update]</sub>
<span>-ufo</span> <sub style="color:#808080;">[flags]</sub>
</code>
</pre>

### Examples

```1sh
update myfile.js build-command -uf
    update script.py -ufo
```

## Arguments

- `<source>` (opt.): The folder containing update to watch and sync.

- `handle` (opt.): The name for the command. Defaults to the folder name.

Features:

- Automatically copies update when changes are detected.
- Installs the script to ~/bin for easy access.
- Press Ctrl+C to stop watching.

Example: update (~/my-scripts) # Watches ~/my-scripts/update update . mycmd # Watches ~/my-scripts/update and
installs as 'mycmd'

<!-- prettier-ignore -->
## Terms

- `update`: The argument passed to the CLI to invoke the updater.
- `command`: The main script to be processed and updated.
- `handle`: The argument passed to the CLI to invoke the command.

| Condition                         | Result                                                                                                                                                                                                                                                            |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 👍 No argument passed to `update` | <table><thead><th>Condition</th><th>Result</th></thead><tbody><tr><td>👍 `main.*` exists</td><td><mark>The name of the current directory</mark><br /> `basename "$(pwd)"`</td></tr><tr><td>👎 `main.*` does **not** exist</td><td>Error</td></tr></tbody></table> |

| Condition(s)                                                                     | Handle                                                                   |
| -------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| <ul><li>No argument passed to `update`</li><li>`main.*` exists</li></ul>         | <mark>The name of the current directory</mark><br /> `basename "$(pwd)"` |
| <ul><li>No argument passed to `update`</li><li>`main.*` does not exist</li></ul> | <mark>The name of the current directory</mark><br /> `basename "$(pwd)"` |

- Order of Prioritization:
  1. If no argument is passed to `update`... a. If `$pwd/main.*` exists.
  2. If `$1` in `update $1` is a directory... a. If `$1` contains a `main.*` file, then <mark>the name of the
     directory</mark>.

3. If `$1` in `update $1` is a file... a. If `$1` has a name other than `main`, then <mark>the name of the
   file</mark>. invoke a bundled script.

- `main`: The entry point — or the "main" script file that is (to be) executed.
  - Must use a _**known extension**_ of a compilable scripting language.
- `src`: The "source" directory where the main script and its dependencies are stored and edited.
- `src/dist`: The "source distribution" directory where the bundled output (with its dependencies) are stored.
- `src/bin`: The "source binary" directory containing the compiled script and its dependencies.
- `bin`: The binary file where the final, compiled script is placed.

## Conditions

- The `update` command should be run from the directory containing the main script (e.g., `main.sh`,
  `main.js`, etc.).
- The script should be able to handle various file extensions for the main script, such as `.sh`, `.js`,
  `.py`, etc.

1. update should check the current directory for main.sh (or any other executable named main.\*.
2. It should copy the bundled output\* (which should include any other imports) to
   "$HOME/src/$handle/src/main.[sh,etc.]" where ...

- `$handle` is "$(basename "$(pwd)")" of main.[sh,etc.].

3. Compile `$HOME/src/$(basename "$(pwd)")/src/main.[sh,etc.]` to `$HOME/src/$handle/bin/main`

4. Copy `$HOME/src/$(basename "$(pwd)")/bin/main` to `$HOME/bin/$handle` \*\*

<!-- prettier-ignore -->
<small>* Not to exceed `100MB`, otherwise, user is required to use the `--force` flag.</small>

<!-- prettier-ignore -->
<small>** If `bin` already exists, `update` calculates the percentage of difference between the old and new `bin` files, and if the difference is greater than 50%, it will sound the terminal bell (`tput bel`), and prompt the user <mark>to confirm that they know they are making a large contribution </mark>and continue with the update.
</small>

<style>
    mark {
        background-color: rgb(150,75,150);
        color: #FFFFFF;
        padding-left: 0.2em;
        padding-right: 0.2em;
        font-weight: 500;
    }
    code {
        font-weight: 500;
    }
    error {
        color: red;
        font-weight: 500;
    }
</style>

License: [0BSD](https://opensource.org/licenses/0BSD)
