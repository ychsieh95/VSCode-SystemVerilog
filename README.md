# SystemVerilog - Language Support

English (en-US) | [繁體中文（台灣）](README.zh-TW.md)

A VS Code extension for reading, navigating, and writing Verilog and SystemVerilog. This repository declares version **0.13.12**, extension ID **`Holey.systemverilog`**, and VS Code compatibility **`^1.61.0`**.

## Features

| Feature | Behavior |
| --- | --- |
| Syntax highlighting | TextMate grammar, language configuration, file icons, and Verilog/SystemVerilog Markdown code block highlighting. |
| Snippets | Common constructs including modules, interfaces, classes, tasks, functions, assertions, `always_ff`, `always_comb`, loops, and data declarations. |
| Document symbols | Outline and Go to Symbol in Editor use the symbol parser. |
| Workspace symbols | Indexed modules, interfaces, programs, classes, packages, and other detected declarations are available through Go to Symbol in Workspace. |
| Definition navigation | Go to Definition resolves symbols, including named port connections and package-qualified names, using document and workspace symbols. |
| References | Find All References compares indexed candidates with their resolved definitions; coverage depends on indexing precision. |
| Hover | Shows the source line of the first resolved definition. |
| Module instantiation | Choose an indexed module and insert named port connections and parameter overrides at the cursor. |
| Formatting | Format Document and Format Selection call an external formatter, defaulting to `verible-verilog-format`. |
| Diagnostics | Optional built-in ANTLR syntax checks and external Verilator, VCS, or Verible diagnostics appear in Problems. |
| Index caching | Workspace symbol data is saved in VS Code workspace state and loaded on subsequent activation. |
| Task integration | Contributed problem matchers recognize Questa/ModelSim, Verilator, and Verible output from user-defined tasks. |

## Supported files

| Files | Language ID | Support |
| --- | --- | --- |
| `.sv`, `.svh` | `systemverilog`, `systemverilogheader` | Highlighting, snippets, navigation, indexing, formatting, optional diagnostics. |
| `.v`, `.vh` | `verilog`, `verilogheader` | Highlighting, snippets, navigation, indexing, formatting, optional diagnostics. |
| `.va`, `.vams` | `veriloga`, `verilogams` | Highlighting and registered editor providers; external tool support depends on the backend. Excluded from the default workspace indexing glob; ANTLR verification rejects these language IDs. |
| `.f` | `verilog-filelist` | File list highlighting and language configuration. |
| `.sdc`, `.xdc` | `sdc`, `xdc` | Constraint highlighting and language configuration. |

## Getting started

1. Install this extension from a built VSIX using **Extensions: Install from VSIX...**, or run it from source as described below.
2. Open a project folder containing `.sv`, `.v`, `.svh`, or `.vh` files. Opening a folder is required to initialize external compilation.
3. Wait for the SystemVerilog status bar to show the indexed object count. Click it or run **SystemVerilog: Build index of modules in workspace** to rebuild.
4. VS Code provides these commands: **Go to Symbol in Editor**, **Go to Symbol in Workspace**, **Go to Definition**, and **Find All References**. Hover over a resolved symbol to preview its declaration.
5. For linting or formatting, install the desired external tools separately. Configure `.vscode/settings.json`.

No external compiler is needed for highlighting, snippets, symbol navigation, or built-in ANTLR checks. Verilator, VCS, and Verible are not bundled. External tools must be available in the extension host environment, including when working remotely.

## Commands

Open the Command Palette to run these commands:

| Command | ID | Use |
| --- | --- | --- |
| SystemVerilog: Build index of modules in workspace | `systemverilog.build_index` | Rescan configured files and rebuild workspace symbols. |
| SystemVerilog: Auto instantiate modules in workspace | `systemverilog.auto_instantiate` | Select an indexed module and insert an instance into the active editor. Keep the selection empty. |
| SystemVerilog: Compile the opened document | `systemverilog.compile` | Run the selected external diagnostic backend on the active file. Save edits first. |

Generated instances use named port connections with matching signal names. Parameterized modules include parameter overrides derived from their header. Review the generated instance, especially for complex declarations and expressions.

## Configuration

Set options in user settings or `.vscode/settings.json`. This example enables compile-on-save; it is disabled by default:

```json
{
  "systemverilog.includeIndexing": ["**/*.{sv,v,svh,vh}"],
  "systemverilog.excludeIndexing": "**/{synth,pnr}/**",
  "systemverilog.documentSymbolsPrecision": "full",
  "systemverilog.compilerType": "Verilator",
  "systemverilog.compileOnSave": true,
  "systemverilog.antlrVerification": false,
  "systemverilog.formatCommand": "verible-verilog-format",
  "[systemverilog]": {
    "editor.defaultFormatter": "Holey.systemverilog"
  },
  "[verilog]": {
    "editor.defaultFormatter": "Holey.systemverilog"
  }
}
```

