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
        DispatchQueue.global(qos: .userInitiated).async {
            let diceRoll = Int(arc4random_uniform(99) + 1)
            usleep(UInt32(diceRoll))
            print("Ran \(text) on thread \(Thread.current) for \(diceRoll) milliseconds")
            completion()
        }
    }
    
    public func runTasks(times times:UInt) {
        print("Reactive Solution 1 ...")
        var producers = [SignalProducer<Void, NoError>]()
        
        for i in 1...times {
            let sp = SignalProducer<Void, NoError> { [weak self] (observer, disposable) in
                let text = String(i)
                self?.superSecretFunc(text, completion: {
                    observer.send(value: ())
                    observer.sendCompleted()
                })
            }
            producers.append(sp)
        }
        
        let fsp = SignalProducer<SignalProducer<Void, NoError>, NoError>(producers)
        
        fsp.flatten(.concat)
            .on(completed: {
                print("Done!")
            }, value: {}).start()
        
    }
}

let rso1 = ReactiveSolution1()
rso1.runTasks(times: 7)

/*:
 ## Sandbox
 
 A place where you can build your sand castles 🏖.
*/


