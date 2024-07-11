//
//  SwiftUIView.swift
//  SwiftMesh
//
//  Created by iOS on 2023/4/18.
//  Copyright © 2023 iOS. All rights reserved.
//

import SwiftUI
import BrickKit
struct SwiftUIView: View {

    @StateObject var request = RequestModel()
    
    var body: some View {
        
        VStack{
            
            Text("Hello, World!")
            
            Text(request.yesterday?.notice ?? "")
//            Text("\(request.yesterday?.getJson())")
            
        }
        .ss.task {
            await request.getResult()
        }
        
    }
    

}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}

extension Data{
    func getJson()-> [String: Any]?{

            return try? JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]

    }
}
