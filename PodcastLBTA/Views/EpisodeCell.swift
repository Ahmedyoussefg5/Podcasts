/***
 Copyright (c) 2018 Jason Ngo
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 ***/

//
//  EpisodeCell.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-13.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {
  
  // MARK: - Views
  
  @IBOutlet var thumbnailImageView: UIImageView!
  @IBOutlet var publicationDateLabel: UILabel!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var downloadProgressLabel: UILabel!
  
  // MARK: - Static
  
  static let reuseIdentifier = "episodeCell"
  static let cellHeight: CGFloat = 132
  static func initFromNib() -> UINib {
    return UINib(nibName: "EpisodeCell", bundle: nil)
  }
  
  let df: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy"
    return dateFormatter
  }()
  
  var episode: Episode! {
    didSet {
      titleLabel.text = episode.title
      descriptionLabel.text = episode.description
      publicationDateLabel.text = df.string(from: episode.pubDate)
      
      guard
        let unwrappedImageUrl = episode.imageUrl,
        let url = URL(string: unwrappedImageUrl.toSecureHTTPS()) else {
          return
      }
      
      thumbnailImageView.sd_setImage(with: url, completed: nil)
    }
  }
  
} // EpisodeCell
