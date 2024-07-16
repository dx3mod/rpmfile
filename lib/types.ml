type lead = Lead.t

type header = (tag * value) list
and tag = int
and value = Header.index_value

type metadata = { lead : lead; signature : header; header : header }
