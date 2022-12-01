"Bazel macros for building frontend packages"

load("@aspect_rules_js//npm:defs.bzl", "npm_package")
load("@aspect_rules_esbuild//esbuild:defs.bzl", "esbuild")
load("@npm//:typed-scss-modules/package_json.bzl", types_scss_modules_bin = "bin")
load("@aspect_rules_ts//ts:defs.bzl", _ts_project = "ts_project")

def module_style_typings(name = "module_style_typings", deps = []):
    """Generate TypeScript types for module.scss files.

    Automatically globs all module.scss files in the Bazel package and
    outputs equivalent .d.ts files next to the styles in the output
    tree.

    Args:
        name: Name of the target
        deps: Additional dependencies imported by any of the source style files.
           These could be other .scss files or node_modules deps.
    """
    srcs = native.glob([
        "**/*.module.scss",
    ])

    outs = ["%s.d.ts" % src for src in srcs]

    types_scss_modules_bin.tsm(
        name = name,
        srcs = srcs + deps,
        outs = outs,
        args = [
            "--logLevel",
            "error",
            "%s/**/*.module.scss" % native.package_name(),
            "--includePaths",
            "client",
            "node_modules",
        ],
    )

def web_bundle(name, **kwargs):
    esbuild(
        name = name,
        splitting = True,
        **kwargs
    )

def ts_project(name, **kwargs):
    _base_ts_project(name, **kwargs)

def ts_node_project(name, deps = [], **kwargs):
    _base_ts_project(
        name,
        deps = deps + [
            "//:node_modules/@types/node",
        ],
        **kwargs
    )

def _base_ts_project(name, srcs = None, deps = [], **kwargs):
    deps = deps + ["//:node_modules/tslib"]

    if srcs == None:
        srcs = native.glob(
            [
                "src/**/*.tsx",
                "src/**/*.ts",
            ],
            exclude = [
                "src/**/*.test.tsx",
                "src/**/*.test.ts",
                "src/**/__mocks__/*",
                "src/**/mocks/*",
            ],
        )

    _ts_project(
        name = name,
        tsconfig = kwargs.pop("tsconfig", "//:tsconfig"),
        declaration = True,
        declaration_map = True,
        resolve_json_module = True,
        source_map = True,
        srcs = srcs,
        deps = deps,
        supports_workers = False,
        **kwargs
    )

def sg_node_package(name, **kwargs):
    ts_project_name = "_%s" % name

    npm_package(
        name = name,
        # Includes only the package and compiled ts
        # TODO: data
        srcs = [
            "package.json",
            ":%s" % ts_project_name,
        ],

        # TODO: ?
        # This is a perf improvement; the default will be flipped to False in rules_js 2.0
        # include_runfiles = False,

        # Public by default
        visibility = kwargs.pop("visibility", ["//visibility:public"]),
    )

    ts_node_project(
        name = ts_project_name,
        visibility = ["//visibility:private"],
        **kwargs
    )
