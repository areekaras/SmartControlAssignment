//
//  User.swift
//  SmartControlAssignment
//
//  Created by Shibili Areekara on 18/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import Foundation

public struct ResponseData: Codable {
    let status:Int?
    let message:String?
    let data: UserData?
}

public struct UserData: Codable {
    let user:User?
    let token:String?
}

public struct User: Codable {
    let id:Int?
    let salutation:String?
    let title:String?
    let first_name:String?
    let last_name:String?
    let email:String?
    let phone:String?
    let role:String?
    let status:String?
    let company:Company?
}

public struct Company: Codable {
    let id:Int?
    let name:String?
    let email:String?
    let status:String?
}
