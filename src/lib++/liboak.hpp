#ifndef LIBOAK_HPP
#define LIBOAK_HPP

#include <string>
#include <functional>
#include <memory>
#include <vector>
#include <unordered_map>
#include <exception>
#include <atomic>
#include <thread>
#include <mutex>

namespace oak {

// Forward declarations
class VM;
class MemoryManager;
class GarbageCollector;

// Custom exception classes
class OakException : public std::exception {
public:
    explicit OakException(const std::string& message) : message_(message) {}
    const char* what() const noexcept override { return message_.c_str(); }
private:
    std::string message_;
};

class VMException : public OakException {
public:
    explicit VMException(const std::string& message) : OakException(message) {}
};

class MemoryException : public OakException {
public:
    explicit MemoryException(const std::string& message) : OakException(message) {}
};

// Error handling
enum class ErrorCode {
    SUCCESS = 0,
    MEMORY_ALLOCATION_FAILED,
    VM_INITIALIZATION_FAILED,
    INVALID_INSTRUCTION,
    STACK_OVERFLOW,
    STACK_UNDERFLOW,
    SEGMENTATION_FAULT,
    INVALID_MEMORY_ACCESS
};

class ErrorHandler {
public:
    static void HandleError(ErrorCode code, const std::string& message);
    static void SetErrorCallback(std::function<void(ErrorCode, const std::string&)> callback);
private:
    static std::function<void(ErrorCode, const std::string&)> errorCallback_;
};

// Enhanced logging system
enum class LogLevel {
    TRACE,
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    FATAL
};

class Logger {
public:
    static void Log(LogLevel level, const std::string& message);
    static void SetLogCallback(std::function<void(LogLevel, const std::string&)> callback);
    static void EnableFileLogging(const std::string& filename);
private:
    static std::function<void(LogLevel, const std::string&)> logCallback_;
    static std::ofstream logFile_;
};

// Memory management
class MemoryManager {
public:
    enum class AllocationStrategy {
        POOL,
        DYNAMIC,
        HYBRID
    };

    struct MemoryStats {
        size_t totalAllocated;
        size_t totalFreed;
        size_t currentUsage;
        size_t peakUsage;
    };

    explicit MemoryManager(AllocationStrategy strategy = AllocationStrategy::HYBRID);
    void* Allocate(size_t size);
    void Free(void* ptr);
    MemoryStats GetStats() const;
    void EnableGarbageCollection(bool enable);

private:
    std::unique_ptr<GarbageCollector> gc_;
    AllocationStrategy strategy_;
    MemoryStats stats_;
    std::mutex mutex_;
};

// Configuration namespace with enhanced features
namespace Config {
    struct VMConfig {
        size_t stackSize = 1024 * 1024;
        size_t heapSize = 1024 * 1024 * 1024;
        bool enableJIT = false;
        bool enableDebugMode = false;
        MemoryManager::AllocationStrategy memoryStrategy;
        std::vector<std::string> searchPaths;
    };

    class ConfigBuilder {
    public:
        ConfigBuilder& SetStackSize(size_t size);
        ConfigBuilder& SetHeapSize(size_t size);
        ConfigBuilder& EnableJIT(bool enable);
        ConfigBuilder& EnableDebugMode(bool enable);
        ConfigBuilder& SetMemoryStrategy(MemoryManager::AllocationStrategy strategy);
        ConfigBuilder& AddSearchPath(const std::string& path);
        VMConfig Build();
    };

    template<typename T>
    using Func = std::function<T>;

    namespace Set {
        class RequiredExitCode {
        public:
            static RequiredExitCode Success(int code, const std::string& hex);
            static RequiredExitCode Failure(int code, const std::string& reason);
        private:
            RequiredExitCode(int code, const std::string& hex, bool success);
            int code_;
            std::string hex_;
            bool success_;
        };
    }
}

// Enhanced VM class
class VM {
public:
    explicit VM(const Config::VMConfig& config);
    ~VM();

    void Execute(const std::string& bytecode);
    void LoadModule(const std::string& modulePath);
    void RegisterCallback(const std::string& name, std::function<void()> callback);
    void Pause();
    void Resume();
    void Stop();

    template<typename T>
    T GetResult();

    MemoryManager& GetMemoryManager() { return *memoryManager_; }

private:
    std::unique_ptr<MemoryManager> memoryManager_;
    std::atomic<bool> running_;
    std::thread executionThread_;
    std::mutex mutex_;
    Config::VMConfig config_;
    // Add other private members as needed
};

// Main Oak class with enhanced functionality
class Oak {
public:
    static void Init(const Config::VMConfig& config = Config::VMConfig());
    static void Shutdown();

    template<typename... Args>
    static void VMSTART(int sector, Args... args) {
        // Implementation for variable arguments
    }

    static VM& GetCurrentVM();
    static void SetErrorHandler(std::function<void(ErrorCode, const std::string&)> handler);
    static void SetLogHandler(std::function<void(LogLevel, const std::string&)> handler);

private:
    static std::unique_ptr<VM> currentVM_;
    static std::mutex globalMutex_;
};

// Utility macros
#define OAK_TRY try {
#define OAK_CATCH } catch (const OakException& e) { \
    ErrorHandler::HandleError(ErrorCode::VM_INITIALIZATION_FAILED, e.what()); \
} catch (const std::exception& e) { \
    ErrorHandler::HandleError(ErrorCode::VM_INITIALIZATION_FAILED, e.what()); \
}

#define OAK_ASSERT(condition, message) \
    if (!(condition)) { \
        throw OakException(message); \
    }

} // namespace oak

#endif // LIBOAK_HPP
