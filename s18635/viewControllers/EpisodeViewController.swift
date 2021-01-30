//
//  EpisodeViewController.swift
//  s18635
//
//  Created by DD on 04/01/2021.
//

import UIKit
import Alamofire

class EpisodeViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    //loaded from func prepare in EpisodeListViewController
    var indexEpisode: Int? = nil
    
    var loadedEpisode: EpisodeModel? = nil
    var loadedCharacters: [String] = []
    
    override func viewDidLoad() {
        self.tableView.delegate=self
        self.tableView.dataSource=self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reload()
    }
    
    //function to load data from external api, then decoding it to local model [EpisodeModel]
    func reload(){
        guard let episodeID = indexEpisode else{return}
        AF.request("https://www.breakingbadapi.com/api/episodes/\(episodeID)/").responseJSON{ response in
            if let error = response.error{
                self.presentError(title: "Request Failed", message: error.localizedDescription)
                return
            }
            if let data=response.data{
                do{
                    let episode = try JSONDecoder().decode([EpisodeModel].self,from: data)
                    
                    //api returns list of Objects [EpisodeModel] that contains 1 element
                    self.loadedEpisode = episode[0]
                    self.reloadData()
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
    
    //function to load data from local model into existing labels in UI
    func reloadData() {
        guard let currentEpisode=loadedEpisode else {return}
        if let episodeID = Int(currentEpisode.episode), let episodeSeas = Int(currentEpisode.season){
            navigationItem.title="s\(String(format: "%02d", episodeSeas))e\(String(format: "%02d", episodeID))"
        }
        titleLabel.text=currentEpisode.title
        episodeLabel.text=currentEpisode.episode
        seasonLabel.text=currentEpisode.season
        airdateLabel.text=currentEpisode.air_date
        seriesLabel.text=currentEpisode.series
        
        loadedCharacters=currentEpisode.characters
        tableView.reloadData()
    }
    
    //function from UITableView to point out number of rows that will be displayed
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedCharacters.count
    }
    
    //function from UITableView to load data into cells using local class [CharacterTableViewCell] as bridge
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell", for: indexPath) as! CharacterTableViewCell
        cell.characterLabel.text=loadedCharacters[indexPath.row]
        return cell
    }
    
    //function from UITableView to do sth when user press cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showCharacter", sender: nil)
    }
    
    //function from UITableView to deliver data to next ViewController [EpisodeViewController]
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showCharacter" else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let viewController = segue.destination as! CharacterViewController
        viewController.characterName = loadedCharacters[indexPath.row]
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var airdateLabel: UILabel!
    @IBOutlet weak var seriesLabel: UILabel!
    
}
class CharacterTableViewCell: UITableViewCell {
    @IBOutlet weak var characterLabel: UILabel!
}

