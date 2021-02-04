//
//  Model.swift
//  PryanikiTestTask
//
//  Created by Maxim Alekseev on 03.02.2021.
//

import Foundation

struct ResourceResponse: Decodable {
    
    var data: [ResourceData]
    var view: [String]
    
}

struct ResourceData: Decodable {

    var name: String
    var data: ResourceElementData
}

struct ResourceElementData: Decodable {
    
    var text: String?
    var url: String?
    var selectedId: Int?
    var variants: [Variant]?
}

struct Variant: Decodable {
    var id: Int
    var text: String
}
