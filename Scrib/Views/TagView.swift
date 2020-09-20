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

protocol TagViewModelProtocol: ObservableObject {
    var image: NSImage { get set }
    func tagItem(of type: TaggingType, with tags: [Tag])
}

struct TagView<ViewModel: TagViewModelProtocol>: View {
    
    @State private var type: TaggingType = .track
    @State private var tags = ""
    
    // Remove these once the entire app is in swiftUI
    struct ButtonHandlers {
        var addButtonPressed: (() -> Void)?
        var cancelButtonPressed: (() -> Void)?
    }
    var buttonHandlers = ButtonHandlers()
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 10) {
                Image(nsImage: viewModel.image)
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
                
                Button("Cancel") {
                    self.buttonHandlers.cancelButtonPressed?()
                }
                Button("Add") {
                    let tags = self.tags.components(separatedBy: ", ").map({Tag(name: $0)})
                    self.viewModel.tagItem(of: self.type, with: tags)
                    self.buttonHandlers.addButtonPressed?()
                }
            }
        }
        .padding()
    }
}
