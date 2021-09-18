//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

@testable import UCFSMMachines
import XCTest


public class UCFSMMachinesParserTests: XCTestCase {

    public static var allTests: [(String, (UCFSMMachinesParserTests) -> () throws -> Void)] {
        return [
            ("test_meme", test_meme)
        ]
    }

    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()

    private var parser: UCFSMParser!

    public override func setUp() {
        super.setUp()
        self.parser = UCFSMParser()
    }
    
    func test_meme() {
//        let path = URL(fileURLWithPath: "\(packageRootPath)/machines/UltrasonicDiscrete.machine")
//        let machine = parser.parseMachine(location: path)
//        XCTAssertNotNil(machine)
    }

}
