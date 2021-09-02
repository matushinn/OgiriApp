//
//  OgiriModel.swift
//  OgiriApp
//
//  Created by 大江祥太郎 on 2021/08/10.
//

import Foundation

struct OdaiModel:Codable{
    let hits:[Hits]
}

struct Hits:Codable {
    let webformatURL:String
}
