# SystemVerilog - Language Support

[English (en-US)](README.md) | 繁體中文（台灣，zh-TW）

這個 VS Code 擴充功能協助閱讀、導覽及撰寫 Verilog 與 SystemVerilog。本儲存庫宣告的版本為 **0.13.13**，擴充功能識別碼為 **`Holey.systemverilog`**，VS Code 相容版本為 **`^1.61.0`**。

## 功能

| 功能 | 行為 |
| --- | --- |
| 語法醒目提示 | 提供 TextMate 語法、語言設定、檔案圖示，以及 Markdown 中 Verilog/SystemVerilog 程式碼區塊的醒目提示。 |
| 程式碼片段 | 包含模組、介面、類別、工作（task）、函式、斷言、`always_ff`、`always_comb`、迴圈與資料宣告等常見結構。 |
| 文件符號 | 使用符號解析器提供大綱與「移至編輯器中的符號」。 |
| 工作區符號 | 透過「移至工作區中的符號」搜尋已建立索引的模組、介面、程式區塊、類別、套件及其他偵測到的宣告。 |
| 定義導覽 | 使用文件及工作區符號解析定義，包含具名連接埠與套件限定名稱。 |
| 參考搜尋 | 將索引中的候選位置與解析出的定義比對；涵蓋範圍取決於索引精度。 |
| 暫留提示 | 顯示第一個解析到的定義所在的原始碼行。 |
| 模組實例產生 | 選擇已建立索引的模組，在游標位置插入具名連接埠與參數覆寫。 |
| 格式化 | 「格式化文件」與「格式化選取範圍」呼叫外部工具，預設為 `verible-verilog-format`。 |
| 診斷 | 可選的內建 ANTLR 語法檢查，以及外部 Verilator、VCS 或 Verible 診斷，會顯示於「問題」面板。 |
| 索引快取 | 將工作區符號存入 VS Code 工作區狀態，供下次啟動載入。 |
| 工作整合 | 提供問題比對器，解析使用者自訂工作中的 Questa/ModelSim、Verilator 與 Verible 輸出。 |

## 支援的檔案

| 檔案 | 語言識別碼 | 支援範圍 |
| --- | --- | --- |
| `.sv`、`.svh` | `systemverilog`、`systemverilogheader` | 醒目提示、程式碼片段、導覽、索引、格式化及可選的診斷。 |
| `.v`、`.vh` | `verilog`、`verilogheader` | 醒目提示、程式碼片段、導覽、索引、格式化及可選的診斷。 |
| `.va`、`.vams` | `veriloga`、`verilogams` | 醒目提示及已註冊的編輯器功能；外部工具支援取決於後端。預設工作區索引模式未納入這些副檔名；ANTLR 驗證不接受這些語言識別碼。 |
| `.f` | `verilog-filelist` | 檔案清單醒目提示與語言設定。 |
| `.sdc`、`.xdc` | `sdc`、`xdc` | 約束檔醒目提示與語言設定。 |

## 快速開始

1. 使用 **Extensions: Install from VSIX...** 安裝已封裝的 VSIX，或依下方開發步驟從原始碼執行。
2. 開啟包含 `.sv`、`.v`、`.svh` 或 `.vh` 的專案資料夾。外部編譯功能需要開啟工作區資料夾才能初始化。
3. 等待 SystemVerilog 狀態列顯示已建立索引的物件數量。點選狀態列，或執行 **SystemVerilog: Build index of modules in workspace** 重新建立索引。
4. 使用 VS Code 的「移至編輯器中的符號」、「移至工作區中的符號」、「移至定義」及「尋找所有參考」。將游標暫留在可解析的符號上，即可預覽宣告。
5. 如需 lint 或格式化，另外安裝外部工具，並設定 `.vscode/settings.json`。

醒目提示、程式碼片段、符號導覽及內建 ANTLR 檢查不需要外部編譯器。擴充功能未內附 Verilator、VCS 或 Verible。使用遠端工作區時，外部工具也必須位於擴充功能主機的執行環境中。

## 命令

在命令選擇區執行以下命令。英文名稱與擴充功能實際註冊的名稱一致：

| 命令 | 識別碼 | 用途 |
| --- | --- | --- |
| SystemVerilog: Build index of modules in workspace | `systemverilog.build_index` | 重新掃描設定的檔案並建立工作區符號索引。 |
| SystemVerilog: Auto instantiate modules in workspace | `systemverilog.auto_instantiate` | 選擇已建立索引的模組，在作用中的編輯器插入實例；請保持沒有選取文字。 |
| SystemVerilog: Compile the opened document | `systemverilog.compile` | 對作用中的檔案執行所選的外部診斷後端；請先儲存修改。 |

產生的實例使用具名連接埠，並連接至同名訊號。參數化模組會依模組標頭產生參數覆寫。請檢查產生的實例，尤其是複雜宣告及運算式。

## 設定

可在使用者設定或 `.vscode/settings.json` 設定選項。以下範例啟用儲存時編譯。此功能預設為停用：

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

