//
//  main.swift
//  cert2json
//
//  Created by Luke Howard on 3/11/2022.
//

import Commandant
import Foundation

let commands = CommandRegistry<ParseCommand.Error>()
commands.register(ParseCommand())
commands.register(VersionCommand())
let helpCommand = HelpCommand(registry: commands)
commands.register(helpCommand)

commands.main(defaultVerb: helpCommand.verb) { error in
    print("\(error)")
}
