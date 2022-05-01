//
//  RebaseCommand.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import Foundation

enum RebaseCommandType: String, CaseIterable, Identifiable {
    case pick, reword, edit, squash, fixup,
         exec, `break`, drop, label, reset,
         merge

    var id: RebaseCommandType { self }

    func command(sha: String, fixup options: RebaseCommand.FixupMessageOptions) -> RebaseCommand? {
        switch self {
        case .pick:
            return .pick(sha: sha)
        case .reword:
            return .reword(sha: sha)
        case .edit:
            return .edit(sha: sha)
        case .squash:
            return .squash(sha: sha)
        case .fixup:
            return .fixup(sha: sha, options)
        case .drop:
            return .drop(sha: sha)
        default:
            return nil
        }
    }
}

enum RebaseCommand: Identifiable {
    /// `p, pick <commit>` = use commit
    case pick(sha: String)

    /// `r, reword <commit>` = use commit, but edit the commit message
    case reword(sha: String)

    /// `e, edit <commit>` = use commit, but stop for amending
    case edit(sha: String)

    /// `s, squash <commit>` = use commit, but meld into previous commit`
    case squash(sha: String)

    /// `f, fixup [-C | -c] <commit>` = like "squash" but keep only the previous
    /// commit's log message, unless `-C` is used, in which case keep only this commit's
    /// message; `-c` is same as `-C` but opens the editor
    case fixup(sha: String, FixupMessageOptions)

    /// `x, exec <command>` = run command (the rest of the line) using shell
    case exec(command: String)
    /// `b, break` = stop here (continue rebase later with `git rebase --continue`)
    case `break`
    /// `d, drop <commit>` = remove commit
    case drop(sha: String)
    /// `l, label <label>` = label current HEAD with a name`
    case label(label: String)
    /// `t, reset <label> = reset HEAD to a label`
    case reset(label: String)

    /// `m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]`
    /// create a merge commit using the original merge commit's message (or the oneline,
    /// if no original merge commit was specified); use `-c <commit>` to reword the commit message
    case merge(originalCommit: (sha: String, reword: Bool)?, label: String, oneline: String?)

    enum FixupMessageOptions: String, CaseIterable {
        case discard = ""
        case use = "-C "
        case useAndEdit = "-c "
    }

    var rawValue: String {
        switch self {
        case .pick(let sha): return "pick \(sha)"
        case .reword(let sha): return "reword \(sha)"
        case .edit(let sha): return "edit \(sha)"
        case .squash(let sha): return "squash \(sha)"
        case let .fixup(sha, options): return "fixup \(options.rawValue)\(sha)"
        case .exec(let command): return "exec \(command)"
        case .break: return "break"
        case .drop(let sha): return "drop \(sha)"
        case .label(let label): return "label \(label)"
        case .reset(let label): return "reset \(label)"
        case let .merge(originalCommit, label, oneline):
            let arg: String
            if let originalCommit = originalCommit {
                arg = "-\(originalCommit.reword ? "c" : "C") \(originalCommit.sha) "
            } else {
                arg = ""
            }
            return "merge \(arg)\(label)\(oneline.map { " # \($0)" } ?? "")"
        }
    }

    static func parse(contentsOf url: URL) -> [RebaseCommand]? {
        if let document = try? String(contentsOf: url, encoding: .utf8) {
            return parse(document)
        } else {
            return nil
        }
    }

    static func parse(_ document: String) -> [RebaseCommand] {
        document.split(separator: "\n").compactMap(parse(line:))
    }

    static func parse<S: StringProtocol>(line: S) -> RebaseCommand? {
        if line.trimmingCharacters(in: .whitespaces).isEmpty
            || line.starts(with: "#") {
            return nil
        }
        let tokens = RebaseCommandParser.tokenize(line: line)

        // broken up because the swift compiler is slow
        let result =  RebaseCommandParser.pick(tokens)
        ?? RebaseCommandParser.reword(tokens)
        ?? RebaseCommandParser.edit(tokens)

        let result2 = result
        ?? RebaseCommandParser.squash(tokens)
        ?? RebaseCommandParser.fixup(tokens)
        ?? RebaseCommandParser.exec(tokens, line: line)

        let result3 = result2
        ?? RebaseCommandParser.break(tokens)
        ?? RebaseCommandParser.drop(tokens)
        ?? RebaseCommandParser.label(tokens)

        return result3
        ?? RebaseCommandParser.reset(tokens)
        ?? RebaseCommandParser.merge(tokens, line: line)
    }

