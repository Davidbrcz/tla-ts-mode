;;; tla-ts-mode.el --- Major mode for editing TLA+ files.

;; Copyright (c) 2023 Davidbrcz
;;
;; Author: Davidbrcz <davidbrcz@gmail.com>
;; Keywords: languages tla
;; Homepage: https://github.com/Davidbrcz/tla-ts-mode
;; Version: 0.1.0
;; SPDX-License-Identifier: GPL-3.0-or-later


;;; Commentary:
;; A major mode used for editing TLA+ PlusCal files with tree-sitter.

;;; Code:

;; Syntax highlighting
(defconst tla-mode-hl-patterns
  [
                                        ; Proofs
   (proof_step_id "<" @punctuation.bracket)
   (proof_step_id (level) @number)
   (proof_step_id (name) @constant)
   (proof_step_id ">" @punctuation.bracket)
   (proof_step_ref "<" @punctuation.bracket)
   (proof_step_ref (level) @number)
   (proof_step_ref (name) @constant)
   (proof_step_ref ">" @punctuation.bracket)
   ])

(defvar tla-ts-mode-indentation-offset 2)
(defvar tla-ts-mode--misc-punctuation
  '(
    ","
    ":"
    "."
    "!"
    (bullet_conj)
    (bullet_disj)
    )
  "Punctuation")

(defvar tla-ts-mode--comment
  '((comment) (block_comment) (block_comment_text) (extramodular_text))
  )

(defvar tla-ts-mode--builtin
  '((nat_number_set) (boolean_set) (int_number_set) (real_number_set) (string_set))
  )

(defvar tla-ts-mode--constant
  '("TRUE" "FALSE")
  )


(defvar tla-ts-mode--numbers
  '((nat_number) (real_number) (octal_number) (hex_number) (binary_number))
  )

(defvar tla-ts-mode--delimiters
  '((langle_bracket) (rangle_bracket) (rangle_bracket_sub) "{" "}" "[" "]" "]_" "(" ")")
  )

(defvar tla-ts-mode--operators
  '( (amp)
     (ampamp)
     (approx)
     (assign)
     (asymp)
     (bigcirc)
     (bnf_rule)
     (bullet)
     (cap)
     (cdot)
     (circ)
     (compose)
     (cong)
     (cup)
     (div)
     (dol)
     (doldol)
     (doteq)
     (dots_2)
     (dots_3)
     (eq)
     (equiv)
     (excl)
     (geq)
     (gg)
     (gt)
     (hashhash)
     (iff)
     (implies)
     (in)
     (land)
     (ld_ttile)
     (leads_to)
     (leq)
     (ll)
     (lor)
     (ls_ttile)
     (lt)
     (map_from)
     (map_to)
     (minus)
     (minusminus)
     (mod)
     (modmod)
     (mul)
     (mulmul)
     (neq)
     (notin)
     (odot)
     (ominus)
     (oplus)
     (oslash)
     (otimes)
     (plus)
     (plus_arrow)
     (plusplus)
     (pow)
     (powpow)
     (prec)
     (preceq)
     (propto)
     (qq)
     (rd_ttile)
     (rs_ttile)
     (setminus)
     (sim)
     (simeq)
     (slash)
     (slashslash)
     (sqcap)
     (sqcup)
     (sqsubset)
     (sqsubseteq)
     (sqsupset)
     (sqsupseteq)
     (star)
     (subset)
     (subseteq)
     (succ)
     (succeq)
     (supset)
     (supseteq)
     (times)
     (uplus)
     (vert)
     (vertvert)
     (wr)
     ;; bound_postfix_op symbols
     (asterisk)
     (prime)
     (sup_hash)
     (sup_plus)
     ;; bound_prefix_op
     (always)
     (domain)
     (enabled)
     (eventually)
     (lnot)
     (negative)
     (powerset)
     (unchanged)
     (union)
     )
  "Operators that are matched by the mode"
  )

