//
//  Music.swift
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

import AppKit
import ScriptingBridge

@objc enum MusicEKnd: UInt32 {
    case TrackListing = 1800696427 /* a basic listing of tracks within a playlist */
    case AlbumListing = 1799449698 /* a listing of a playlist grouped by album */
    case CdInsert = 1799570537 /* a printout of the playlist for jewel case inserts */
}

@objc enum MusicEnum: UInt32 {
    case Standard = 1819767668 /* Standard PostScript error handling */
    case Detailed = 1819763828 /* print a detailed report of PostScript errors */
}

@objc enum MusicEPlS: UInt32 {
    case stopped = 1800426323
    case playing = 1800426320
    case paused = 1800426352
    case fastForwarding = 1800426310
    case rewinding = 1800426322
}

@objc enum MusicERpt: UInt32 {
    case Off = 1800564815
    case One = 1800564785
    case All = 1799449708
}

@objc enum MusicEShM: UInt32 {
    case Songs = 1800628307
    case Albums = 1800628289
    case Groupings = 1800628295
}

@objc enum MusicESrc: UInt32 {
    case Library = 1800169826
    case AudioCD = 1799439172
    case MP3CD = 1800225604
    case RadioTuner = 1800697198
    case SharedLibrary = 1800628324
    case ITunesStore = 1799967827
    case Unknown = 1800760939
}

@objc enum MusicESrA: UInt32 {
    case Albums = 1800630860 /* albums only */
    case All = 1799449708 /* all text fields */
    case Artists = 1800630866 /* artists only */
    case Composers = 1800630851 /* composers only */
    case Displayed = 1800630870 /* visible text fields */
    case Names = 1800630867 /* track names only */
}

@objc enum MusicESpK: UInt32 {
    case None = 1800302446
    case Folder = 1800630342
    case Genius = 1800630343
    case Library = 1800630348
    case Music = 1800630362
    case PurchasedMusic = 1800630349
}

@objc enum MusicEMdK: UInt32 {
    case Song = 1800234067 /* music track */
    case MusicVideo = 1800823894 /* music video track */
    case Unknown = 1800760939
}

@objc enum MusicERtK: UInt32 {
    case User = 1800565845 /* user-specified rating */
    case Computed = 1800565827 /* computed rating */
}

@objc enum MusicEAPD: UInt32 {
    case Computer = 1799442499
    case AirPortExpress = 1799442520
    case AppleTV = 1799442516
    case AirPlayDevice = 1799442511
    case BluetoothDevice = 1799442498
    case HomePod = 1799442504
    case Unknown = 1799442517
}

@objc enum MusicEClS: UInt32 {
    case Unknown = 1800760939
    case Purchased = 1800435058
    case Matched = 1800233332
    case Uploaded = 1800761452
    case Ineligible = 1800562026
    case Removed = 1800562029
    case Error = 1799713394
    case Duplicate = 1799648624
    case Subscription = 1800631650
    case NoLongerAvailable = 1800562038
    case NotUploaded = 1800761424
}

@objc protocol MusicGenericMethods : NSObjectProtocol {

    @objc optional func printPrintDialog(_ printDialog: Bool, withProperties: [AnyHashable : Any], kind: MusicEKnd, theme: String) // Print the specified object(s)

    @objc optional func close() // Close an object

    @objc optional func delete() // Delete an element from an object

    @available(OSX 10.5, *)
    @objc optional func duplicate(to: SBObject) -> SBObject // Duplicate one or more object(s)

    @objc optional func exists() -> Bool // Verify if an object exists

    @objc optional func open() // the specified object(s)

    @objc optional func save() // Save the specified object(s)

    @objc optional func playOnce(_ once: Bool) // play the current track or the specified track or file.

    @objc optional func select() // select the specified object(s)
}

/*
 * Music Suite
 */

// The application program
@objc protocol MusicApplication: NSObjectProtocol {

    @objc optional func airPlayDevices() -> [MusicAirPlayDevice]

    @objc optional func browserWindows() -> [MusicBrowserWindow]

