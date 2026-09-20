"""Validate a copied config with isolated Neovim config/data/state/cache directories."""

import argparse
import json
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--seed-plugins",
        type=Path,
        help="copy an existing lazy plugin cache; never modify it",
    )
    parser.add_argument(
        "--seed-parsers",
        type=Path,
        help="copy an existing Neovim site directory with native parsers",
    )
    parser.add_argument(
        "--skip-parser-downloads",
        action="store_true",
        help="inject unavailable parser-build capability for restricted-network testing",
    )
    parser.add_argument("--output", type=Path, default=Path(".tests/results"))
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    nvim = shutil.which("nvim")
    if not nvim:
        raise SystemExit("nvim is required on PATH")
    env = os.environ.copy()
    # Keep the original installation entirely separate, including on Windows.
    with tempfile.TemporaryDirectory(prefix="nvim portability ") as temporary:
        root = Path(temporary)
        for kind in ("CONFIG", "DATA", "STATE", "CACHE"):
            env[f"XDG_{kind}_HOME"] = str(root / kind.lower())
        env["NVIM_APPNAME"] = "nvim"
        env.pop("VIMINIT", None)
        env.pop("EXINIT", None)
        env.pop("NVIM", None)
        paths = subprocess.run(
            [
                nvim,
                "--headless",
                "-u",
                "NONE",
                "-i",
                "NONE",
                "-c",
                'lua io.stdout:write(vim.json.encode({config=vim.fn.stdpath("config"),data=vim.fn.stdpath("data")}))',
                "+qa",
            ],
            env=env,
            check=True,
            capture_output=True,
            text=True,
        )
        paths = json.loads(paths.stdout)
        config = Path(paths["config"])
        config.mkdir(parents=True)
        for name in ("init.lua", "lazyvim.json", ".luarc.json", ".neoconf.json"):
            shutil.copy2(repo / name, config / name)
        for name in ("lua", "snippets"):
            shutil.copytree(repo / name, config / name)
        if args.seed_plugins:
            shutil.copytree(
                args.seed_plugins, Path(paths["data"]) / "lazy", symlinks=True
            )
        if args.seed_parsers:
            shutil.copytree(
                args.seed_parsers, Path(paths["data"]) / "site", symlinks=True
            )
        work = root / "sample project"
        work.mkdir()
        (work / ".luarc.json").write_text("{}\n", encoding="utf-8")
        env["NVIM_TEST_WORK"] = str(work)
        injected = []
        if args.skip_parser_downloads:
            injected = [
                "--cmd",
                'lua vim.opt.rtp:prepend(vim.fn.stdpath("config")); require("util.platform").can_build_parsers = function() return false end',
            ]

        def run(label, arguments, cwd=work, timeout=600, expected=0):
            print(f"Running {label}...", flush=True)
            result = subprocess.run(
                [nvim, *arguments],
                check=False,
                cwd=cwd,
                env=env,
                capture_output=True,
                text=True,
                timeout=timeout,
            )
            text = result.stdout + result.stderr
            (output / f"{label}.log").write_text(text, encoding="utf-8")
            if result.returncode != expected or re.search(
                r"(?:Error detected while processing|Failed to (?:run|load)|E\d{3}:)",
                text,
            ):
                print(text[-16000:])
                raise RuntimeError(f"{label} failed; see {output}")
            print(f"PASS: {label}", flush=True)

        try:
            run(
                "unit",
                [
                    "--headless",
                    "-u",
                    "NONE",
                    "-i",
                    "NONE",
                    "-l",
                    str(repo / "tests/portability.lua"),
                ],
                repo,
            )
            run(
                "missing-git",
                [
                    "--headless",
                    "-u",
                    "NONE",
                    "-i",
                    "NONE",
                    "-l",
                    str(repo / "tests/bootstrap.lua"),
                ],
                repo,
                timeout=10,
                expected=1,
            )
            install = (
                "lua dofile("
                + json.dumps(str(repo / "tests/install.lua").replace("\\", "/"))
                + ")"
            )
            run(
                "install",
                [
                    "--headless",
                    "-i",
                    "NONE",
                    *injected,
                    "+Lazy! install",
                    "-c",
                    install,
                    "+qa",
                ],
            )
            # -c executes after init; scheduled smoke work runs after VimEnter/VeryLazy.
            smoke = (
                "lua dofile("
                + json.dumps(str(repo / "tests/smoke.lua").replace("\\", "/"))
                + ")"
            )
            run(
                "smoke",
                ["--headless", "-i", "NONE", *injected, "-c", smoke],
                timeout=300,
            )
            run("startup", ["--headless", "-i", "NONE", *injected, "+qa"])
        finally:
            for name in (
                "health.txt",
                "messages.txt",
                "notifications.txt",
                "features.json",
            ):
                if (work / name).exists():
                    shutil.copy2(work / name, output / name)
            if (config / "lazy-lock.json").exists():
                shutil.copy2(config / "lazy-lock.json", output / "lazy-lock.json")
            (output / "environment.json").write_text(
                json.dumps(
                    {
                        "platform": os.name,
                        "seeded": bool(args.seed_plugins),
                        "seeded_parsers": bool(args.seed_parsers),
                        "parser_downloads_skipped": args.skip_parser_downloads,
                        "neovim": subprocess.check_output(
                            [nvim, "--version"], text=True
                        ).splitlines()[0],
                    },
                    indent=2,
                )
                + "\n",
                encoding="utf-8",
            )


if __name__ == "__main__":
    main()
