//
//  File.swift
//  
//
//  Created by Vaida on 6/8/24.
//

import Foundation


extension CommandReadableContent where Content: RawRepresentable & CaseIterable, Content.RawValue == String {
    
    public static func options(from options: Content.Type) -> CommandReadableContent<Content> { .init { read in
        guard let option = Content(rawValue: read) else { throw ReadError(reason: "Invalid Input: Input not in acceptable set") }
        return option
    } overrideGetLoop: { manager, content in
        content.__optionsGetLoop(manager: manager, shouldPrintPrompt: true, option: Content.self)
    } }
    
    
    private func __optionsGetLoop<Option>(manager: CommandReadManager<Content>, shouldPrintPrompt: Bool, option: Option.Type) -> Content where Option: RawRepresentable & CaseIterable, Option.RawValue == String {
        if shouldPrintPrompt {
            manager.__printPrompt()
        }
        
        var defaultValueLiteral: String? {
            if let defaultValue = manager.contentType.defaultValue, shouldPrintPrompt {
                return manager.contentType.formatter?(defaultValue) ?? "\(defaultValue)"
            }
            return nil
        }
        
        guard let option = CommandReadableContent<String>.unboundedOptions(from: Content.self).__askToChoose(from: Option.allCases.map(\.rawValue), defaultValueLiteral: defaultValueLiteral) else {
            Terminal.bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            fflush(stdout)
            return __optionsGetLoop(manager: manager, shouldPrintPrompt: false, option: Option.self)
        }
        
        if let defaultValue = manager.contentType.defaultValue, option.isEmpty {
            return defaultValue
        }
        
        do {
            guard let value = try self.initializer(option) else { throw ReadError(reason: "Invalid Input.") }
            
            let condition = try manager.condition?(value)
            guard condition ?? true else { throw ReadError(reason: "Invalid Input.") }
            
            return value
        } catch {
            if let error = error as? ReadError {
                print("\u{1B}[31m" + error.reason + "\u{1B}[0m")
            } else {
                print("\u{1B}[31m" + (error as NSError).localizedDescription + "\u{1B}[0m")
            }
            Swift.print("\u{1B}[31mTry again: \u{1B}[0m", terminator: "")
            fflush(stdout)
            
            return __optionsGetLoop(manager: manager, shouldPrintPrompt: false, option: Option.self)
        }
    }
    
}
