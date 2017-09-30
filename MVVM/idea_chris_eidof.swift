//
//  idea_chris_eidof.swift
//  QuantwmOSX
//
//  Created by Xavier on 25/07/2017.
//  Copyright © 2017 XL Software Solutions. All rights reserved.
//

import Foundation

final class Disposable {
    private let dispose: () -> ()
    init(_ dispose: @escaping () -> ()) {
        self.dispose = dispose
    }

    deinit {
        dispose()
    }
}


final class Ref<A> {
    typealias Observer = (A) -> ()

    private let _get: () -> A
    private let _set: (A) -> ()
    private let _addObserver: (@escaping Observer) -> Disposable

    var value: A {
        get {
            return _get()
        }
        set {
            _set(newValue)
        }
    }

    init(get: @escaping () -> A, set: @escaping (A) -> (), addObserver: @escaping (@escaping Observer) -> Disposable) {
        _get = get
        _set = set
        _addObserver = addObserver
    }

    func addObserver(observer: @escaping Observer) -> Disposable {
        return _addObserver(observer)
    }
}

extension Ref {
    convenience init(initialValue: A) {
        var observers: [Int: Observer] = [:]
        var theValue = initialValue {
            didSet {
                observers.values.forEach { $0(theValue) }
            }
        }
        var freshId = (Int.min...).makeIterator()
        let get = { theValue }
        let set = { newValue in
            theValue = newValue
        }
        let addObserver = { (newObserver: @escaping Observer) -> Disposable in
            let id = freshId.next()!
            observers[id] = newObserver
            return Disposable {
                observers[id] = nil
            }
        }
        self.init(get: get, set: set, addObserver: addObserver)
    }
}

extension Ref {
    subscript<B>(keyPath: WritableKeyPath<A,B>) -> Ref<B> {
        let parent = self
        return Ref<B>(get: { parent._get()[keyPath: keyPath] }, set: {
            var oldValue = parent.value
            oldValue[keyPath: keyPath] = $0
            parent._set(oldValue)

        }, addObserver: { observer in
            parent.addObserver { observer($0[keyPath: keyPath]) }
        })
    }
}

extension Ref where A: MutableCollection {
    subscript(index: A.Index) -> Ref<A.Element> {
        return Ref<A.Element>(get: { self._get()[index] }, set: { newValue in
            var old = self.value
            old[index] = newValue
            self._set(old)
        }, addObserver: { observer in
            self.addObserver { observer($0[index]) }
        })
    }
}

struct History<A> {
    private let initialValue: A
    private var history: [A] = []
    private var redoStack: [A] = []
    var value: A {
        get {
            return history.last ?? initialValue
        }
        set {
            history.append(newValue)
            redoStack = []
        }
    }

    init(initialValue: A) {
        self.initialValue = initialValue
    }

    mutating func undo() {
        guard let item = history.popLast() else { return }
        redoStack.append(item)
    }

    mutating func redo() {
        guard let item = redoStack.popLast() else { return }
        history.append(item)
    }
}

struct Address {
    var street: String
}
struct Person {
    var name: String
    var addresses: [Address]
}

typealias Addressbook = [Person]

//let source: Ref<History<Addressbook>> = Ref(initialValue: History(initialValue: []))
//let addressBook: Ref<Addressbook> = source[\.value]
//addressBook.value.append(Person(name: "Test", addresses: []))
//addressBook[0].value.name = "New Name"
//print(addressBook[0].value)
//source.value.undo()
//print(addressBook[0].value)
//source.value.redo()
//
//var twoPeople: Ref<Addressbook> = Ref(initialValue:
//    [Person(name: "One", addresses: []),
//     Person(name: "Two", addresses: [])])
//let p0 = twoPeople[0]
//twoPeople.value.removeFirst()
//print(p0.value)

