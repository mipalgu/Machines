//
//  File.swift
//  
//
//  Created by Morgan McColl on 2/6/21.
//

import Foundation

struct ChainValidator<Path: ReadOnlyPathProtocol, Validator: ValidatorProtocol>: ValidatorProtocol where Path.Value == Validator.Root {

  var path: Path

  var validator: Validator

  init(path: Path, validator: Validator) {
    self.path = path
    self.validator = validator
  }

  func performValidation(_ root: Path.Root) throws {
    let value = root[keyPath: path.keyPath]
    try validator.performValidation(value)
  }

}
