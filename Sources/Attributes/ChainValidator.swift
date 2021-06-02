//
//  File.swift
//  
//
//  Created by Morgan McColl on 2/6/21.
//

import Foundation

struct ChainValidator<Path: ReadOnlyPathProtocol>: ValidatorProtocol {

  var path: Path

  var validator: AnyValidator<Path.Value>

  init(path: Path, validator: AnyValidator<Path.Value>) {
    self.path = path
    self.validator = validator
  }

  func performValidation(_ root: Path.Root) throws {
    let value = root[keyPath: path.keyPath]
    try validator.performValidation(value)
  }

}
