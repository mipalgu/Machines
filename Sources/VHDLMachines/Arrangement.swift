//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// An arrangement represents a collection of machines that are executing together. An arrangment has a set of
/// parent machines which act as entry points into the program. This structure does not infer any execution
/// order for the machines in this arrangement. Instead, this arrangement simply defines the machines and the
/// capability of each machine (Suspensible, Parameterised, Custom Ringlets etc).
/// 
/// A machine is represented with a name and URL to it's location in the file system. From the arrangements
/// perspective, the only variables defined here are the external variables (and signals), and clocks that
/// also act as a special external signal. The arrangment variables defined in this struct are available to
/// all machines within the same arrangement and act as variables with global scope.
public struct Arrangement: Equatable, Hashable, Codable {

    /// All machines in the arrangement.
    public var machines: [MachineName: URL]

    /// The external signals in the arrangement that map to physical pins.
    public var externalSignals: [PortSignal]

    /// The signals local to every machine in the arrangement, but do not map to external devices.
    public var signals: [LocalSignal]

    /// The clocks in the arrangement available to every machine.
    public var clocks: [Clock]

    /// The parent machines in the arrangement. These machines act as entry points into the main program
    /// of this arrangement.
    public var parents: [MachineName]

    /// The path to the arrangement. This is the path to the file containing the arrangement definition. This
    /// path will be used to persist the arrangement.
    public var path: URL

    /// Initialises the arrangement with the given values.
    /// - Parameters:
    ///   - machines: The machines in the arrangement.
    ///   - externalSignals: The external signals in the arrangement.
    ///   - externalVariables: The external variables in the arrangement.
    ///   - clocks: The clocks in the arrangement.
    ///   - parents: The parent machines in the arrangement.
    ///   - path: The file path to the arrangement.
    public init(
        machines: [MachineName: URL],
        externalSignals: [PortSignal],
        signals: [LocalSignal],
        clocks: [Clock],
        parents: [MachineName],
        path: URL
    ) {
        self.machines = machines
        self.externalSignals = externalSignals
        self.signals = signals
        self.clocks = clocks
        self.parents = parents
        self.path = path
    }

    /// Create an initial arrangement located at the given URL. This arrangement will contain a single machine
    /// called *Machine* that will exist within the same directory as the arrangement folder.
    /// - Parameter url: The URL to the arrangement folder.
    /// - Returns: The initial arrangement.
    @inlinable
    public static func initial(url: URL) -> Arrangement {
        let machineURL = url.deletingLastPathComponent().appendingPathComponent(
            "Machine.machine", isDirectory: true
        )
        let newMachine = Machine.initial(path: machineURL)
        let clock = newMachine.clocks
        return Arrangement(
            machines: ["Machine": machineURL],
            externalSignals: [],
            signals: [],
            clocks: clock,
            parents: ["Machine"],
            path: url
        )
    }

}
