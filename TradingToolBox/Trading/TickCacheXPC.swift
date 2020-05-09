//
//  TickCacheXPC.swift
//  BasicBox
//
//  Created by Lubor Kolacny on 2/5/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import Foundation
import Combine

@objc(TickCacheXPCProtocol) protocol TickCacheXPCProtocol {
    func areWeReady(reply: ((Bool, Double) -> Void)!)
    func getTicks(reply: ((Data?) -> Void)!)
}

public class TickCache: Publisher {
    public typealias Output = FlatPrice
    public typealias Failure = Error

    var sub: AnySubscriber<Output, Failure>?
    var subscription: TickCacheSubscription?
    
    var cancelled = false
    var mutex = pthread_mutex_t()
    
    public init() {}

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.sub = AnySubscriber(subscriber)
        subscription = TickCacheSubscription(combineIdentifier: CombineIdentifier(), cache: self, mutex: &mutex)
        subscriber.receive(subscription: subscription!)
        start()
    }
    
    private func start() {
        pthread_mutex_init(&mutex, nil)
        let connection = NSXPCConnection(machServiceName: "au.com.itroja.TickTackXPC")
        connection.remoteObjectInterface = NSXPCInterface(with: TickCacheXPCProtocol.self)
        connection.resume()

        let service = connection.remoteObjectProxyWithErrorHandler { error in
            self.sub?.receive(completion: .failure(error))
        } as? TickCacheXPCProtocol

        service!.getTicks { (aData) in
            var notCancelled = true
            aData!.withUnsafeBytes({ ptr in
                let i = ptr.bindMemory(to: FlatPrice.self)
                var bytes = i.enumerated().makeIterator()
                while notCancelled, let byte = bytes.next() {
                    pthread_mutex_lock(&self.mutex)
                    notCancelled = !self.cancelled
                    pthread_mutex_unlock(&self.mutex)
                    let price = byte.element
                    _ = self.sub?.receive(price)
                }
            })
            _ = self.sub?.receive(completion: .finished)
        }
    }
    
    struct TickCacheSubscription: Subscription {
        
        let combineIdentifier: CombineIdentifier
        weak var cache: TickCache?
        let mutex:UnsafeMutablePointer<pthread_mutex_t>
        
        func request(_ demand: Subscribers.Demand) {
        }

        func cancel() {
            pthread_mutex_lock(mutex)
            cache?.cancelled = true
            pthread_mutex_unlock(mutex)
        }
    }
}
