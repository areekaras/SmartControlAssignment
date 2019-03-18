//
//  Machine.swift
//  SmartControlAssignment
//
//  Created by Shibili Areekara on 18/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import Foundation

public struct AssetsApiDats: Codable {
    let status:Int?
    let message:String?
    let data: MachineData?
}

public struct MachineData: Codable {
    let assets:[Asset]?
}

public struct Asset: Codable {
    let id:Int?
    let name:String?
    let status:String?
    let availability:String?
    let image:Image?
}

public struct Image: Codable {
    let id:Int?
    let url:String?
    let isdeleted:Int?
}