    @objc optional func encoders() -> [MusicEncoder]

    @objc optional func eqPresets() -> [MusicEQPreset]

    @objc optional func eqWindows() -> [MusicEQWindow]

    @objc optional func miniplayerWindows() -> [MusicMiniplayerWindow]

    @objc optional func playlists() -> [MusicPlaylist]

    @objc optional func playlistWindows() -> [MusicPlaylistWindow]

    @objc optional func sources() -> [MusicSource]

    @objc optional func tracks() -> [MusicTrack]

    @objc optional func videoWindows() -> [MusicVideoWindow]

    @objc optional func visuals() -> [MusicVisual]

    @objc optional func windows() -> [MusicWindow]

    
    @objc optional var airPlayEnabled: Bool { get } // is AirPlay currently enabled?

    @objc optional var converting: Bool { get } // is a track currently being converted?

    @objc optional var currentAirPlayDevices: [MusicAirPlayDevice] { get } // the currently selected AirPlay device(s)

    @objc optional var currentEncoder: MusicEncoder { get } // the currently selected encoder (MP3, AIFF, WAV, etc.)

    @objc optional var currentEQPreset: MusicEQPreset { get } // the currently selected equalizer preset

    @objc optional var currentPlaylist: MusicPlaylist { get } // the playlist containing the currently targeted track

    @objc optional var currentStreamTitle: String { get } // the name of the current track in the playing stream (provided by streaming server)

    @objc optional var currentStreamURL: String { get } // the URL of the playing stream or streaming web site (provided by streaming server)

    @objc optional var currentTrack: MusicTrack { get } // the current targeted track

    @objc optional var currentVisual: MusicVisual { get } // the currently selected visual plug-in

    @objc optional var eqEnabled: Bool { get } // is the equalizer enabled?

    @objc optional var fixedIndexing: Bool { get } // true if all AppleScript track indices should be independent of the play order of the owning playlist.

    @objc optional var frontmost: Bool { get } // is this the active application?

    @objc optional var fullScreen: Bool { get } // is the application using the entire screen?

    @objc optional var name: String { get } // the name of the application

    @objc optional var mute: Bool { get } // has the sound output been muted?

    @objc optional var playerPosition: Double { get } // the player’s position within the currently playing track in seconds.

    @objc optional var playerState: MusicEPlS { get } // is the player stopped, paused, or playing?

    @objc optional var selection: SBObject { get } // the selection visible to the user

    @objc optional var shuffleEnabled: Bool { get } // are songs played in random order?

    @objc optional var shuffleMode: MusicEShM  { get }// the playback shuffle mode

    @objc optional var songRepeat: MusicERpt { get } // the playback repeat mode

    @objc optional var soundVolume: Int  { get }// the sound output volume (0 = minimum, 100 = maximum)

    @objc optional var version: String { get } // the version of the application

    @objc optional var visualsEnabled: Bool { get } // are visuals currently being displayed?

    
    @objc optional func printPrintDialog(_ printDialog: Bool, withProperties: [AnyHashable : Any], kind: MusicEKnd, theme: String) // Print the specified object(s)

    @objc optional func run() // Run the application

    @objc optional func quit() // Quit the application

    @objc optional func add(_ x: [URL], to: SBObject) -> MusicTrack // add one or more files to a playlist

    @objc optional func backTrack() // reposition to beginning of current track or go to previous track if already at start of current track

    @objc optional func convert(_ x: [SBObject]) -> MusicTrack // convert one or more files or tracks

    @objc optional func fastForward() // skip forward in a playing track

    @objc optional func nextTrack() // advance to the next track in the current playlist

    @objc optional func pause() // pause playback

    @objc optional func playOnce(_ once: Bool) // play the current track or the specified track or file.

    @objc optional func playpause() // toggle the playing/paused state of the current track

    @objc optional func previousTrack() // return to the previous track in the current playlist

    @objc optional func resume() // disable fast forward/rewind and resume playback, if playing.

    @objc optional func rewind() // skip backwards in a playing track

