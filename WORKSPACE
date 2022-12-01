load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

http_archive(
    name = "aspect_rules_js",
    sha256 = "f58d7be1bb0e4b7edb7a0085f969900345f5914e4e647b4f0d2650d5252aa87d",
    strip_prefix = "rules_js-1.8.0",
    url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v1.8.0.tar.gz",
)

http_archive(
    name = "rules_nodejs",
    sha256 = "50adf0b0ff6fc77d6909a790df02eefbbb3bc2b154ece3406361dda49607a7bd",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.7.1/rules_nodejs-core-5.7.1.tar.gz"],
)

http_archive(
    name = "aspect_rules_ts",
    sha256 = "5b501313118b06093497b6429f124b973f99d1eb5a27a1cc372e5d6836360e9d",
    strip_prefix = "rules_ts-1.0.2",
    url = "https://github.com/aspect-build/rules_ts/archive/refs/tags/v1.0.2.tar.gz",
)

http_archive(
    name = "aspect_rules_jest",
    sha256 = "dd596891aa893048d2e8d210fce214459df33d454bf0e77906ebbfaee38f2bbc",
    strip_prefix = "rules_jest-0.12.1",
    url = "https://github.com/aspect-build/rules_jest/archive/refs/tags/v0.12.1.tar.gz",
)

# Node toolchain setup ==========================
load("@rules_nodejs//nodejs:repositories.bzl", "DEFAULT_NODE_VERSION", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = DEFAULT_NODE_VERSION,
)

# rules_js setup ================================
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

# rules_js npm setup ============================
load("@aspect_rules_js//npm:npm_import.bzl", "npm_translate_lock")

npm_translate_lock(
    name = "npm",
    data = [
        # TODO: can remove these package.json labels after switching to a pnpm lockfile.
        "//:client/branded/package.json",
        "//:client/build-config/package.json",
        "//:client/client-api/package.json",
        "//:client/codeintellify/package.json",
        "//:client/common/package.json",
        "//:client/eslint-plugin-wildcard/package.json",
        "//:client/extension-api-types/package.json",
        "//:client/extension-api/package.json",
        "//:client/http-client/package.json",
        "//:client/jetbrains/package.json",
        "//:client/observability-client/package.json",
        "//:client/observability-server/package.json",
        "//:client/search-ui/package.json",
        "//:client/search/package.json",
        "//:client/shared/package.json",
        "//:client/storybook/package.json",
        "//:client/template-parser/package.json",
        "//:client/web/package.json",
        "//:client/wildcard/package.json",
        "//:pnpm-workspace.yaml",
    ],
    npmrc = "//:.npmrc",
    package_json = "//:package.json",  # TODO: not needed after switch to pnpm_lock
    verify_node_modules_ignored = "//:.bazelignore",
    yarn_lock = "//:yarn.lock",  # TODO: replace with pnpm_lock
)

# rules_ts npm setup ============================
load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()

load("@aspect_rules_ts//ts:repositories.bzl", "rules_ts_dependencies", LATEST_TS_VERSION = "LATEST_VERSION")

rules_ts_dependencies(ts_version = LATEST_TS_VERSION)

# rules_jest setup ==============================
load("@aspect_rules_jest//jest:dependencies.bzl", "rules_jest_dependencies")

rules_jest_dependencies()

load("@aspect_rules_jest//jest:repositories.bzl", "jest_repositories")

jest_repositories(name = "jest")

load("@jest//:npm_repositories.bzl", jest_npm_repositories = "npm_repositories")

jest_npm_repositories()