For Verible linting, set `systemverilog.compilerType` to `Verible` and use `systemverilog.launchConfigurationVerible`. For VCS, select `VCS` and configure `systemverilog.launchConfigurationVCS` with the arguments your project requires. The extension appends the active file path to the selected launch command; add include directories, defines, or file lists yourself. Compiler commands do not implement the formatter's placeholder substitution.

To enable built-in syntax checking on edits and on open, set both `systemverilog.antlrVerification` and `systemverilog.verifyOnOpen` to `true`. `verifyOnOpen` alone does not enable verification.

### Settings reference

Defaults below come from `package.json`.

| Setting | Type | Default | Purpose |
| --- | --- | --- | --- |
| `systemverilog.disableIndexing` | `boolean` | `false` | Disable automatic startup indexing when no saved index is available. |
| `systemverilog.parallelProcessing` | `integer` | `10` | Number of files processed concurrently during indexing. |
| `systemverilog.includeIndexing` | `array` | `["**/*.{sv,v,svh,vh}"]` | Array of glob patterns included in workspace indexing. |
| `systemverilog.excludeIndexing` | `string` | `""` | Glob pattern excluded from indexing. |
| `systemverilog.forceFastIndexing` | `boolean` | `false` | Force fast regular expression indexing. |
| `systemverilog.enableIncrementalIndexing` | `boolean` | `true` | Update the index when files are saved or become active. |
| `systemverilog.maxLineCountIndexing` | `integer` | `2000` | Use fast indexing for files exceeding this line count. |
| `systemverilog.documentSymbolsPrecision` | `string` | `"full"` | Symbol detail: `full`, `full_no_references`, `declaration`, or `fast`. |
| `systemverilog.compilerType` | `string` | `"Verilator"` | Diagnostic backend: `Verilator`, `VCS`, or `Verible`. |
| `systemverilog.excludeCompiling` | `string` | `""` | Glob pattern checked for compile-on-save; matched against the document URI. |
| `systemverilog.launchConfigurationVerilator` | `string` | `"verilator --sv --lint-only --language 1800-2012 --Wall"` | Verilator executable and arguments. |
| `systemverilog.launchConfigurationVCS` | `string` | `"vcs"` | VCS executable and arguments. |
| `systemverilog.launchConfigurationVerible` | `string` | `"verible-verilog-lint"` | Verible lint executable and arguments. |
| `systemverilog.formatCommand` | `string` | `"verible-verilog-format"` | Formatter executable and arguments. |
| `systemverilog.compileOnSave` | `boolean` | `false` | Run the selected external tool on save. |
| `systemverilog.trace.server` | `string` | `"off"` | Language server trace level: `off`, `messages`, or `verbose`. |
| `systemverilog.antlrVerification` | `boolean` | `false` | Enable built-in ANTLR syntax checks on edits. |
| `systemverilog.verifyOnOpen` | `boolean` | `false` | Check opened documents with ANTLR; also requires `antlrVerification`. |
| `systemverilog.compileOnOpen` | `boolean` | `false` | Run the selected external tool when a document opens. |

### Indexing precision and performance

- `full`: declarations, nested constructs, ports, parameters, methods, typedefs, defines, labels, instantiations, assertions, and reference candidates.
- `full_no_references`: similar declaration coverage without reference candidates; Find All References loses coverage.
- `declaration`: reduced declaration parsing. The accepted setting value is singular: `declaration`.
- `fast`: common block names such as modules, classes, interfaces, packages, and programs, without hierarchy.

Large workspaces automatically use reduced parsing based on file count and `parallelProcessing`. Files longer than `maxLineCountIndexing` also use fast parsing. Exclude generated netlists or build folders to reduce CPU and memory use. Rebuild the index after changing indexing settings. If document symbol behavior still uses the previous configuration, reload the window.

Include patterns starting with `*` are searched through VS Code's workspace file search; other patterns use filesystem globbing. Use `**/rtl/**/*.{sv,v,svh,vh}` for workspace-relative RTL or an absolute path for an external source tree. Additional file extensions require both a language association and an indexing pattern:

```json
{
  "files.associations": {
    "*.svp": "systemverilog",
    "*.svi": "systemverilog"
  },
  "systemverilog.includeIndexing": ["**/*.{sv,v,svh,vh,svp,svi}"]
}
```

### Formatter behavior

