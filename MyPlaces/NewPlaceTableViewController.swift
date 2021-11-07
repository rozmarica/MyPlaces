//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Луиза on 05.11.2021.
//

import UIKit
import Cosmos

class NewPlaceTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var locationLabel: UITextField!
    @IBOutlet weak var typeLabel: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var cosmosView: CosmosView!
    
    var imageIsChanged = false
    var currentPlace: Place!
    var currentRating = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        nameLabel.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        setupEditScreen()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }
    
    @IBAction func caneclAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo-1")
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera",
                                       style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let photo = UIAlertAction(title: "Photo",
                                      style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let cancel = UIAlertAction(title: "Cancel",
                                       style: .cancel,
                                       handler: nil)
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true, completion: nil)
        } else {
            view.endEditing(true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func savePlace() {
        let image = imageIsChanged ? placeImageView.image : #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image?.pngData()
        
        //        let newPlace = Place(name: nameLabel.text!,
        //                             location: locationLabel.text,
        //                             type: typeLabel.text,
        //                             imageData: imageData,
        //                             rating: Double(ratingControl.rating))
        
        let newPlace = Place(name: nameLabel.text!,
                             location: locationLabel.text,
                             type: typeLabel.text,
                             imageData: imageData,
                             rating: currentRating)
        
        if let currentPlace = currentPlace {
            try! realm.write({
                currentPlace.name = newPlace.name
                currentPlace.location = newPlace.location
                currentPlace.type = newPlace.type
                currentPlace.imageData = newPlace.imageData
                currentPlace.rating = newPlace.rating
            })
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        guard let currentPlace = currentPlace,
              let data = currentPlace.imageData,
              let image = UIImage(data: data) else { return }
        
        setupNavBar()
        imageIsChanged = true
        nameLabel.text = currentPlace.name
        locationLabel.text = currentPlace.location
        typeLabel.text = currentPlace.type
        placeImageView.image = image
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        //        ratingControl.rating = Int(currentPlace.rating)
        cosmosView.rating = currentPlace.rating
    }
    
    private func setupNavBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier,
              let mapVC = segue.destination as? MapViewController else { return }
        
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showPlace" {
            mapVC.place.name = nameLabel.text!
            mapVC.place.location = locationLabel.text
            mapVC.place.type = typeLabel.text
            mapVC.place.imageData = placeImageView.image?.pngData()
        }
    }
}

// MARK: - UITextFieldDelegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged(_ textField: UITextField) {
        if let text = textField.text {
            saveButton.isEnabled = !text.isEmpty
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: - Work with image

extension NewPlaceTableViewController: UIImagePickerControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImageView.image = info[.editedImage] as? UIImage
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        imageIsChanged = true
        dismiss(animated: true)
    }
}

// MARK: - MapViewControllerDelegate

extension NewPlaceTableViewController: MapViewControllerDelegate {
    
    func getAddress(_ address: String?) {
        locationLabel.text = address
    }
    
    
}
