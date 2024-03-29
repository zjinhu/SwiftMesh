//
//  SwiftUIView.swift
//  SwiftMesh
//
//  Created by iOS on 2023/4/18.
//  Copyright © 2023 iOS. All rights reserved.
//

import SwiftUI
import SwiftBrick

struct SwiftUIView: View {

    @StateObject var request = RequestModel()
    
    var body: some View {
        
        VStack{
            
            Text("Hello, World!")
            
            Text(request.yesterday?.notice ?? "")
            
        }
        .task {
            await request.getResult()
        }
        
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
