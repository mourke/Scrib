//
//  TagView.swift
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

import SwiftUI
import LastFMKit.LFMTaggingType

struct TagView: View {
    
    @State var type: TaggingType = .track
    @State var tags = ""
    
    private let add: (TaggingType, [Tag]) -> Void
    private let cancel: () -> Void
    private let image: NSImage?
    
    init(image: NSImage? = nil,
         add: @escaping (TaggingType, [Tag]) -> Void,
         cancel: @escaping () -> Void) {
        self.add = add
        self.cancel = cancel
        self.image = image
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 10) {
                Image(nsImage: image ?? NSImage(named: "Placeholder_Track")!)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .scaledToFit()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add tags to item.")
                        .fontWeight(.bold)
                    Text("Enter tags separated by a comma.")
                        .font(.caption)
                }
            }
            HStack {
                Spacer(minLength: 35)
                Text("Tags:")
                TextField("Enter tags separated by a \",\"", text: $tags)
            }
            
            Picker(selection: $type, label: Text("Type:")) {
                Text("Track").tag(TaggingType.track)
                Text("Artist").tag(TaggingType.artist)
                Text("Album").tag(TaggingType.album)
            }
            .pickerStyle(RadioGroupPickerStyle())
            .padding(.leading, 35)
            
            HStack {
                Spacer()
                
                Button(action: cancel) {
                    Text("Cancel")
                }
                Button(action: {
                    self.add(self.type, self.tags.components(separatedBy: ", ").map({Tag(name: $0)}))
                }) {
                    Text("Add")
                }
            }
        }
        .padding()
    }
}

#if DEBUG
struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(add: { (_, _) in
            
        }, cancel: {
            
        })
    }
}
#endif
