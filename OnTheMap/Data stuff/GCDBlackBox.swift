//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 5/29/18.
//  Copyright © 2018 Zaben. All rights reserved.
//
// Took this function from the MyFavoriteMovies App

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

