//
//  CharacterModel.swift
//  s18635
//
//  Created by DD on 06/01/2021.
//

struct CharacterModel:Decodable {
    let name:String
    let birthday:String
    let occupation:[String]
    let img:String
    let status:String
    let nickname:String
    let portrayed:String
}
