//
//  CharacterViewController.swift
//  s18635
//
//  Created by DD on 06/01/2021.
//

import UIKit
import Alamofire

class CharacterViewController: UIViewController {
    
    //loaded from func prepare in EpisodeViewController
    var characterName: String? = nil
    
    var loadedCharacter:CharacterModel? = nil
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var portrayedLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reload()
    }

    //function to load data from external api, then decoding it to local model [CharacterModel]
    func reload(){
        guard let characterName = characterName else{return}
        AF.request("https://www.breakingbadapi.com/api/characters?name=\(characterName.replacingOccurrences(of: " ", with: "+"))").responseJSON{ response in
            if let error = response.error{
                self.presentError(title: "Request Failed", message: error.localizedDescription)
                return
            }
            if let data=response.data{
                do{
                    let character = try JSONDecoder().decode([CharacterModel].self,from: data)
                    if character.count<1 {self.presentError(title: "Sth went wrong", message: "Api is broken and it cannot find this person");return}
                    
                    //api returns list of Objects [CharacterModel] that contains 1 element
                    self.loadedCharacter = character[0]
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
    
    //function to load data from local model into existing labels in UI and then tries to load the image from URL
    func reloadData() {
        guard let currentCharacter=loadedCharacter else {return}
        nameLabel.text=currentCharacter.name
        nickNameLabel.text=currentCharacter.nickname
        birthdayLabel.text=currentCharacter.birthday
        statusLabel.text=currentCharacter.status
        portrayedLabel.text=currentCharacter.portrayed
        occupationLabel.text=currentCharacter.occupation.joined(separator: "\n")
        
        guard let imageURL = URL(string: currentCharacter.img) else { return }
        AF.request(imageURL).response{ response in
            if let error = response.error{
                self.presentError(title: "Cannot load image", message: error.localizedDescription)
                return
            }
            if let data=response.data{
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                     self.imgView.image = image
                 self.imgView.contentMode = .scaleAspectFit
                }
            }
        }
    }
}

