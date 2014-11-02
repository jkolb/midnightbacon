//
//  ApplicationController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class ApplicationController {
    let reddit = Reddit()
    
    func fetchLinks(path: String) -> Promise<Reddit.Links> {
        return reddit.fetchReddit(path)
    }
}
