//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import GUUnits
import Foundation

/// A clock represents an oscillating signal with a constant frequency/period.
public struct Clock: Codable {

    /// The units of frequency.
    public enum FrequencyUnit: String, CaseIterable, Codable {

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
    public var name: String

    /// The frequency of the clock represented with the frequency `unit`.
    public var frequency: UInt

    /// The unit of frequency.
    public var unit: FrequencyUnit

    /// The period of the clock.
    public var period: Time {
        let freq = Double(frequency)
        switch unit {
        case .Hz:
            return Time.milliseconds(1000.0 / freq)
        case .kHz:
            return Time.microseconds(1000.0 / freq)
        case .MHz:
            return Time.microseconds(1.0 / freq)
        case .GHz:
            return Time.microseconds(0.001 / freq)
        case .THz:
            return Time.microseconds(0.000001 / freq)
        }
    }

    /// Initialise a clock with the given name, frequency and unit.
    /// - Parameters:
    ///   - name: The name of the clock.
    ///   - frequency: The frequency of the clock represented with the frequency `unit`.
    ///   - unit: The unit of frequency.
    public init(name: String, frequency: UInt, unit: FrequencyUnit) {
        self.name = name
        self.frequency = frequency
        self.unit = unit
    }

}
