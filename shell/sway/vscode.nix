{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    docker-compose
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      keyboard-quickfix
      material-theme
      remote-containers
      remote-wsl
      todo-tree
      vscode-neovim
      vscode-icons
    ];
    keybindings = [
      # general
      {
        "key" = "escape";
        "command" = "vscode-neovim.escape";
        "when" = "editorTextFocus && neovim.init && neovim.mode != 'normal'";
      }
      {
        "key" = "ctrl+shift+c";
        "command" = "editor.action.clipboardCopyAction";
      }
      {
        "key" = "ctrl+shift+v";
        "command" = "editor.action.clipboardPasteAction";
      }
      {
        "key" = "ctrl+z";
        "command" = "workbench.action.toggleZenMode";
      }

      # functions
      {
        "key" = "ctrl+e";
        "command" = "workbench.view.explorer";
        "when" = "neovim.mode == 'normal'";
      }
      {
        "key" = "ctrl+f ctrl+f";
        "command" = "workbench.action.quickOpen";
        "when" = "neovim.mode == 'normal'";
      }
      {
        "key" = "ctrl+f ctrl+g";
        "command" = "workbench.view.search";
        "when" = "!searchViewletFocus && neovim.mode == 'normal'";
      }
      {
        "key" = "ctrl+f ctrl+s";
        "command" = "workbench.action.showAllSymbols";
        "when" = "neovim.mode == 'normal'";
      }
      {
        "key" = "ctrl+t";
        "command" = "terminal.focus";
        "when" = "neovim.mode == 'normal'";
      }
      {
        "key" = "ctrl+x";
        "command" = "workbench.panel.markers.view.focus";
        "when" = "neovim.mode == 'normal'";
      }

      # window
      {
        "key" = "ctrl+h";
        "command" = "vscode-neovim.send";
        "when" = "!sideBarFocus && !panelFocus && neovim.mode == 'normal'";
        "args" = "<C-w>h";
      }
      {
        "key" = "ctrl+l";
        "command" = "vscode-neovim.send";
        "when" = "!sideBarFocus && !panelFocus && neovim.mode == 'normal'";
        "args" = "<C-w>l";
      }
      {
        "key" = "ctrl+k";
        "command" = "vscode-neovim.send";
        "when" = "!sideBarFocus && !panelFocus && neovim.mode == 'normal'";
        "args" = "<C-w>k";
      }
      {
        "key" = "ctrl+j";
        "command" = "vscode-neovim.send";
        "when" = "!sideBarFocus && !panelFocus && neovim.mode == 'normal'";
        "args" = "<C-w>j";
      }

      # buffer
      {
        "key" = "ctrl+b ctrl+n";
        "command" = "workbench.action.files.newUntitledFile";
      }
      {
        "key" = "ctrl+p";
        "command" = "workbench.action.previousEditor";
        "when" = "editorTextFocus && neovim.mode == 'normal'";
      }
      {
        "key" = "ctrl+n";
        "command" = "workbench.action.nextEditor";
        "when" = "editorTextFocus && neovim.mode == 'normal'";
      }
      {
        "key" = "ctrl+c";
        "command" = "workbench.action.closeActiveEditor";
        "when" = "listFocus || editorFocus && neovim.mode == 'normal'";
      }

      # editor - completion
      {
        "key" = "tab";
        "command" = "selectNextSuggestion";
        "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
      }
      {
        "key" = "shift+tab";
        "command" = "selectPrevSuggestion";
        "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
      }
      {
        "key" = "enter";
        "command" = "insertSnippet";
        "when" = "editorTextFocus && hasSnippetCompletions && !editorTabMovesFocus && !inSnippetMode";
      }
      {
        "key" = "tab";
        "command" = "jumpToNextSnippetPlaceholder";
        "when" = "editorTextFocus && hasNextTabstop && inSnippetMode";
      }
      {
        "key" = "shift+tab";
        "command" = "jumpToPrevSnippetPlaceholder";
        "when" = "editorTextFocus && hasPrevTabstop && inSnippetMode";
      }

      # sidebar (explorer & grep)
      {
        "key" = "ctrl+l";
        "command" = "workbench.action.focusFirstEditorGroup";
        "when" = "sideBarFocus";
      }
      {
        "key" = "ctrl+c";
        "command" = "workbench.action.closeSidebar";
        "when" = "sideBarFocus";
      }

      # explorer
      {
        "key" = "f";
        "command" = "filesExplorer.findInFolder";
        "when" = "explorerResourceIsFolder && explorerViewletVisible && filesExplorerFocus && !inputFocus";
      }
      {
        "key" = "h";
        "command" = "list.collapse";
        "when" = "explorerViewletFocus && listFocus && !inputFocus";
      }
      {
        "key" = "l";
        "command" = "list.expand";
        "when" = "explorerViewletFocus && listFocus && !inputFocus";
      }
      {
        "key" = "j";
        "command" = "list.focusDown";
        "when" = "explorerViewletFocus && listFocus && !inputFocus";
      }
      {
        "key" = "k";
        "command" = "list.focusUp";
        "when" = "explorerViewletFocus && listFocus && !inputFocus";
      }
      {
        "key" = "a";
        "command" = "workbench.files.action.createFileFromExplorer";
        "when" = "explorerViewletVisible && filesExplorerFocus && !inputFocus";
      }
      {
        "key" = "shift+a";
        "command" = "workbench.files.action.createFolderFromExplorer";
        "when" = "explorerViewletVisible && filesExplorerFocus && !inputFocus";
      }
      {
        "key" = "y";
        "command" = "filesExplorer.copy";
        "when" = "explorerViewletFocus && explorerViewletVisible && filesExplorerFocus && !explorerResourceIsRoot && !inputFocus";
      }
      {
        "key" = "m";
        "command" = "filesExplorer.cut";
        "when" = "explorerViewletFocus && explorerViewletVisible && filesExplorerFocus && !explorerResourceIsRoot && !inputFocus";
      }
      {
        "key" = "p";
        "command" = "filesExplorer.paste";
        "when" = "explorerViewletFocus && explorerViewletVisible && filesExplorerFocus && !explorerResourceReadonly && !inputFocus";
      }
      {
        "key" = "d";
        "command" = "deleteFile";
        "when" = "explorerViewletFocus && explorerViewletVisible && filesExplorerFocus && !explorerResourceMoveableToTrash && !explorerResourceReadonly && !inputFocus";
      }
      {
        "key" = "d";
        "command" = "moveFileToTrash";
        "when" = "explorerViewletFocus && explorerResourceMoveableToTrash && explorerViewletVisible && filesExplorerFocus && !explorerResourceReadonly && !inputFocus";
      }
      {
        "key" = "r";
        "command" = "renameFile";
        "when" = "explorerViewletFocus && explorerViewletVisible && filesExplorerFocus && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
      }

      # grep search
      {
        "key" = "ctrl+g";
        "command" = "search.action.clearSearchResults";
        "when" = "searchViewletFocus";
      }
      {
        "key" = "ctrl+p";
        "command" = "search.action.focusSearchList";
        "when" = "searchInputBoxFocus";
      }
      {
        "key" = "ctrl+n";
        "command" = "search.action.focusSearchList";
        "when" = "searchInputBoxFocus";
      }

      # file/symbol search
      {
        "key" = "ctrl+c";
        "command" = "workbench.action.closeQuickOpen";
        "when" = "inQuickOpen";
      }

      # panel (diagnostics & terminal)
      {
        "key" = "ctrl+k";
        "command" = "workbench.action.focusActiveEditorGroup";
        "when" = "panelFocus";
      }
      {
        "key" = "ctrl+c";
        "command" = "workbench.action.closePanel";
        "when" = "panelFocus";
      }

      # diagnostics search
      {
        "key" = "ctrl+p";
        "command" = "workbench.panel.markers.view.focus";
        "when" = "problemsFilterFocus";
      }
      {
        "key" = "ctrl+n";
        "command" = "workbench.panel.markers.view.focus";
        "when" = "problemsFilterFocus";
      }

      # terminal
      {
        "key" = "ctrl+j";
        "command" = "workbench.action.togglePanel";
        "when" = "panelFocus";
      }
      {
        "key" = "ctrl+w n";
        "command" = "workbench.action.terminal.new";
        "when" = "terminalFocus && terminalProcessSupported";
      }
      {
        "key" = "ctrl+w v";
        "command" = "workbench.action.terminal.split";
        "when" = "terminalFocus && terminalProcessSupported";
      }
      {
        "key" = "ctrl+p";
        "command" = "workbench.action.terminal.focusPrevious";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+n";
        "command" = "workbench.action.terminal.focusNext";
        "when" = "terminalFocus";
      }

      # removed
      {
        "key" = "ctrl+n";
        "command" = "-workbench.action.files.newUntitledFile";
      }
      {
        "key" = "ctrl+p";
        "command" = "-workbench.action.quickOpen";
      }
      {
        "key" = "ctrl+j";
        "command" = "-workbench.action.togglePanel";
      }
      {
        "key" = "escape";
        "command" = "-vscode-neovim.escape";
        "when" = "editorTextFocus && neovim.init";
      }
    ];
    userSettings = {
      ## neocode

      # editor
      "editor.cursorBlinking" = "solid";
      "editor.dragAndDrop" = false;
      "editor.formatOnSave" = true;
      "editor.formatOnPaste" = true;
      "editor.lineNumbers" = "relative";
      "editor.linkedEditing" = true;
      "editor.minimap.enabled" = false;
      "editor.mouseWheelZoom" = true;
      "editor.scrollBeyondLastLine" = false;
      "editor.smoothScrolling" = true;
      "editor.wordWrap" = "on";

      # explorer
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "explorer.openEditors.sortOrder" = "alphabetical";
      "explorer.openEditors.visible" = 0;
      "explorer.sortOrder" = "mixed";

      # general
      "files.autoSave" = "afterDelay";
      "files.eol" = "\n";
      "search.showLineNumbers" = true;
      "search.smartCase" = true;
      "workbench.editor.highlightModifiedTabs" = true;
      "workbench.list.automaticKeyboardNavigation" = false;
      "workbench.list.keyboardNavigation" = "simple";
      "workbench.iconTheme" = "vscode-icons";
      "workbench.panel.opensMaximized" = "never";
      "workbench.startupEditor" = "newUntitledFile";

      # whitespaces & newline
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
      "files.trimTrailingWhitespace" = true;

      # plugins
      "extensions.closeExtensionDetailsOnViewChange" = true;
      "extensions.ignoreRecommendations" = true;

      "vsicons.dontShowNewVersionMessage" = true;

      "vscode-neovim.highlightGroups.unknownHighlight" = "vim";
      "vscode-neovim.logLevel" = "warn";
      "vscode-neovim.logOutputToConsole" = true;
      "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";
      "vscode-neovim.neovimInitVimPaths.linux" = "/home/serowy/.config/nvim/init.lua";
      "vscode-neovim.textDecorationsAtTop" = true;

      # git
      "git.ignoreMissingGitWarning" = true;

      # terminal
      "terminal.integrated.localEchoExcludePrograms" = [
        "vim"
        "vi"
        "nano"
        "tmux"
        "nvim"
      ];

      # todo
      "todo-tree.filtering.includeHiddenFiles" = true;
      "todo-tree.general.enableFileWatcher" = true;
      "todo-tree.tree.expanded" = true;
      "todo-tree.tree.flat" = true;
      "todo-tree.tree.buttons.filter" = false;
      "todo-tree.tree.showCurrentScanMode" = false;
      "todo-tree.tree.scanAtStartup" = false;

      # zen
      "zenMode.hideLineNumbers" = false;
      "zenMode.restore" = false;

      ## custom settings (not neocode related)

      "workbench.colorTheme" = "One Dark Pro";

      # font
      "editor.codeLensFontSize" = 10;
      "editor.fontFamily" = "FiraCode Nerd Font Mono";
      "editor.fontWeight" = "normal";
      "editor.fontLigatures" = true;

      # terminal
      "terminal.integrated.defaultProfile.linux" = "zsh";

      # lsp
      "[home-assistant]" = {
        "editor.defaultFormatter" = "keesschollaart.vscode-home-assistant";
      };
      "[javascript]" = {
        "editor.defaultFormatter" = "vscode.typescript-language-features";
      };
      "[jsonc]" = {
        "editor.defaultFormatter" = "vscode.json-language-features";
      };
      "rust-analyzer.checkOnSave.command" = "clippy";
      "rust-analyzer.cargo.allFeatures" = true;

      ## settings sync

      "settingsSync.keybindingsPerPlatform" = false;

      # ignored
      "settingsSync.ignoredExtensions" = [
        "dotjoshjohnson.xml"
      ];
      "settingsSync.ignoredSettings" = [
        "vscode-neovim.useWSL"
        "vscode-neovim.neovimExecutablePaths.linux"
        "vscode-neovim.neovimExecutablePaths.win32"
        "vscode-neovim.neovimInitVimPaths.linux"
        "vscode-neovim.neovimInitVimPaths.win32"
      ];
    };
  };
}
