import XCTest

import SwiftMachinesTests

XCTMain([
    testCase(MachineAssemblerTests.allTests),
    // testCase(MachineCompilerTests.allTests),
    testCase(MachineParserTests.allTests)]
)
