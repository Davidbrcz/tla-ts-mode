# TLA+ Mode
An Emacs major mode for editing TLA+ specifications using tree-sitter

## Install TLA+ tree sitter grammer

`M-x treesit-install-language-grammar`

Choose tlaplus a language, chose to build it interactively,
 - url https://github.com/tlaplus-community/tree-sitter-tlaplus
 - branch: "main"

## Then load the mode with use-package 

(use-package tla-ts-mode
  :mode "\\.tla\\'"
  :ensure t
  :config
  ; The grammar is called tlaplus, but the mode is called tla
  (setq treesit-load-name-override-list '((tla "libtree-sitter-tlaplus" "tree_sitter_tlaplus")))
  )

