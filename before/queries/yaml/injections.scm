;; extends
; https://neovim.io/doc/user/treesitter.html#_treesitter-language-injections


; interpret multiline values (block scalars) of key-value pairs as the language of the key
; https://yaml-multiline.info#block-scalars
((block_mapping_pair
   key: (flow_node (_ (string_scalar) @injection.language))
   value: (block_node (block_scalar) @injection.content))

 ; skip the block style indicator without considering other indicators
 (#offset! @injection.content 0 1 0 0)

 ; only consider a few languages for now; case-sensitive
 (#any-of? @injection.language "json" "sql" "toml" "yaml"))


; Kyverno Chainsaw -- script: { content: BASH }
; https://kyverno.github.io/chainsaw/main/reference/apis/chainsaw.v1alpha1#chainsaw-kyverno-io-v1alpha1-Operation
(block_mapping_pair
  key: (flow_node) @operation (#any-eq? @operation "script")
  value:
  (_ (_ (_ key: (flow_node) @key (#any-eq? @key "content")
           value:
           (block_node
             (block_scalar) @injection.content
             ; skip the block style indicator without considering other indicators
             (#offset! @injection.content 0 1 0 0)
             (#set! injection.language "bash"))))))
