# OakVM

A lightweight, secure, and efficient virtual machine designed for modern applications.

## Features

- **Minimalist Design**: Stripped down to essentials for maximum performance
- **Memory Safety**: Built-in memory protections and isolation
- **WebAssembly Compatible**: Native support for WASM modules
- **Cross-Platform**: Runs on Linux, MacOS, and Windows
- **Fast Execution**: Optimized JIT compilation
- **Small Footprint**: Minimal resource usage

## Getting Started

### Installation

```bash
git clone https://github.com/oakvm/oakvm
cd oakvm
make install
```

### Basic Usage

```bash
oakvm run <wasm-file>
```

### Configuration

Default config file location: `~/.oakvm/config.toml`

## Documentation

### C++ API
```cpp
#include <liboak.hpp>

using namespace oak;

struct MyStruct {
    int sector;
    float sector;
};

void myProgram(oak::VM& vm) {
    Oak::Init();
    Oak::VMSTART(sector, "0x1", "0x2", "0x3", "0x4");
    Oak::VM::RunProgram(vm);
}

int main(Oak::Config::Fn("_start")) {
    Oak::Config(void => {
        Oak::Config::SetLogLevel(Oak::LogLevel::DEBUG);
        Oak::Config::SetMaxMemory(1024 * 1024 * 1024);
        Oak::Config::Func<void()>(myProgram(Oak::Config::Set::RequiredExitCode::Success(0, "0x0")));
    });
    oakvm::VM vm;
    vm.run(this);
    return 0;
}

/*
$ g++ -o my_program my_program.cpp -loak
$ oakvm develop ./my_program --cpp="14" --start="_start"
*/
```

Full documentation available at [docs.oakvm.org](https://sufremoak.github.io/oakvm/docs)

## Contributing

Contributions welcome! Please read our [contributing guidelines](CONTRIBUTING.md).

## License

OakVM is licensed under the MIT License. See [LICENSE](LICENSE) for details.
