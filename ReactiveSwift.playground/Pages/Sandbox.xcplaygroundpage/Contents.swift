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

class ReactiveSolution1 {
    
    private func superSecretFunc(_ text:String, completion: @escaping (() -> Void)) {
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        
        concurrentQueue.sync {
        /*
        }
        DispatchQueue.global(qos: .userInitiated).async {
            */
            let diceRoll = Int(arc4random_uniform(8) + 1)
            usleep(UInt32(diceRoll * 1000000))
            print("Ran \(text) on thread \(Thread.current) for \(diceRoll) seconds")
            completion()
        }
    }
    
    public func runTasks(times times:UInt) {
        print("Reactive Solution 1 ...")
        var producers = [SignalProducer<Int, NoError>]()
        
        for i in 1...times {
            let sp = SignalProducer<Int, NoError> { [weak self] (observer, disposable) in
                let text = String(i)
                print("Create #\(text) signal.")
                self?.superSecretFunc(text, completion: {
                    print("#\(i) send value")
                    observer.send(value: Int(i * 3))
                    observer.sendCompleted()
                })
            }
            producers.append(sp)
        }
        
        let fsp = SignalProducer<SignalProducer<Int, NoError>, NoError>(producers)
        var initValue: Int = 0
        fsp.flatten(.merge)//change from .concat to .merge
            .observe(on: UIScheduler())
            .startWithValues { initValue in
                print("receive #\(initValue)")
        }
    }
}

let rso1 = ReactiveSolution1()
rso1.runTasks(times: 3)


