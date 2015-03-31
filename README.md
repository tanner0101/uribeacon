## UriBeacon Swift / Objc CocoaPod

Connect to the Physical web by using this Cocoapod to add UriBeacon functionality to your app.

# Add Podfile

In your Project's directory run

`pod init`

Open the newly created Podfile and add the following lines

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!

target '<<App Name Here>>' do
    pod 'UriBeacon'
end
```

Now download and install the Pod

`pod install`

# Implement UriBeacons

```swift

//
//  ViewController.swift
//  Physical Web
//
//  Created by Tanner Nelson on 3/31/15.
//  Copyright (c) 2015 Blue Bite. All rights reserved.
//

import UIKit
import UriBeacon

class ViewController: UIViewController, UriBeacon.DiscoveryDelegate {
    
    var beaconScanner: UriBeacon.Scanner?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.beaconScanner = UriBeacon.Scanner(delegate: self)
        self.beaconScanner?.startScanning()
    }
    
    func updateURIs() {
        print("URIs: ")
        println(self.beaconScanner?.uris)
    }
    
    func scanner(scanner: Scanner, discoveredURI: URI) {
        self.updateURIs()
    }
    
    func scanner(scanner: Scanner, lostURI: URI) {
        self.updateURIs()
    }
    
}

```