load("@aspect_rules_ts//ts:defs.bzl", _ts_config = "ts_config", _ts_project = "ts_project")

def ts_project(name, composite = True, declaration = True, declaration_map = True, resolve_json_module = True, source_map = True, **kwargs):
    """Default arguments for ts_project."""
    _ts_project(
        name = name,
        composite = composite,
        declaration = declaration,
        declaration_map = declaration_map,
        resolve_json_module = resolve_json_module,
        source_map = source_map,
        **kwargs
    )

def ts_config(name, deps = [], **kwargs):
    """Default arguments for ts_config."""

    if "//:tsconfig" not in deps:
        deps = deps + ["//:tsconfig"]

    _ts_config(
        name = name,
        deps = deps,
        **kwargs
    )
