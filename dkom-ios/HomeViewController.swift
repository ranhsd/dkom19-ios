//
//  HomeViewController.swift
//  dkom-ios
//
//  Created by Ran Hassid on 08/01/2019.
//  Copyright © 2019 Trench Girls LTD. All rights reserved.
//

import UIKit
import Parse
import Kingfisher
import DeepDiff
import ParseLiveQuery
import TBEmptyDataSet
import SVProgressHUD
import KDEAudioPlayer

class HomeViewController: UIViewController {
    
    private var candidates : [TFCandidate] = []
    private var candidatesLoaded: Bool = false
    
    private lazy var audioPlayer : AudioPlayer = {
        let audioPlayer = AudioPlayer()
        audioPlayer.delegate = self
        return audioPlayer
    }()
    
    
    
    private var messagePresenter: SimpleMessagePresenter? = nil
    
    private lazy var client = Client()
    
    private lazy var query : PFQuery<PFObject> = {
        let query = TFCandidate.query()
        query?.whereKeyExists("createdBy")
        return query!
    }()
    private lazy var subscription: Subscription<PFObject> = client.subscribe(query)
    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: .zero)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.estimatedRowHeight = 76
            tableView.rowHeight = UITableView.automaticDimension
            tableView.register(nibWithCellClass: CandidateCell.self)
            tableView.emptyDataSetDataSource = self
            tableView.emptyDataSetDelegate = self
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Candidates"
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createCandidate))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(onLogout))
        
        self.subscribeForNewCandidates()
        
        self.loadCandidates()
    }
    
    //    MARK: Data loading
    private func loadCandidates() {
        
        let query = TFCandidate.query()
        query?.order(byDescending: "createdAt")
        
        SVProgressHUD.show(withStatus: "Loading Candidates...")
        
        query?.findObjectsInBackground(block: {[weak self] (results, error) in
            
            SVProgressHUD.dismiss()
            
            guard let `self` = self else { return }
            
            guard error == nil else {
                self.messagePresenter = SimpleMessagePresenter(title: "Oops", message: error?.localizedDescription)
                self.messagePresenter?.present(on: self, closeHandler: nil)
                return
            }
            
            self.candidatesLoaded = true
            guard let cands = results as? [TFCandidate] else { return }
            let oldCandidates = self.candidates
            self.candidates.append(contentsOf: cands)
            let changes = diff(old: oldCandidates, new: self.candidates)
            self.tableView.reload(changes: changes, section: 0)
            
        })
    }
    
    //    MARK: Realtime stuff
    
    private func subscribeForNewCandidates() {
        subscription.handle(Event.created) {[weak self] query, object in
            guard let `self` = self else { return }
            guard let candidate = object as? TFCandidate else { return }
            
            if candidate.createdBy?.objectId != TFUser.current()?.objectId {
                self.playCandidateSound(candidate: candidate)
            }
            
            DispatchQueue.main.async {
                let oldCandidates = self.candidates
                self.candidates.insert(candidate, at: 0)
                let changes = diff(old: oldCandidates, new: self.candidates)
                self.tableView.reload(changes: changes, section: 0)
            }
        }
    }
    
    //    MARK: Actions and selectors
    @objc func createCandidate(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withClass: CreateCandidateViewController.self)!
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func onLogout() {
        SVProgressHUD.show()
        
        TFUser.logOutInBackground { error in
            guard error == nil else {
                return
            }
            
            NotificationCenter.default.post(name: .loggedOut, object: nil)
        }
    }

}

extension HomeViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.candidates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: CandidateCell.self, for: indexPath)
        
        let candidate = self.candidates[indexPath.row]
        cell.configure(with: candidate)

        return cell
    }
}

extension HomeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let candidate = self.candidates[indexPath.row]
        self.playCandidateSound(candidate: candidate)
    }
    
    internal func playCandidateSound(candidate: TFCandidate) {
        if let audioURL = candidate.audioBio?.url {
            guard let audioItem = AudioItem(mediumQualitySoundURL: URL(string: audioURL)) else {
                return
            }
            self.audioPlayer.play(item: audioItem)
        }
    }
}

extension HomeViewController : TBEmptyDataSetDelegate, TBEmptyDataSetDataSource {
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Candidates", attributes: [
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .headline)
        ])
    }
    
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        return self.candidates.isEmpty && self.candidatesLoaded
    }
}

extension HomeViewController : AudioPlayerDelegate {
    
}