    var id: RebaseCommand { self }
}

extension RebaseCommand: Hashable {
    static func == (lhs: RebaseCommand, rhs: RebaseCommand) -> Bool {
        switch (lhs, rhs) {
        case (.pick(let lhs), .pick(let rhs)): return lhs == rhs
        case (.reword(let lhs), .reword(let rhs)): return lhs == rhs
        case (.edit(let lhs), .edit(let rhs)): return lhs == rhs
        case (.squash(let lhs), .squash(let rhs)): return lhs == rhs
        case (.fixup(let lhs, let loptions), .fixup(let rhs, let roptions)):
            return lhs == rhs && loptions == roptions
        case (.exec(let lhs), .exec(let rhs)): return lhs == rhs
        case (.break, .break): return true
        case (.drop(let lhs), .drop(let rhs)): return lhs == rhs
        case (.label(let lhs), .label(let rhs)): return lhs == rhs
        case (.reset(let lhs), .reset(let rhs)): return lhs == rhs
        case let (.merge(lcommit, llabel, loneline), .merge(rcommit, rlabel, roneline)):
            return lcommit?.sha == rcommit?.sha && lcommit?.reword == rcommit?.reword && llabel == rlabel && loneline == roneline
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .pick(let sha):
            hasher.combine("pick")
            hasher.combine(sha)
        case .reword(let sha):
            hasher.combine("reword")
            hasher.combine(sha)
        case .edit(let sha):
            hasher.combine("edit")
            hasher.combine(sha)
        case .squash(let sha):
            hasher.combine("squash")
            hasher.combine(sha)
        case .fixup(let sha, let fixupMessageOptions):
            hasher.combine("reword")
            hasher.combine(sha)
            hasher.combine(fixupMessageOptions)
        case .exec(let command):
            hasher.combine("exec")
            hasher.combine(command)
        case .break:
            hasher.combine("break")
        case .drop(let sha):
            hasher.combine("drop")
            hasher.combine(sha)
        case .label(let label):
            hasher.combine("label")
            hasher.combine(label)
        case .reset(let label):
            hasher.combine("reset")
            hasher.combine(label)
        case .merge(let originalCommit, let label, let oneline):
            hasher.combine("merge")
            hasher.combine(originalCommit?.sha)
            hasher.combine(originalCommit?.reword)
            hasher.combine(label)
            hasher.combine(oneline)
        }
    }
}

struct Token {
    let value: String
    let start: String.Index
}

private enum RebaseCommandParser {
    static func tokenize<S: StringProtocol>(line: S) -> [Token] {
        let result: (tokens: [Token], next: Token) = line
            .enumerated()
            .reduce((tokens: [], next: Token(value: "", start: line.startIndex))) {
                (state, elt) in
                let (idx, char) = elt
                if char.isWhitespace {
                    if state.next.value.isEmpty {
                        return (
                            state.tokens,
                            Token(value: "", start: line.index(state.next.start, offsetBy: 1))
                        )
                    } else {
                        return (
                            state.tokens + [state.next],
                            Token(value: "", start: line.index(line.startIndex, offsetBy: idx))
                        )
                    }
                } else {
                    return (
                        state.tokens,
                        Token(value: state.next.value + String(char), start: state.next.start)
                    )
                }
            }
        return result.tokens + (result.next.value.isEmpty ? [] : [result.next])
    }

    private static func makeNames(_ funcName: String) -> [String] {
        let name = funcName.firstIndex(of: "(").map(funcName.prefix(upTo:)).map(String.init) ?? funcName
        if let first = name.first.map(String.init) {
            return [name, first]
        }
        return [name]
    }