(defvar tla-ts-mode--pcal-keywords
  '(
    "--algorithm"
    "assert"
    "await"
    ;; (pcal_definitions)
    ;; (pcal_either)
    "either"
    "or"
    "goto"
    "if"
    "else"
    "variable"
    "variables"
    "fair"
    "process"
    ;; (pcal_macro)
    ;; (pcal_macro_call)
    ;; (pcal_macro_decl)
    ;; (pcal_print)
    ;; (pcal_procedure)
    ;; (pcal_process)
    "return"
    "skip"
    "while"
    "with"
    )
  )
(defvar tla-ts-mode--keywords
  '(
    "ACTION"
    "ASSUME"
    "ASSUMPTION"
    "AXIOM"
    "BY"
    "CASE"
    "CHOOSE"
    "CONSTANT"
    "CONSTANTS"
    "COROLLARY"
    "DEF"
    "DEFINE"
    "DEFS"
    "DOMAIN"
    "ELSE"
    "ENABLED"
    "EXCEPT"
    "EXTENDS"
    "HAVE"
    "HIDE"
    "IF"
    "IN"
    "INSTANCE"
    "LAMBDA"
    "LEMMA"
    "LET"
    "LOCAL"
    "MODULE"
    "NEW"
    "OBVIOUS"
    "OMITTED"
    "ONLY"
    "OTHER"
    "PICK"
    "PROOF"
    "PROPOSITION"
    "PROVE"
    "QED"
    "RECURSIVE"
    "SF_"
    "STATE"
    "SUBSET"
    "SUFFICES"
    "TAKE"
    "TEMPORAL"
    "THEN"
    "THEOREM"
    "UNCHANGED"
    "UNION"
    "USE"
    "VARIABLE"
    "VARIABLES"
    "WF_"
    "WITH"
    "WITNESS"
    (def_eq)
    (set_in)
    (gets)
    (forall)
    (exists)
    (temporal_forall)
    (temporal_exists)
    (all_map_to)
    (maps_to)
    (case_box)
    (case_arrow)
    (address)
    (label_as))
  "TLA+ keywords for tree-sitter font-locking.")

(defvar tla-ts-font-lock-rules
  `(
    :language tlaplus
    :override t
    :feature builtin
    (
     ([,@tla-ts-mode--builtin] @font-lock-builtin-face)
     ([,@tla-ts-mode--constant] @font-lock-constant-face)
     (pcal_algorithm_body label: (identifier) @font-lock-constant-face)
     )

    :language tlaplus
    :feature string
    ((string) @font-lock-string-face)

    :language tlaplus
    :feature numbers
    (
     [,@tla-ts-mode--numbers] @font-lock-number-face
     )

    :language tlaplus
    :override t
    :feature keyword
    (
     ([,@tla-ts-mode--keywords] @font-lock-keyword-face)
     ([,@tla-ts-mode--pcal-keywords] @font-lock-keyword-face)
     )


    :language tlaplus
    :override t
    :feature function
    (
     (operator_definition name: (identifier) @font-lock-function-name-face)
     )

    :language tlaplus
    :override t
    :feature operator
    ([,@tla-ts-mode--operators] @font-lock-operator-face)

    :language tlaplus
    :override t
    :feature module
    (
     (module name: (identifier) @font-lock-type-face)
     )

    :language tlaplus
    :override t
    :feature extend
    (
     ((extends (identifier_ref) @font-lock-preprocessor-face))
     )

    :language tlaplus
    :override t
    :feature module_constants
    (
     ((constant_declaration (identifier) @font-lock-variable-name-face))
     )

    ;; feature extend and parameter overlap as they both match identifier_ref
    ;;  keep policy instructs to keep previous font lock that was applied by the extend feature
    :language tlaplus
    :override keep
    :feature identifier
    (
     (operator_definition parameter: (identifier) @font-lock-variable-name-face)
     (theorem name: (identifier) @font-lock-variable-name-face)
     (variable_declaration (identifier) @font-lock-variable-name-face)
     (pcal_var_decl (identifier) @font-lock-variable-name-face)
     (pcal_algorithm name: (identifier) @font-lock-function-name-face)
     (record_literal  (identifier) @font-lock-property-name-face)
     ((identifier_ref) @font-lock-variable-use-face)
     ((prev_func_val) @font-lock-variable-use-face)
     (pcal_process name: (identifier) @font-lock-variable-name-face)
     (quantifier_bound (identifier) @font-lock-variable-name-face)
     (pcal_with (identifier) @font-lock-variable-name-face)
     )

    :language tlaplus
    :override t
    :feature delimiter
    ([,@tla-ts-mode--delimiters ] @font-lock-bracket-face)

    :language tlaplus
    :feature misc-punctuation
    ([,@tla-ts-mode--misc-punctuation] @font-lock-misc-punctuation-face)

    :language tlaplus
    :override keep
    :feature comment
    ([,@tla-ts-mode--comment] @font-lock-comment-face)

    )
  )

;; Imenu support
;; For extends and constants, the code
;; matches directly the identifier below the constant_declaration
;; and uses the text of the node as the symbols
;; For operators, it mwatches the operator node itself and extracts
;; the identifier of its :name field
(defmacro tla-ts-mode--imenu-node-under-p (parent-type node-type)
  `(lambda (node)
     (and (equal (treesit-node-type node) ,node-type)
          (equal (treesit-node-type (treesit-node-parent node))
                 ,parent-type)
          ))
  )

