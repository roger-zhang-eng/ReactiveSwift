/*:
 > # IMPORTANT: To use `ReactiveSwift.playground`, please:
 
 1. Retrieve the project dependencies using one of the following terminal commands from the ReactiveSwift project root directory:
    - `git submodule update --init`
 **OR**, if you have [Carthage](https://github.com/Carthage/Carthage) installed
    - `carthage checkout --no-use-binaries`
 1. Open `ReactiveSwift.xcworkspace`
 1. Build `Result-Mac` scheme
 1. Build `ReactiveSwift-macOS` scheme
 1. Finally open the `ReactiveSwift.playground`
 1. Choose `View > Show Debug Area`
 */

import Result
import ReactiveSwift
import Foundation
import PlaygroundSupport

class ReactiveSolution1 {
    var fsp: SignalProducer<SignalProducer<Int, NoError>, NoError>!
    
    private func superSecretFunc(_ text:String, completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let delayValue = Int(arc4random_uniform(15) + 1)
            print("\(text) on thread \(Thread.current) for delay \(delayValue) units")
            usleep(UInt32(delayValue) * 500000)
            
            completion()
        }
    }
    
    public func runTasks(times:Int) {
        print("runTasks by \(times) ...")
        var producers = [SignalProducer<Int, NoError>]()
        
        for i in 1...times {
            debugPrint("Create #\(i)")
            let sp = SignalProducer<Int, NoError> { [weak self] observer, disposable in
                let strongSelf = self!
                let inputText = "#\(i)"
                strongSelf.superSecretFunc(inputText) {
                    let sentValue =  i * 3
                    debugPrint("#\(i) send value \(sentValue)")
                    observer.send(value: sentValue)
                    observer.sendCompleted()
                }
            }
            producers.append(sp)
        }
        
        self.fsp = SignalProducer<SignalProducer<Int, NoError>, NoError>(producers)
        
    }
    
    func observeSignals() {
        // merge will get value once any signal sends, regardless complete.
        // concat will wait the 1st signal value and complete, then accept 2nd signal value, then one by one
        // latest will complete if the last SP completes, only get the last value
        debugPrint("observeSignals begin to observe by merge...")
        self.fsp.flatten(.merge)
            .on(completed: {
                print("observeSignals Done!")
            }, value: { gotValue in
                print("observeSignals get value: \(gotValue)")
            }).start()
    }
}

//Avoiding playground execution ends earlier than thread processing, need manually run playground and stop it.
PlaygroundPage.current.needsIndefiniteExecution = true

let rso1 = ReactiveSolution1()
rso1.runTasks(times: 5)
rso1.observeSignals()

