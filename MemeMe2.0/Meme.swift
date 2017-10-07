//
//  Meme.swift
//  MemeMe2.0
//
//  Created by Vaibhav Sahu on 10/5/17.
//  Copyright © 2017 Vaibhav Sahu. All rights reserved.
//

import Foundation
import UIKit

struct Meme{
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
    
    init(topText: String!, bottomText: String!, originalImage: UIImage, memedImage:UIImage)
    {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