    @objc optional func stop() // stop playback

    @objc optional func openLocation(_ x: String) // Opens an iTunes Store or audio stream URL
}

// an item
@objc protocol MusicItem : MusicGenericMethods {

    @objc optional var container: SBObject { get } // the container of the item

    @objc optional func id() -> Int // the id of the item

    @objc optional var index: Int { get } // the index of the item in internal application order

    @objc optional var name: String { get } // the name of the item

    @objc optional var persistentID: String { get } // the id of the item as a hexadecimal string. This id does not change over time.

    @objc optional var properties: [AnyHashable : Any]  { get } // every property of the item

    
    @objc optional func download() // download a cloud track or playlist

    @objc optional func reveal() // reveal and select a track or playlist
}

class MusicApplicationObject: NSObject, MusicApplication {
    private let instance = SBApplication(bundleIdentifier: "com.apple.Music")!

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return instance
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return instance.responds(to: aSelector) || super.responds(to: aSelector)
    }
    
    override func isKind(of aClass: AnyClass) -> Bool {
        return super.isKind(of: aClass) || instance.isKind(of: aClass)
    }
}

// an AirPlay device
@objc protocol MusicAirPlayDevice : MusicItem {

    @objc optional var active: Bool { get } // is the device currently being played to?

    @objc optional var available: Bool { get } // is the device currently available?

    @objc optional var kind: MusicEAPD { get } // the kind of the device

    @objc optional var networkAddress: String { get } // the network (MAC) address of the device

    @objc optional func protected() -> Bool // is the device password- or passcode-protected?

    @objc optional var selected: Bool  { get } // is the device currently selected?

    @objc optional var supportsAudio: Bool { get } // does the device support audio playback?

    @objc optional var supportsVideo: Bool { get } // does the device support video playback?

    @objc optional var soundVolume: Int  { get } // the output volume for the device (0 = minimum, 100 = maximum)
}

// a piece of art within a track or playlist
@objc protocol MusicArtwork : MusicItem {

    
    @objc optional var data: NSImage  { get } // data for this artwork, in the form of a picture

    @objc optional var objectDescription: String { get } // description of artwork as a string

    @objc optional var downloaded: Bool { get } // was this artwork downloaded by Music?

    @objc optional var format: NSNumber { get } // the data format for this piece of artwork

    @objc optional var kind: Int { get } // kind or purpose of this piece of artwork

    @objc optional var rawData: Any { get } // data for this artwork, in original format
}

// converts a track to a specific file format
@objc protocol MusicEncoder : MusicItem {

    
    @objc optional var format: String { get } // the data format created by the encoder
}

// equalizer preset configuration
@objc protocol MusicEQPreset : MusicItem {

    @objc optional var band1: Double { get } // the equalizer 32 Hz band level (-12.0 dB to +12.0 dB)

    @objc optional var band2: Double { get } // the equalizer 64 Hz band level (-12.0 dB to +12.0 dB)

    @objc optional var band3: Double { get } // the equalizer 125 Hz band level (-12.0 dB to +12.0 dB)

    @objc optional var band4: Double { get } // the equalizer 250 Hz band level (-12.0 dB to +12.0 dB)

    @objc optional var band5: Double { get } // the equalizer 500 Hz band level (-12.0 dB to +12.0 dB)

    @objc optional var band6: Double { get } // the equalizer 1 kHz band level (-12.0 dB to +12.0 dB)

    @objc optional var band7: Double { get } // the equalizer 2 kHz band level (-12.0 dB to +12.0 dB)

    @objc optional var band8: Double { get } // the equalizer 4 kHz band level (-12.0 dB to +12.0 dB)

    @objc optional var band9: Double { get } // the equalizer 8 kHz band level (-12.0 dB to +12.0 dB)

    @objc optional var band10: Double { get } // the equalizer 16 kHz band level (-12.0 dB to +12.0 dB)

    @objc optional var modifiable: Bool { get } // can this preset be modified?

    @objc optional var preamp: Double { get } // the equalizer preamp level (-12.0 dB to +12.0 dB)

