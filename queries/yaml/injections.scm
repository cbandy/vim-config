; https://neovim.io/doc/user/treesitter.html#_treesitter-language-injections

; interpret multiline values (block scalars) of key-value pairs as the language of the key
; https://yaml-multiline.info/#block-scalars
(block_mapping_pair
  key: (flow_node
         (plain_scalar
           (string_scalar) @injection.language (#any-of? @injection.language "json" "sql" "toml" "yaml")))
  value: (block_node
           (block_scalar) @injection.content))