若要使用 Verible lint，將 `systemverilog.compilerType` 設為 `Verible`，並設定 `systemverilog.launchConfigurationVerible`。使用 VCS 時，選擇 `VCS` 並在 `systemverilog.launchConfigurationVCS` 加入專案需要的參數。擴充功能會在啟動命令後附加作用中檔案的路徑。include 目錄、巨集定義與檔案清單須自行加入。編譯命令不支援格式化命令的預留位置替換。

若要在編輯及開啟文件時使用內建語法檢查，請將 `systemverilog.antlrVerification` 與 `systemverilog.verifyOnOpen` 都設為 `true`。只啟用 `verifyOnOpen` 不會開啟驗證。

### 設定參考

以下預設值取自 `package.json`。

| 設定 | 型別 | 預設值 | 說明 |
| --- | --- | --- | --- |
| `systemverilog.disableIndexing` | `boolean` | `false` | 沒有已儲存的索引時，停用啟動時的自動索引。 |
| `systemverilog.parallelProcessing` | `integer` | `10` | 建立索引時，同時處理的檔案數量。 |
| `systemverilog.includeIndexing` | `array` | `["**/*.{sv,v,svh,vh}"]` | 納入工作區索引的 glob 模式陣列。 |
| `systemverilog.excludeIndexing` | `string` | `""` | 從索引排除的 glob 模式。 |
| `systemverilog.forceFastIndexing` | `boolean` | `false` | 強制使用快速正規表示式索引。 |
| `systemverilog.enableIncrementalIndexing` | `boolean` | `true` | 儲存檔案或切換作用中編輯器時更新索引。 |
| `systemverilog.maxLineCountIndexing` | `integer` | `2000` | 檔案行數超過此值時，使用快速索引。 |
| `systemverilog.documentSymbolsPrecision` | `string` | `"full"` | 符號詳細程度：`full`、`full_no_references`、`declaration` 或 `fast`。 |
| `systemverilog.compilerType` | `string` | `"Verilator"` | 診斷後端：`Verilator`、`VCS` 或 `Verible`。 |
| `systemverilog.excludeCompiling` | `string` | `""` | 儲存時編譯所檢查的排除 glob 模式；比對對象為文件 URI。 |
| `systemverilog.launchConfigurationVerilator` | `string` | `"verilator --sv --lint-only --language 1800-2012 --Wall"` | Verilator 執行檔與參數。 |
| `systemverilog.launchConfigurationVCS` | `string` | `"vcs"` | VCS 執行檔與參數。 |
| `systemverilog.launchConfigurationVerible` | `string` | `"verible-verilog-lint"` | Verible lint 執行檔與參數。 |
| `systemverilog.formatCommand` | `string` | `"verible-verilog-format"` | 格式化工具執行檔與參數。 |
| `systemverilog.compileOnSave` | `boolean` | `false` | 儲存時執行所選的外部工具。 |
| `systemverilog.trace.server` | `string` | `"off"` | 語言伺服器追蹤層級：`off`、`messages` 或 `verbose`。 |
| `systemverilog.antlrVerification` | `boolean` | `false` | 編輯時啟用內建 ANTLR 語法檢查。 |
| `systemverilog.verifyOnOpen` | `boolean` | `false` | 開啟文件時執行 ANTLR 檢查；也必須啟用 `antlrVerification`。 |
| `systemverilog.compileOnOpen` | `boolean` | `false` | 開啟文件時執行所選的外部工具。 |

### 索引精度與效能

- `full`：偵測宣告、巢狀結構、連接埠、參數、方法、typedef、巨集定義、標籤、實例、斷言及參考候選位置。
- `full_no_references`：提供相近的宣告解析範圍，但不收集參考候選位置，因此會降低「尋找所有參考」的涵蓋範圍。
- `declaration`：縮減宣告解析範圍。設定值必須使用單數的 `declaration`。
- `fast`：僅偵測模組、類別、介面、套件與程式區塊等常見名稱，不保留階層結構。

大型工作區會依檔案數與 `parallelProcessing` 自動降低解析精度。行數超過 `maxLineCountIndexing` 的檔案也會使用快速解析。排除產生的網表與建置目錄可降低 CPU 與記憶體使用量。變更索引設定後請重新建立索引。若文件符號仍沿用舊設定，請重新載入視窗。

以 `*` 開頭的納入模式會透過 VS Code 搜尋工作區檔案。其他模式則使用檔案系統 glob。工作區 RTL 可使用 `**/rtl/**/*.{sv,v,svh,vh}`，外部原始碼目錄則可使用絕對路徑。新增副檔名時，必須同時設定語言關聯與索引模式：

```json
{
  "files.associations": {
    "*.svp": "systemverilog",
    "*.svi": "systemverilog"
  },
  "systemverilog.includeIndexing": ["**/*.{sv,v,svh,vh,svp,svi}"]
}
```

### 格式化行為

