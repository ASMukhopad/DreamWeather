//
//  Functions.swift
//  DreamWeather
//
//  Created by Alexander on 25.01.2023.
//

func setup<Type>(_ object: Type, block: (Type) -> Void) -> Type {
    block(object)
    return object
}
