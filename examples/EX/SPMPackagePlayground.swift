import BrazeKit
import BrazeUI
import SegmentBraze
import SegmentBrazeUI

import DebugKit
import GoogleMaps
import SamplePackageA
import NetworkLogger
import OpenTelemetrySdk
import SnapKit
import SwiftUIX
import SwiftyBeaver

struct Foo {
    func check() {
        print(AnyButtonStyle.self) // SwiftUIX
        print(SwiftyBeaver.self) // SwiftyBeaver
        print(Constraint.self) // SnapKit
        print(DoubleCounterSdk.self) // OpenTelemetrySdk
        print(DebugKit.self) // DebugKit
        print(GMSAddress.self) // GoogleMaps
        
        print(BrazeKit.Location.self) // BrazeKit
        print(BrazeUI.AsyncImageView.self) // BrazeUI
        print(SegmentBraze.BrazeDestination.self) // SegmentBraze
        print(SegmentBrazeUI.BrazeDestination.self) // SegmentBrazeUI
    }
}

#if !NO_MACROS
//import Orcam
//import MacroCodableKit
//
//@AllOfCodable // MacroCodableKit
//@Init // Orcam
//struct FooMacro {
//  let x: Int
//}
#endif