    @objc optional var updateTracks: Bool { get } // should tracks which refer to this preset be updated when the preset is renamed or deleted?
}

// a list of tracks/streams
@objc protocol MusicPlaylist : MusicItem {

    
    @objc optional func tracks() -> [MusicTrack]

    @objc optional func artworks() -> [MusicArtwork]

    
    @objc optional var objectDescription: String { get } // the description of the playlist

    @objc optional var disliked: Bool { get } // is this playlist disliked?

    @objc optional var duration: Int { get } // the total length of all tracks (in seconds)

    @objc optional var name: String { get } // the name of the playlist

    @objc optional var loved: Bool { get } // is this playlist loved?

    @objc optional var parent: MusicPlaylist { get } // folder which contains this playlist (if any)

    @objc optional var size: Int { get } // the total size of all tracks (in bytes)

    @objc optional var specialKind: MusicESpK { get } // special playlist kind

    @objc optional var time: String { get } // the length of all tracks in MM:SS format

    @objc optional var visible: Bool { get } // is this playlist visible in the Source list?

    
    @objc optional func move(to: SBObject) // Move playlist(s) to a new location

    @objc optional func search(for for_: String, only: MusicESrA) -> MusicTrack // search a playlist for tracks matching the search string. Identical to entering search text in the Search field.
}

// a playlist representing an audio CD
@objc protocol MusicAudioCDPlaylist : MusicPlaylist {

    
    @objc optional func audioCDTracks() -> [MusicAudioCDTrack]

    
    @objc optional var artist: String { get } // the artist of the CD

    @objc optional var compilation: Bool { get } // is this CD a compilation album?

    @objc optional var composer: String { get } // the composer of the CD

    @objc optional var discCount: Int { get } // the total number of discs in this CD’s album

    @objc optional var discNumber: Int { get } // the index of this CD disc in the source album

    @objc optional var genre: String { get } // the genre of the CD

    @objc optional var year: Int { get } // the year the album was recorded/released
}

// the master library playlist
@objc protocol MusicLibraryPlaylist : MusicPlaylist {

    
    @objc optional func fileTracks() -> [MusicFileTrack]

    @objc optional func urlTracks() -> [MusicURLTrack]

    @objc optional func sharedTracks() -> [MusicSharedTrack]
}

// the radio tuner playlist
@objc protocol MusicRadioTunerPlaylist : MusicPlaylist {

    
    @objc optional func urlTracks() -> [MusicURLTrack]
}

// a media source (library, CD, device, etc.)
@objc protocol MusicSource : MusicItem {

    
    @objc optional func audioCDPlaylists() -> [MusicAudioCDPlaylist]

    @objc optional func libraryPlaylists() -> [MusicLibraryPlaylist]

    @objc optional func playlists() -> [MusicPlaylist]

    @objc optional func radioTunerPlaylists() -> [MusicRadioTunerPlaylist]

    @objc optional func subscriptionPlaylists() -> [MusicSubscriptionPlaylist]

    @objc optional func userPlaylists() -> [MusicUserPlaylist]

    
    @objc optional var capacity: Int64 { get } // the total size of the source if it has a fixed size

    @objc optional var freeSpace: Int64 { get } // the free space on the source if it has a fixed size

    @objc optional var kind: MusicESrc { get }
}

// a subscription playlist from Apple Music
@objc protocol MusicSubscriptionPlaylist : MusicPlaylist {

    
    @objc optional func fileTracks() -> [MusicFileTrack]

    @objc optional func urlTracks() -> [MusicURLTrack]
}

// playable audio source
@objc protocol MusicTrack : MusicItem {

    @objc optional func artworks() -> [MusicArtwork]

    
    @objc optional var album: String { get } // the album name of the track

    @objc optional var albumArtist: String { get } // the album artist of the track

    @objc optional var albumDisliked: Bool { get } // is the album for this track disliked?

    @objc optional var albumLoved: Bool { get } // is the album for this track loved?

