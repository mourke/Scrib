//
//  OnboardingView.swift
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

struct OnboardingView: View {
    
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            Image("Onboarding Background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            
            VStack {
                Image("Logo")
                    .padding(.bottom, 30)
                TextField("Username", text: $username)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.callout) // set the inner Text Field Font
                    .padding(10)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(5)
                    .padding([.horizontal, .top])
                SecureField("Password", text: $password)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.callout) // set the inner Text Field Font
                    .padding(10)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(5)
                    .padding()
                Button(action: {
                    // TODO: Login
                }, label: {
                    Text("Login")
                })
                    .buttonStyle(LoginButtonStyle())
            }
        }
    }
}

struct LoginButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .font(.callout)
            .foregroundColor(Color("AppColor"))
            .background(configuration.isPressed ? Color(.controlBackgroundColor).opacity(0.8) : Color(.controlBackgroundColor))
            .cornerRadius(5)
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif
