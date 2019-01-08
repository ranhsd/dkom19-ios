//
//  TFCandidate.swift
//  dkom-ios
//
//  Created by Ran Hassid on 08/01/2019.
//  Copyright © 2019 Trench Girls LTD. All rights reserved.
//

import UIKit
import Parse

class TFCandidate: PFObject {
    @NSManaged public var name: String?
    @NSManaged public var bio: String?
    @NSManaged public var profilePicture: PFFileObject?
    @NSManaged public var audioBio: PFFileObject?
}

extension TFCandidate : PFSubclassing {
    public static func parseClassName() -> String {
        return "Candidate"
    }
}
