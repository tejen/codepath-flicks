//
//  CollectionCell.swift
//  Now Playing
//
//  Created by Tejen Hasmukh Patel on 1/24/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionPosterBlurBackground: UIImageView!
    @IBOutlet weak var collectionPosterImageViewForeground: UIImageView!
    @IBOutlet weak var collectionYearLabel: UILabel!
    @IBOutlet weak var collectionRatingLabel: UILabel!
    
    var imageRequestsTriggered = false;
    var smallImageRequest = NSURLRequest();
    var largeImageRequest = NSURLRequest();
    
    override func layoutSubviews() {
        
        print(collectionPosterBlurBackground.alpha);
        
        if(imageRequestsTriggered == true) {
            return;
        }
        
        imageRequestsTriggered = true;
        
        self.collectionPosterImageViewForeground.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.collectionPosterImageViewForeground.alpha = 0.0
                self.collectionPosterImageViewForeground.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.collectionPosterImageViewForeground.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.collectionPosterImageViewForeground.setImageWithURLRequest(
                            self.largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.collectionPosterImageViewForeground.image = largeImage;
                                
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
}
