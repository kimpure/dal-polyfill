declare _G: {
	DAL_runtime_type_checking: boolean,
	DAL_hash_iterator: boolean,
	DAL_allow_debug_library_usage: boolean,
	DAL_emulate_frozen_table: boolean,
	DAL_emulate_newproxy: boolean,
	DAL_test: boolean,
	DAL_emulate_type_error: boolean,
}

declare load: <A...>(chunk: string | () -> string, chunkname: string?, mode: ("bt" | "b" | "t")?, env: { [string]: any }?) -> (((A...) -> any)?, string?)