    @objc optional var albumRating: Int { get } // the rating of the album for this track (0 to 100)

    @objc optional var albumRatingKind: MusicERtK { get } // the rating kind of the album rating for this track

    @objc optional var artist: String { get } // the artist/source of the track

    @objc optional var bitRate: Int { get } // the bit rate of the track (in kbps)

    @objc optional var bookmark: Double { get } // the bookmark time of the track in seconds

    @objc optional var bookmarkable: Bool { get } // is the playback position for this track remembered?

    @objc optional var bpm: Int { get } // the tempo of this track in beats per minute

    @objc optional var category: String { get } // the category of the track

    @objc optional var cloudStatus: MusicEClS { get } // the iCloud status of the track

    @objc optional var comment: String { get } // freeform notes about the track

    @objc optional var compilation: Bool { get } // is this track from a compilation album?

    @objc optional var composer: String { get } // the composer of the track

    @objc optional var databaseID: Int { get } // the common, unique ID for this track. If two tracks in different playlists have the same database ID, they are sharing the same data.

    @objc optional var dateAdded: Date { get } // the date the track was added to the playlist

    @objc optional var objectDescription: String { get } // the description of the track

    @objc optional var discCount: Int { get } // the total number of discs in the source album

    @objc optional var discNumber: Int { get } // the index of the disc containing this track on the source album

    @objc optional var disliked: Bool { get } // is this track disliked?

    @objc optional var downloaderAppleID: String { get } // the Apple ID of the person who downloaded this track

    @objc optional var downloaderName: String { get } // the name of the person who downloaded this track

    @objc optional var duration: Double { get } // the length of the track in seconds

    @objc optional var enabled: Bool { get } // is this track checked for playback?

    @objc optional var episodeID: String { get } // the episode ID of the track

    @objc optional var episodeNumber: Int { get } // the episode number of the track

    @objc optional var eq: String { get } // the name of the EQ preset of the track

    @objc optional var finish: Double { get } // the stop time of the track in seconds

    @objc optional var gapless: Bool { get } // is this track from a gapless album?

    @objc optional var genre: String { get } // the music/audio genre (category) of the track

    @objc optional var grouping: String { get } // the grouping (piece) of the track. Generally used to denote movements within a classical work.

    @objc optional var kind: String { get } // a text description of the track

    @objc optional var longDescription: String { get } // the long description of the track

    @objc optional var loved: Bool { get } // is this track loved?

    @objc optional var lyrics: String { get } // the lyrics of the track

    @objc optional var mediaKind: MusicEMdK { get } // the media kind of the track

    @objc optional var modificationDate: Date { get } // the modification date of the content of this track

    @objc optional var movement: String { get } // the movement name of the track

    @objc optional var movementCount: Int { get } // the total number of movements in the work

    @objc optional var movementNumber: Int { get } // the index of the movement in the work

    @objc optional var playedCount: Int { get } // number of times this track has been played

    @objc optional var playedDate: Date { get } // the date and time this track was last played

    @objc optional var purchaserAppleID: String { get } // the Apple ID of the person who purchased this track

    @objc optional var purchaserName: String { get } // the name of the person who purchased this track

    @objc optional var rating: Int { get } // the rating of this track (0 to 100)

    @objc optional var ratingKind: MusicERtK { get } // the rating kind of this track

    @objc optional var releaseDate: Date { get } // the release date of this track

    @objc optional var sampleRate: Int { get } // the sample rate of the track (in Hz)

    @objc optional var seasonNumber: Int { get } // the season number of the track

    @objc optional var shufflable: Bool { get } // is this track included when shuffling?

    @objc optional var skippedCount: Int { get } // number of times this track has been skipped

    @objc optional var skippedDate: Date { get } // the date and time this track was last skipped

    @objc optional var show: String { get } // the show name of the track

    @objc optional var sortAlbum: String { get } // override string to use for the track when sorting by album

    @objc optional var sortArtist: String { get } // override string to use for the track when sorting by artist

    @objc optional var sortAlbumArtist: String { get } // override string to use for the track when sorting by album artist

