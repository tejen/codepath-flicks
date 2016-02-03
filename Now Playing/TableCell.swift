//
//  TableCell.swift
//  Now Playing
//
//  Created by Tejen Hasmukh Patel on 1/23/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class TableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisView: UITextView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var smallImageRequest = NSURLRequest();
    var largeImageRequest = NSURLRequest();
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        
        self.posterImageView.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.posterImageView.alpha = 0.0
                self.posterImageView.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.posterImageView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterImageView.setImageWithURLRequest(
                            self.largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterImageView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        });
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
