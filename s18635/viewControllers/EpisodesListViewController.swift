//
//  EpisodesListViewController.swift
//  s18635
//
//  Created by DD on 03/01/2021.
//
import Alamofire
import UIKit

class EpisodesListViewController: UITableViewController {
    
    var loadedEpisodes: [EpisodesListModel]=[]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    //function from UITableViewController to point out number of rows that will be displayed
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedEpisodes.count
    }
    
    //function from UITableViewController to load data into cells using local class [EpisodeTableViewCell] as bridge
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeTableViewCell
        let episode = loadedEpisodes[indexPath.row]
        cell.titleLabel.text = episode.title
        if let episodeID = Int(episode.episode),let episodeSeas = Int(episode.season){
            cell.episodeSeasonLabel.text = "s\(String(format: "%02d", episodeSeas))e\(String(format: "%02d", episodeID))"
        }
        cell.seriesLabel.text = episode.series
        return cell
    }
    
    //function from UITableViewController to do sth when user press cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showEpisode", sender: nil)
    }
    
    //function from UITableViewController to deliver data to next ViewController [EpisodeViewController]
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showEpisode" else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let viewController = segue.destination as! EpisodeViewController
        viewController.indexEpisode = loadedEpisodes[indexPath.row].episode_id
    }
    
    //function to load data from external api, then decoding it to local model [EpisodesListModel]
    func reload() {
        AF.request("https://www.breakingbadapi.com/api/episodes").responseJSON{ response in
            if let error = response.error{
                self.presentError(title: "Request Failed", message: error.localizedDescription)
                return
            }
            if let data=response.data{
                do{
                    let episodes = try JSONDecoder().decode([EpisodesListModel].self,from: data)
                    self.loadedEpisodes = episodes
                    self.tableView.reloadData()
                }catch{self.presentError(title: "Request Failed", message: error.localizedDescription)}
            }
        }
    }
    
    //Pop-up message that presents the error during run
    func presentError(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reload", style: .default){ _ in self.reload() })
        self.present(alert, animated: true)
    }
}
class EpisodeTableViewCell: UITableViewCell {
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var episodeSeasonLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
}