    @objc optional var sortName: String { get } // override string to use for the track when sorting by name

    @objc optional var sortComposer: String { get } // override string to use for the track when sorting by composer

    @objc optional var sortShow: String { get } // override string to use for the track when sorting by show name

    @objc optional var size: Int64 { get } // the size of the track (in bytes)

    @objc optional var start: Double { get } // the start time of the track in seconds

    @objc optional var time: String { get } // the length of the track in MM:SS format

    @objc optional var trackCount: Int { get } // the total number of tracks on the source album

    @objc optional var trackNumber: Int { get } // the index of the track on the source album

    @objc optional var unplayed: Bool { get } // is this track unplayed?

    @objc optional var volumeAdjustment: Int { get } // relative volume adjustment of the track (-100% to 100%)

    @objc optional var work: String { get } // the work name of the track

    @objc optional var year: Int { get } // the year the track was recorded/released
}

// a track on an audio CD
@objc protocol MusicAudioCDTrack : MusicTrack {

    
    @objc optional var location: URL { get } // the location of the file represented by this track
}

// a track representing an audio file (MP3, AIFF, etc.)
@objc protocol MusicFileTrack : MusicTrack {

    
    @objc optional var location: URL { get } // the location of the file represented by this track

    
    @objc optional func refresh() // update file track information from the current information in the track’s file
}

// a track residing in a shared library
@objc protocol MusicSharedTrack : MusicTrack { }

// a track representing a network stream
@objc protocol MusicURLTrack : MusicTrack {

    
    @objc optional var address: String { get } // the URL for this track
}

// custom playlists created by the user
@objc protocol MusicUserPlaylist : MusicPlaylist {
    
    @objc optional func fileTracks() -> [MusicFileTrack]

    @objc optional func urlTracks() -> [MusicURLTrack]

    @objc optional func sharedTracks() -> [MusicSharedTrack]

    
    @objc optional var shared: Bool { get } // is this playlist shared?

    @objc optional var smart: Bool { get } // is this a Smart Playlist?

    @objc optional var genius: Bool { get } // is this a Genius Playlist?
}

// a folder that contains other playlists
@objc protocol MusicFolderPlaylist : MusicUserPlaylist { }

// a visual plug-in
@objc protocol MusicVisual : MusicItem { }

// any window
@objc protocol MusicWindow : MusicItem {

    
    @objc optional var bounds: NSRect { get } // the boundary rectangle for the window

    @objc optional var closeable: Bool { get } // does the window have a close button?

    @objc optional var collapseable: Bool { get } // does the window have a collapse button?

    @objc optional var collapsed: Bool { get } // is the window collapsed?

    @objc optional var fullScreen: Bool { get } // is the window full screen?

    @objc optional var position: NSPoint { get } // the upper left position of the window

    @objc optional var resizable: Bool { get } // is the window resizable?

    @objc optional var visible: Bool { get } // is the window visible?

    @objc optional var zoomable: Bool { get } // is the window zoomable?

    @objc optional var zoomed: Bool { get } // is the window zoomed?
}

// the main window
@objc protocol MusicBrowserWindow : MusicWindow {

    
    @objc optional var selection: SBObject { get } // the selected tracks

    @objc optional var view: MusicPlaylist { get } // the playlist currently displayed in the window
}

// the equalizer window
@objc protocol MusicEQWindow : MusicWindow { }

// the miniplayer window
@objc protocol MusicMiniplayerWindow : MusicWindow { }

// a sub-window showing a single playlist
@objc protocol MusicPlaylistWindow : MusicWindow {

    
    @objc optional var selection: SBObject { get } // the selected tracks

    @objc optional var view: MusicPlaylist { get } // the playlist displayed in the window
}

// the video window
@objc protocol MusicVideoWindow : MusicWindow { }


extension SBObject: MusicArtwork, MusicURLTrack, MusicItem, MusicSubscriptionPlaylist, MusicPlaylistWindow, MusicMiniplayerWindow, MusicEQWindow, MusicWindow {}
