//
//  SwiftUIView.swift
//  SwiftMesh
//
//  Created by iOS on 2023/4/18.
//  Copyright © 2023 iOS. All rights reserved.
//

import SwiftUI

struct SwiftUIView: View {
    @StateObject var request = RequestModel()
    
    var body: some View {
        
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
            Text(request.cityResult?.message ?? "")
        }.onAppear{
            request.getAppliances()
        }
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