`systemverilog.formatCommand` 接受執行檔名稱及後續參數。提供者會將完整的編輯器內容送入標準輸入。格式化選取範圍時，另加 `--lines=start-end`。已儲存的檔案會以其所在目錄作為工作目錄。

格式化命令支援 `${workspaceRoot}`、`${workspaceFolder}`、`${cwd}` 及 `${env.NAME}` 預留位置。環境變數格式使用句點，例如 `${env.VERIBLE_HOME}`。命令依空白切割，因此即使加上引號，含空白的執行檔路徑仍無法正確解析。請使用 `PATH` 中的執行檔，或不含空白的路徑。

## 建置工作

自訂的 `.vscode/tasks.json` 可使用以下問題比對器：

- Questa/ModelSim：`$vlog-error`、`$vlog-warn`、`$vlog-info`、`$vsim-error`、`$vsim-warning`、`$vsim-info`。
- Verilator：`$verilator-error`、`$verilator-warning`、`$verilator-error-v5`、`$verilator-warning-v5`。
- Verible：`$verible-error`、`$verible-warning`、`$verible-info`。

範例：

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

工作問題比對器與三種內建外部診斷後端分開運作。提供 Questa/ModelSim 比對器不代表 `compilerType` 支援 Questa 後端。

## 實作與限制

擴充功能用戶端註冊導覽、暫留提示、格式化及模組實例產生功能。`src/parser.ts` 使用正規表示式解析符號，`src/indexer.ts` 維護工作區索引。`src/server.ts` 中的獨立語言伺服器透過 IPC 發布 ANTLR 與外部工具診斷。

- 符號解析採用啟發式方法，並非完整語意分析或設計展開（elaboration）。複雜語法可能造成導覽結果不完整或不明確。
- `src/wip` 中有尚未完成的補全及模組階層樹程式碼，但未註冊為可用功能。目前支援程式碼片段，尚未實作語意 IntelliSense 補全。
- ANTLR 前處理會替換文件內的巨集文字，並移除 `ifdef`/`ifndef` 區塊。它不是完整的前處理器，可能略過條件編譯程式碼，並使診斷位置偏移。不能視為完整 IEEE 相容性驗證。
- 外部編譯讀取磁碟上已儲存的檔案，不會使用尚未儲存的編輯器內容。初始化使用第一個工作區資料夾，因此多根工作區的編譯支援有限。格式化則會選擇文件所屬的工作區。
- `excludeCompiling` 僅套用於儲存時編譯。手動編譯及開啟時編譯不會檢查此設定。
- 內建 Verible 後端將程式碼風格問題發布為資訊層級。工作問題比對器可指定不同嚴重程度。
- ANTLR 與外部工具使用同一份文件診斷通道，結果可能互相覆蓋。
- 此擴充功能提供編輯器支援及命令整合，未提供 HDL 模擬介面、波形檢視器或 HDL 除錯器。

若符號過時或不完整，請重新建立索引，並檢查納入／排除模式與解析精度。格式化失敗時，請檢查執行檔路徑與原始碼語法。外部診斷異常時，請在擴充功能主機環境確認設定命令可執行，並查看「輸出」面板中的 **SystemVerilog**／**SystemVerilog Language Server** 頻道。

## 開發

安裝 Node.js/npm 及供 ANTLR 產生器使用的 Java 執行環境，接著執行：

```bash
npm ci
npm run compile
npm run webpack:dev
```

`compile` 會重新產生 TextMate JSON 語法及 ANTLR TypeScript 解析器，再編譯 TypeScript。`webpack:dev` 會打包用戶端與伺服器。在 VS Code「執行與偵錯」面板啟動 **Client + Server**，即可偵錯兩個程序。伺服器除錯連接埠為 `6009`。

常用檢查與發佈建置：

```bash
npm run lint
npm test
npm run coverage
npm run vscode:prepublish
```

`npm test` 會編譯專案並啟動 VS Code Electron 整合測試，必要時下載穩定版 VS Code。Electron 需要圖形環境或虛擬顯示器。`vscode:prepublish` 會編譯並在 `dist/client` 與 `dist/server` 產生正式版套件。封裝 VSIX 需另外使用 VS Code 擴充功能封裝工具。

| 位置 | 職責 |
| --- | --- |
| `src/extension.ts` | 用戶端啟動、功能註冊、命令及索引快取。 |
| `src/parser.ts`、`src/indexer.ts`、`src/symbol.ts` | 符號偵測、工作區索引及符號表示。 |
| `src/providers/` | 導覽、參考搜尋、暫留提示、格式化與實例產生。 |
| `src/server.ts`、`src/compiling/` | 語言伺服器、ANTLR 驗證及外部診斷。 |
| `syntaxes/`、`configs/`、`snippets/` | 醒目提示、語言設定及程式碼片段。 |
| `src/test/` | 整合測試及解析器／編譯器測試資料。 |
| `build/` | 用戶端與伺服器的 webpack 設定。 |

版本紀錄請見 [CHANGELOG.md](CHANGELOG.md)，MIT 授權條款請見 [LICENSE](LICENSE)。
