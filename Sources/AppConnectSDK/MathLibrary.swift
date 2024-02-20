//
//  MathLibrary.swift
//  
//
//  Created by Korn Isaranimitr on 20/2/2567 BE.
//

public struct MathLibrary {
    
    // Implementation for addition
    public static func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
    
    // Implementation for subtraction
    public static func subtract(_ a: Int, _ b: Int) -> Int {
        return a - b
    }
    
    // Implementation for multiplication
    public static func multiply(_ a: Int, _ b: Int) -> Int {
        return a * b
    }
    
    // Implementation for division
    public static func divide(_ a: Int, _ b: Int) -> Int {
        guard b != 0 else {
            fatalError("Division by zero is not allowed")
        }
        return a / b
    }
}
