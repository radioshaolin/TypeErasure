import UIKit

enum Result<T> {
    case success([T])
    case failure
}

// MARK: - Protocol with associated type example
protocol Loader {
    associatedtype DataType
    
    func load(completion: @escaping (Result<DataType>) -> Void)
}

// MARK: - Abstract base class
private class AnyLoaderBase<DataType>: Loader {
    init() {
        guard type(of: self) != AnyLoaderBase.self else {
            fatalError("_AnyPokemonBase<Power> instances can not be created; create a subclass instance instead")
        }
    }
    
    func load(completion: @escaping (Result<DataType>) -> Void) {
        fatalError("Must override")
    }
}

// MARK: - Box container class
private final class AnyLoaderBox<T: Loader>: AnyLoaderBase<T.DataType> {
    private let box: T

    init(_ box: T) { self.box = box }
    
    override func load(completion: @escaping (Result<DataType>) -> Void) {
        box.load(completion: completion)
    }
}

// MARK: - Loader Wrapper, public class
final class AnyLoader<DataType>: Loader {
    private let box: AnyLoaderBase<DataType>
    
    init<Concrete: Loader> (_ loader: Concrete) where Concrete.DataType == DataType {
        self.box = AnyLoaderBox(loader)
    }
    
    func load(completion: @escaping (Result<DataType>) -> Void) {
        box.load(completion: completion)
    }
}

// MARK: - Concrete realization of Loader protocol
struct IntLoader: Loader {
    typealias DataType = Int
    let data = [1488, 666]
    
    func load(completion: @escaping (Result<Int>) -> Void) {
        completion(.success(data))
    }
}

let intLoder = IntLoader()
let dataLoaderList = [AnyLoader(intLoder)]
dataLoaderList.map { $0.load { (result) in
        if case let .success(data) = result { print(data) }
    }
}
