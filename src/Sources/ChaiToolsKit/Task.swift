//
//  Task.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/17/17.
//
//

/// Generic Result enum object
///
/// - success(T?): contains generic `T` value for success case
/// - error(Error): object that conforms to `Error` protocol for error case
public enum Result<T, Error> {

    case success(T?)
    case failure(Error)

    /// If `self` is `.success(T)`, return value
    var result: T? {
        guard case .success(let data) = self else {
            return nil
        }
        return data
    }
}

/// Errors that can be generated by `Task` Object
///
/// - unknown: unknown issue
/// - missingTask: A `taskBlock` was not set inside of `Task` Object
public enum TaskError: Error {
    case unknown
    case missingTask
}

/// `typealias` of object returned once a `taskBlock` has ran
typealias TaskResult = Result<Any, Error>

/// `typealias` for `(Void) -> Void`
typealias VoidCompletion = (Void) -> Void


/// An object that saves `taskBlock`(completion block) for later use.
/// Also contains `success` and `failure` completion blocks.
public struct Task {

    /// Name of Task, typically used for identifying purposes
    var name: String!

    /// Completion block to be ran
    var taskBlock: ((TaskResult) -> TaskResult)?

    /// Completion Block to run if `taskBlock` is successful
    var successBlock: VoidCompletion?

    /// Completion Block to run if `taskBlock` fails
    var failureBlock: VoidCompletion?

    /// Initialize `Task` object
    ///
    /// - Parameters:
    ///   - name: Used as an identifier for Task.
    ///   - task: Completion block to be ran
    init(name: String,
         task: ((TaskResult) -> TaskResult)? = nil,
         success: VoidCompletion? = nil,
         failure: VoidCompletion? = nil) {
        self.name = name
        taskBlock = task
        successBlock = success
        failureBlock = failure
    }

    /// Executes `taskBlock` completion block and returns `.success` or `.failure`
    /// depending on `input` parameter
    ///
    /// - Parameter input: `TaskResult` from previously executed `Task`.
    /// - Returns: `TaskResult` object containing `.success(Any)` or `.failure(Error)`.
    func execute(_ input: TaskResult) -> TaskResult {

        if case .failure = input { return input }

        guard let nextParam = taskBlock?(input)
            else { return .failure(TaskError.missingTask) }

        switch nextParam {
        case .success(let x):
            successBlock?()

            // Check to see if we passed a TaskResult Object(typically very first object)
            if let y = x as? TaskResult, case .success(let z) = y {
                return .success(z)
            }
            return nextParam
        default:
            failureBlock?()
            return .failure(TaskError.unknown)
        }
    }

    /// Syntax sugar method allowing user to set `taskBlock` completion block.
    ///
    /// - Parameter completion: Completion Block to run when `execute(:)` is called
    /// - Returns: copy of `self`
    func task(_ completion: ((TaskResult) -> TaskResult)?) -> Task {
        var copySelf = self
        copySelf.taskBlock = completion
        return copySelf
    }

    /// Syntax sugar method allowing user to set `failureBlock` completion block.
    ///
    /// - Parameter completion: Completion Block to run if `taskBlock` is successful
    /// - Returns: copy of `self`
    func success(_ completion: VoidCompletion?) -> Task {
        var copySelf = self
        copySelf.successBlock = completion
        return copySelf
    }

    /// Syntax sugar method allowing user to set `successBlock` completion block.
    ///
    /// - Parameter completion: Completion Block to run if `taskBlock` fails
    /// - Returns: copy of `self`
    func failure(_ completion: VoidCompletion?) -> Task {
        var copySelf = self
        copySelf.failureBlock = completion
        return copySelf
    }
}


/// Object is responsible for executing `Tasks`
public struct TaskRunner {

    /// Syntax sugar to execute `[Task]`
    ///
    /// - Parameter tasks: Array of `Task` to be executed
    /// - Returns: `TaskResult` containing `.success(Any)` or `.failure(Error)`
    static func execute(_ tasks: [Task]) -> TaskResult {
        return tasks.reduce(TaskResult.success(nil), { $1.execute($0) })
    }
}
