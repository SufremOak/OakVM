#include <liboak.hpp>

using namespace oak;

void customErrorHandler(ErrorCode code, const std::string& message) {
    std::cerr << "Error " << static_cast<int>(code) << ": " << message << std::endl;
}

int main() {
    OAK_TRY {
        // Configure VM
        Config::ConfigBuilder builder;
        auto config = builder
            .SetStackSize(2 * 1024 * 1024)
            .SetHeapSize(4 * 1024 * 1024 * 1024)
            .EnableJIT(true)
            .SetMemoryStrategy(MemoryManager::AllocationStrategy::HYBRID)
            .Build();

        // Initialize Oak
        Oak::Init(config);
        Oak::SetErrorHandler(customErrorHandler);

        // Create and run VM
        VM vm(config);
        vm.LoadModule("mymodule.oak");
        vm.Execute("main");

        auto result = vm.GetResult<int>();

        Oak::Shutdown();
        return result;
    } OAK_CATCH

    return -1;
}
