//
//  EpisodeModel.swift
//  s18635
//
//  Created by DD on 03/01/2021.
//

struct EpisodeModel: Decodable {
    let episode_id: Int
    let title: String
    let season: String
    let air_date: String
    let characters: [String]
    let episode: String
    let series: String
}