    private static func validate(
        _ tokens: [Token],
        names: [String] = makeNames(#function),
        args: Int
    ) -> [Token]? {
        validate(tokens, names: names, args: args...args)
    }

    private static func validate<R: RangeExpression>(
        _ tokens: [Token],
        _name: String = #function,
        names: [String]? = nil,
        args argCountRange: R
    ) -> [Token]? where R.Bound == Int {
        let names = names ?? makeNames(_name)
        guard
            let first = tokens.first?.value,
            names.contains(first),
            argCountRange.contains(tokens.count - 1)
        else { return nil }
        return Array(tokens.dropFirst())
    }

    private static func validateOne(
        _ command: (String) -> RebaseCommand,
        _name: String = #function,
        names: [String]? = nil,
        tokens: [Token]
    ) -> RebaseCommand? {
        validate(tokens, names: names ?? makeNames(_name), args: 1...).map { command($0[0].value) }
    }

    static func pick(_ tokens: [Token]) -> RebaseCommand? { validateOne(RebaseCommand.pick, tokens: tokens) }
    static func reword(_ tokens: [Token]) -> RebaseCommand? { validateOne(RebaseCommand.reword, tokens: tokens) }
    static func edit(_ tokens: [Token]) -> RebaseCommand? { validateOne(RebaseCommand.edit, tokens: tokens) }
    static func squash(_ tokens: [Token]) -> RebaseCommand? { validateOne(RebaseCommand.squash, tokens: tokens) }
    static func drop(_ tokens: [Token]) -> RebaseCommand? { validateOne(RebaseCommand.drop, tokens: tokens) }
    static func label(_ tokens: [Token]) -> RebaseCommand? { validateOne(RebaseCommand.label, tokens: tokens) }
    static func reset(_ tokens: [Token]) -> RebaseCommand? { validateOne(RebaseCommand.reset, names: ["t", "reset"], tokens: tokens) }

    static func `break`(_ tokens: [Token]) -> RebaseCommand? {
        guard validate(tokens, args: 0) != nil else { return nil }
        return .break
    }

    static func fixup(_ tokens: [Token]) -> RebaseCommand? {
        guard let args = validate(tokens, args: 1...) else { return nil }
        if let options = RebaseCommand.FixupMessageOptions(rawValue: args[0].value + " ") {
            return .fixup(sha: args[1].value, options)
        }
        return .fixup(sha: args[0].value, .discard)
    }

    static func exec<S: StringProtocol>(_ tokens: [Token], line: S) -> RebaseCommand? {
        guard let args = validate(tokens, names: ["x", "exec"], args: 1...) else { return nil }
        return .exec(command: String(line[args[0].start...]))
    }

    static func merge<S: StringProtocol>(_ tokens: [Token], line: S) -> RebaseCommand? {
        guard let args = validate(tokens, args: 1...) else { return nil }
        if args.count == 1 {
            return .merge(originalCommit: nil, label: args[1].value, oneline: nil)
        } else if args[0].value.lowercased() == "-c" {
            guard args.count >= 3 else { return nil }
            return .merge(
                originalCommit: (sha: args[1].value, reword: args[0].value.last == "c"),
                label: args[2].value,
                oneline: args.count >= 5 ? String(line[args[4].start...]) : nil
            )
        } else if args.count > 2 {
            return .merge(originalCommit: nil, label: args[0].value, oneline: String(line[args[2].start...]))
        }
        return nil
    }
}

let sample = """
pick 2111d70 Add https://github.com/stevengharris/MarkupEditor
pick 3fcebc6 Add Hammer package
pick a4eb9e6 Update packages.json # empty
pick ccb7a53 Update packages.json # empty
pick 38b5c13 Add newline
pick d253b80 Remove newline
pick fae2974 Try to remove newline again
pick e551d42 add google sign in
pick 47e2e77 Change the project's license to Apache 2.0.
pick e36b3fc Added theblixguy/Once.
pick 8ecad3f Added EUDCCKit
pick f3141dc Added missing .git Extension
pick fbeab96 Added packages
pick e656820 Removed blank line.
pick 49e1ccb Add MenuBuilder

# Rebase 5664cc6..49e1ccb onto 5664cc6 (15 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup [-C | -c] <commit> = like "squash" but keep only the previous
#                    commit's log message, unless -C is used, in which case
#                    keep only this commit's message; -c is same as -C but
#                    opens the editor
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
# .       message (or the oneline, if no original merge commit was
# .       specified); use -c <commit> to reword the commit message
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#

"""
