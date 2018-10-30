//
//  EpisodesTableViewController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesTableViewController: UITableViewController {
    
    // constants
    fileprivate let episodeCellId = "episodeCell"
    fileprivate let episodeCellRowHeight: CGFloat = 132
    
    var episodes: [Episode] = []
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchPodcastEpisodes()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEpisodesTableView()
        setupEpisodesNavigationBarButtons()
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: episodeCellId, for: indexPath) as! EpisodeCell
        cell.episode = episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return episodeCellRowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: episodes)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 400 : 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.saveEpisode(episode: episode)
            APIService.shared.downloadEpisode(episode: episode)
        }
        
        return [downloadAction]
    }
    
} // EpisodesTableViewController

// MARK: - Setup Functions

private extension EpisodesTableViewController {
    
    func setupEpisodesTableView() {
        let episodeCellNib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(episodeCellNib, forCellReuseIdentifier: episodeCellId)
        tableView.tableFooterView = UIView()
    }
    
    func setupEpisodesNavigationBarButtons() {
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        
        let podcastHasBeenFavourited = savedPodcasts.index {
            $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName
        }
        
        if podcastHasBeenFavourited != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favourite", style: .plain, target: self, action: #selector(handleSaveFavourites))
        }
    }
}

// MARK: - Selector/Helper Functions

private extension EpisodesTableViewController {
    
    @objc func handleSaveFavourites() {
        print("Favourite pressed")
        guard let podcast = self.podcast else { return }
        
        var savedPodcasts = UserDefaults.standard.savedPodcasts()
        savedPodcasts.append(podcast)
        
        let savedPodcastsArchiveData = NSKeyedArchiver.archivedData(withRootObject: savedPodcasts)
        UserDefaults.standard.set(savedPodcastsArchiveData, forKey: UserDefaults.favouritePodcastsKey)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "new"
    }
    
    func fetchPodcastEpisodes() {
        print("attempting to fetch episodes from RSS feed url: \(podcast?.feedUrl ?? "")")
        
        guard let unwrappedFeedUrl = podcast?.feedUrl else { return }
        APIService.shared.fetchEpisodesFrom(feedUrl: unwrappedFeedUrl) { (episodes) in
            self.episodes = episodes
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}