//
//  CreateCandidateViewController.swift
//  dkom-ios
//
//  Created by Ran Hassid on 08/01/2019.
//  Copyright © 2019 Trench Girls LTD. All rights reserved.
//

import UIKit
import Eureka
import CropViewController
import ImageRow
import IQAudioRecorderController
import Parse
import SwifterSwift
import SVProgressHUD
import KDEAudioPlayer

class CreateCandidateViewController: FormViewController {
    
    private var audioBioFilePath: String? = nil
    private lazy var audioPlayer = AudioPlayer()
    
    private lazy var candidate: TFCandidate = {
       let candidate = TFCandidate()
        candidate.createdBy = TFUser.current()
        return candidate
    }()
    
    enum FormFieldsTags : String {
        case profilePicture = "profile_pic"
        case audioBio = "audio_bio"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Candidate"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel))
        
        TextRow.defaultCellSetup = {cell, _ in
            cell.height = { 60 }
        }
        
        form
            +++ Section()
            <<< ImageRow(FormFieldsTags.profilePicture.rawValue){row in
                row.title = "Profile Picture"
                row.sourceTypes =  [.PhotoLibrary, .Camera]
                row.clearAction = .no
                row.allowEditor = true
                row.useEditedImage = true
                row.placeholderImage = UIImage(named: "avatar")
                
                }.cellSetup({ cell, row in
                    cell.height = { 90 }
                }).onChange{[unowned self]row in
                    guard let image = row.value else {
                        return
                    }
                    
                    let imageData = image.resizeWithWidth(width: 1080)!
                    let compressedImageData = imageData.compressedData(quality: 0.6)!
                    
                    self.candidate.profilePicture = PFFileObject(data: compressedImageData, contentType: "image/jpeg")

                }
            <<< TextRow(){row in
                row.title = "Name"
                row.placeholder = "Full Name"
                }
                .cellSetup{cell, _ in
                    cell.textField.autocapitalizationType = .words
                }
                .onChange{[unowned self]row in
                    self.candidate.name = row.value
                }
            +++ Section()
            <<< TextAreaRow(){row in
                row.title = "Bio"
                row.placeholder = "Enter your Bio"
                row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 60)
                }.onChange{[unowned self]row in
                    self.candidate.bio = row.value
            }
            <<< LabelRow(FormFieldsTags.audioBio.rawValue) {row in
                row.title = "Audio Bio"
                }.onCellSelection{[unowned self]_,_ in
                    self.presentAudioRecorder()
                }.cellSetup{cell, _ in
                    cell.detailTextLabel?.numberOfLines = 0
                }
            
            +++ Section()
            <<< ButtonRow(){row in
                row.title = "Submit"
            }.onCellSelection{[unowned self]_,_ in
                self.saveCandidate()
            }
        
    }
    
    @objc func onCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func presentAudioRecorder() {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else { return }
            let audioController = IQAudioRecorderViewController()
            audioController.delegate = self
            audioController.audioQuality = .medium
            audioController.maximumRecordDuration = 10
            audioController.allowCropping = false
            self.presentBlurredAudioRecorderViewControllerAnimated(audioController)
        }

    }

    private func isFormValid() -> Bool {
        return self.candidate.profilePicture != nil && self.candidate.name != nil
    }
    private func saveCandidate() {
        
        if (!isFormValid()) {
            let presenter = SimpleMessagePresenter(title: "Oops!", message: "Candidate name and/or profile picture are missing")
            presenter.present(on: self, closeHandler: nil)
            return
        }
        
        SVProgressHUD.show()
        
        self.candidate.saveInBackground {[weak self] (success, error) in
            
            SVProgressHUD.dismiss()
            
            guard let `self` = self else { return }
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func presentCropViewController(image: UIImage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[unowned self] in
            let cropViewController = CropViewController(croppingStyle: .circular, image: image)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
        }
    }
    
}

extension CreateCandidateViewController : CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        cropViewController.dismiss(animated: true) {[weak self] in
            guard let `self` = self else { return }
            
            let imageData = image.resizeWithWidth(width: 1080)!
            let compressedImageData = imageData.compressedData(quality: 0.6)!
            
            self.candidate.profilePicture = PFFileObject(data: compressedImageData, contentType: "image/jpeg")
            
            guard let profilePictureRow = self.form.rowBy(tag: FormFieldsTags.profilePicture.rawValue) as? ImageRow else {
                return
            }
            
            profilePictureRow.value = image
        }
    }
}

extension CreateCandidateViewController : IQAudioRecorderViewControllerDelegate {
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        
        controller.dismiss(animated: true, completion: nil)
        
        self.audioBioFilePath = filePath
        
        let url = URL(fileURLWithPath: filePath)
        
        do {
            let data = try Data(contentsOf: url)
            self.candidate.audioBio = PFFileObject(data: data, contentType: "audio/mpeg")
            
            if let row = form.rowBy(tag: FormFieldsTags.audioBio.rawValue) as? LabelRow {
                row.value = "Tap to modify"
                row.updateCell()
            }
            
        } catch {
            print("error " + error.localizedDescription)
        }
        
    }
    
    
}
