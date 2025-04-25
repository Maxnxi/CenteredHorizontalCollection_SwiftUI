//
//  ScrollBehaviorMode.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//


import Foundation

/// Scroll behavior modes for the collection
public enum ScrollBehaviorMode {
    /// Simple selection and centering
    case standard
    
    /// UICollectionView-like targetContentOffset behavior for more natural scrolling
    case targetContentOffset
}