//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import GUUnits
import VHDLParsing

/// A clock represents an oscillating signal with a constant frequency/period.
public struct Clock: Codable, Equatable, Hashable, Sendable {

    /// The units of frequency.
    public enum FrequencyUnit: String, CaseIterable, Codable, Sendable {

        // swiftlint:disable identifier_name

        /// Hertz.
        case Hz

        // swiftlint:enable identifier_name

        /// kiloHertz.
        case kHz

        /// MegaHertz.
        case MHz

        /// GigaHertz.
        case GHz

        /// TeraHertz.
        case THz

    }

    /// The name of the clock.
    public var name: VariableName

    /// The frequency of the clock represented with the frequency `unit`.
    public var frequency: UInt

    /// The unit of frequency.
    public var unit: FrequencyUnit

    /// The period of the clock.
    @inlinable public var period: Time {
        let freq = Double(frequency)
        switch unit {
        case .Hz:
            return Time.milliseconds(1000.0 / freq)
        case .kHz:
            return Time.microseconds(1000.0 / freq)
        case .MHz:
            return Time.nanoseconds(1000.0 / freq)
        case .GHz:
            return Time.picoseconds(1000.0 / freq)
        case .THz:
            return Time.picoseconds(1.0 / freq)
        }
    }

    /// Initialise a clock with the given name, frequency and unit.
    /// - Parameters:
    ///   - name: The name of the clock.
    ///   - frequency: The frequency of the clock represented with the frequency `unit`.
    ///   - unit: The unit of frequency.
    @inlinable
    public init(name: VariableName, frequency: UInt, unit: FrequencyUnit) {
        self.name = name
        self.frequency = frequency
        self.unit = unit
    }

}
