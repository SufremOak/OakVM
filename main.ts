import type { Instance } from "@wasmer/sdk";
// import { Terminal } from "xterm";
// import { FitAddon } from "xterm-addon-fit";
import { Command } from "commander";
import { execFile } from "node:child_process";

// const sh = require("shelljs");
const program = new Command();

async function main() {
  const { Wasmer, init, initializeLogger } = await import("@wasmer/sdk");

  await init();
  initializeLogger("debug");

  const term = new Terminal({ cursorBlink: true, convertEol: true });
  const fit = new FitAddon();
  term.loadAddon(fit);
  term.open(document.getElementById("terminal")!);
  fit.fit();
  const pkg = await Wasmer.fromRegistry("sharrattj/bash");
  term.writeln("Starting...");

  const instance = await pkg.entrypoint!.run();
  connectStreams(instance, term);
}

const encoder = new TextEncoder();

function connectStreams(instance: Instance, term: Terminal) {
  const stdin = instance.stdin?.getWriter();
  term.onData((data) => stdin?.write(encoder.encode(data)));
  instance.stdout.pipeTo(
    new WritableStream({ write: (chunk) => term.write(chunk) }),
  );
  instance.stderr.pipeTo(
    new WritableStream({ write: (chunk) => term.write(chunk) }),
  );
}

program.version("0.0.1").description("OakVM CLI").usage("[command]");

program
  .command("startvm")
  .description("Start OakVM")
  .action(function () {
    const command = "bash";
    const args = ["./src/kernel/main.sh"];

    execFile(command, args, (error: any, stdout: any, stderr: any) => {
      if (error) {
        console.error("Error executing script:", error);
        return;
      }
      console.log("Script output:", stdout);
      if (stderr) {
        console.error("Script errors:", stderr);
      }
    });
  });

program.parse();
