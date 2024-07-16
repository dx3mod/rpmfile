type lead = Lead.t
type header = (Tag.t * Header.index_value) list
type metadata = { lead : lead; signature : header; header : header }
