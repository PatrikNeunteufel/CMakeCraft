// projects/exec/MinimalConsole/src/main.cpp
// ==========================================
// Minimal console application demonstrating BasicLogger
//
// Version: 0.2.0
// Date:    2025-12-07

#include <BasicLogger.h>
#include <iostream>

int main() {
    // Create logger with file output
    BasicLogger::Logger logger("minimal_console.log");
    logger.setLevel(BasicLogger::Level::Debug);
    
    // Log to both console and file
    logger.info("MinimalConsole started");
    logger.debug("Debug mode enabled");
    
    std::cout << "Hello World from MinimalConsole!" << std::endl;
    
    logger.info("Processing complete");
    logger.warning("This is a test warning");
    
    // Also demonstrate global logger
    BasicLogger::setLogLevel(BasicLogger::Level::Info);
    BasicLogger::logInfo("Using global logger");
    
    logger.info("MinimalConsole finished");
    
    return 0;
}
