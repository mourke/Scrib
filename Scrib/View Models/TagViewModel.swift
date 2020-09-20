//
//  TagViewModel.swift
//  Scrib
//
//  Copyright © 2020 Mark Bourke.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE
//

import Cocoa
import LastFMKit

class TagViewModel: TagViewModelProtocol {
    
    @Published var image: NSImage
    
    private let track: MusicTrack
    
    init(track: MusicTrack) {
        self.track = track
        self.image = track.artworks?().first?.data ?? NSImage(named: "Placeholder_Track")!
    }
    
    func tagItem(of type: TaggingType, with tags: [Tag]) {
        let artist = track.artist!
        
        switch type {
        case .album:
            AlbumProvider.add(tags: tags, to: track.album!, by: track.albumArtist ?? artist, callback: nil)
        case .artist:
            ArtistProvider.add(tags: tags, to: artist, callback: nil)
        case .track:
            TrackProvider.add(tags: tags, to: track.name!, by: artist, callback: nil)
        default:
            fatalError()
        }
    }
}
