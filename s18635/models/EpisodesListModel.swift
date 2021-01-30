//
//  EpisodesListModel.swift
//  s18635
//
//  Created by DD on 03/01/2021.
//

struct EpisodesListModel: Decodable {
    let episode_id: Int
    let title: String
    let season: String
    let episode: String
    let series: String
}