(defun tla-ts-mode--imenu-operator-node-p (node)
  (equal (treesit-node-type node) "operator_definition")
  )

(defun tla-ts-mode--imenu-name-operator-function (node)
  ;; retrieve the identifier from name: fiield of the operator_definition node
  (treesit-node-text (treesit-node-child-by-field-name node "name"))
  )

(defun tla-ts-setup ()
  "setup treesit for tla-ts-mode."
  (interactive)

  ;; our tree-sitter setup goes here.
  ;; this handles font locking -- more on that below.
  (setq-local treesit-font-lock-settings
              (apply #'treesit-font-lock-rules tla-ts-font-lock-rules))
  (setq-local font-lock-defaults nil)

  ;; each sublist maps to its position interpreted as a level of treesit-font-lock-level
  ;; level 1 usually contains only comments and definitions.
  ;; level 2 usually adds keywords, strings, data types, etc.
  ;; level 3 usually represents full-blown fontifications, including
  ;; assignments, constants, numbers and literals, etc.
  ;; level 4 adds everything else that can be fontified: delimiters,
  ;; operators, brackets, punctuation, all functions, properties,
  ;; variables, etc.
  (setq-local treesit-font-lock-feature-list
              '(
                (comment module)
                (keyword string function extend module_constants)
                (numbers constant operator identifier builtin)
                (delimiter misc-punctuation)
                )
              )

  (setq-local treesit-simple-indent-rules
              '((tlaplus
                 ((parent-is "if_then_else") parent tla-ts-mode-indentation-offset)
                 (no-node parent 0)
                 (catch-all parent 0)
                 ))
              )

  (setq-local treesit--indent-verbose 1)
  (setq-local treesit-simple-imenu-settings
              `(
                ("Extends" ,(tla-ts-mode--imenu-node-under-p "extends" "identifier_ref") nil treesit-node-text)
                ("Constants" ,(tla-ts-mode--imenu-node-under-p "constant_declaration" "identifier") nil treesit-node-text)
                ("Variables" ,(tla-ts-mode--imenu-node-under-p "variable_declaration" "identifier") nil treesit-node-text)
                ("Operators" tla-ts-mode--imenu-operator-node-p nil tla-ts-mode--imenu-name-operator-function)
                ))

  (treesit-major-mode-setup))

;;;###autoload
(define-derived-mode tla-ts-mode prog-mode "TLA+"
  "Major mode for editing TLA+ with tree-sitter."

  (setq-local font-lock-defaults nil)
  (when (treesit-ready-p 'tlaplus)
    (treesit-parser-create 'tlaplus)
    (tla-ts-setup)
    ))

;;;###autoload
(add-to-list 'auto-mode-alist
             '("\\.tla\\'" . tla-ts-mode))

(provide 'tla-ts-mode)

;;; tla-mode.el ends here
