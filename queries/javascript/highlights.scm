(comment) @comment
(keyword) @javascript.keyword 
(string) @javascript.literal_string

; Keywords
(kw_as) @javascript.keyword
(kw_const) @javascript.keyword
(kw_else) @javascript.keyword
(kw_false) @javascript.keyword.false
(kw_from) @javascript.keyword
(kw_function) @javascript.keyword
(kw_if) @javascript.keyword
(kw_import) @javascript.keyword
(kw_let) @javascript.keyword
(kw_return) @javascript.keyword
(kw_this) @javascript.keyword
(kw_true) @javascript.keyword.true


; String stuff
(literal_string) @javascript.literal_string
(literal_regex) @javascript.regex
; 
(literal_object_key) @javascript.literal_object_key

; Jsx
(jsx_name) @jsx.tag_name
(jsx_start) @jsx.start_tag
((jsx_end) @jsx.end_tag (#set! "priority" 200))
(jsx_self) @jsx.self_tag 

(attribute_name) @jsx.attribute_name
(identifier) @js.identifier


; Typescript
(kw_interface) @typescript.keyword
(kw_type) @typescript.keyword
(ts_user_type) @typescript.user_type