`systemverilog.formatCommand` accepts the executable followed by arguments. The provider sends the full editor text to standard input and uses `--lines=start-end` for selection formatting. It runs in the document's directory for saved files.

Supported formatter placeholders are `${workspaceRoot}`, `${workspaceFolder}`, `${cwd}`, and `${env.NAME}`. The environment form uses a dot, for example `${env.VERIBLE_HOME}`. The command is split on whitespace, so quoting does not make executable paths containing spaces work. Use an executable on `PATH` or a path without spaces.

## Build tasks

User-defined `.vscode/tasks.json` tasks can use the following contributed problem matchers:

- Questa/ModelSim: `$vlog-error`, `$vlog-warn`, `$vlog-info`, `$vsim-error`, `$vsim-warning`, `$vsim-info`.
- Verilator: `$verilator-error`, `$verilator-warning`, `$verilator-error-v5`, `$verilator-warning-v5`.
- Verible: `$verible-error`, `$verible-warning`, `$verible-info`.

For example:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Questa: compile",
      "type": "shell",
      "command": "vlog",
      "args": ["-sv", "${file}"],
      "problemMatcher": ["$vlog-error", "$vlog-warn", "$vlog-info"]
    }
  ]
}
```

Task problem matchers are separate from the three diagnostic backends. Providing Questa/ModelSim matchers does not add a Questa backend to `compilerType`.

## Implementation and limitations

The extension client registers navigation, hover, formatting, and module instantiation providers. `src/parser.ts` uses regular expressions for symbols, and `src/indexer.ts` maintains the workspace index. A separate IPC language server in `src/server.ts` publishes ANTLR and external tool diagnostics.

- Symbol resolution is heuristic, rather than full semantic analysis or elaboration. Complex syntax may produce incomplete or ambiguous navigation results.
- Completion and a module hierarchy tree have work-in-progress code under `src/wip`, but are not registered as active features. Snippets are available; semantic IntelliSense completion is not implemented.
- ANTLR preprocessing replaces local macro text and removes `ifdef`/`ifndef` blocks. It is not a complete preprocessor, may skip conditional code, and may shift reported locations. Do not assume full IEEE compliance.
- External compilation reads the saved file on disk, not the unsaved editor buffer. Its initialization uses the first workspace folder, so multi-root compilation has limited workspace handling. Formatting chooses the document's workspace instead.
- `excludeCompiling` is applied to compile-on-save; manual compilation and compile-on-open do not check it.
- Verible style findings from the built-in backend are published as informational diagnostics. Task matchers can assign different severity.
- Diagnostics from ANTLR and external tools share the same document diagnostic channel and can overwrite each other.
- This extension provides editor support and command integrations; it does not provide a simulation UI, waveform viewer, or debugger for HDL.

If symbols appear stale or incomplete, rebuild the index. Check include/exclude patterns and precision. For formatter failures, check the executable path and source syntax. For external diagnostics, verify the configured command in the extension host environment and inspect the **SystemVerilog** / **SystemVerilog Language Server** Output channels.

## Development

Install Node.js/npm. Install a Java runtime for the ANTLR generator. Run these commands:

```bash
npm ci
npm run compile
npm run webpack:dev
```

`compile` regenerates the TextMate JSON grammar and ANTLR TypeScript parser, then compiles TypeScript. `webpack:dev` bundles the client and server. Launch **Client + Server** from VS Code's Run and Debug panel to debug both processes. The server debugger uses port `6009`.

Useful checks and release build:

```bash
npm run lint
npm test
npm run coverage
npm run vscode:prepublish
```

`npm test` compiles the project and launches the VS Code Electron integration tests, downloading stable VS Code when needed. A graphical environment or virtual display is needed for Electron. `vscode:prepublish` compiles and creates production bundles in `dist/client` and `dist/server`; packaging as VSIX is a separate step using VS Code extension packaging tooling.

| Location | Responsibility |
| --- | --- |
| `src/extension.ts` | Client activation, provider registration, commands, index cache. |
| `src/parser.ts`, `src/indexer.ts`, `src/symbol.ts` | Symbol detection, workspace indexing, symbol representation. |
| `src/providers/` | Navigation, references, hover, formatting, instantiation. |
| `src/server.ts`, `src/compiling/` | Language server, ANTLR verification, external diagnostics. |
| `syntaxes/`, `configs/`, `snippets/` | Highlighting, language configuration, snippets. |
| `src/test/` | Integration tests and parser/compiler fixtures. |
| `build/` | Client and server webpack configuration. |

See [CHANGELOG.md](CHANGELOG.md) for release history and [LICENSE](LICENSE) for the MIT license.
