//
//  ContentView.swift
//  cktest
//
//  Created by João Vitor Lima Mergulhão on 25/08/24.
//

import SwiftUI
import CloudKit

struct ContentView: View {
    @StateObject var cloudDB = CKmodel()
    @State var textValue:String = ""
    @State var messages: [String] = []
    @State var records: [CKRecord] = []

    var body: some View {
        VStack {
            TextField("escreva algo", text: $textValue)
            
            Button(action: {
                cloudDB.createRecord(text: textValue)
            }, label: {
                Text("Salvar")
            })
            
            Button(action: {
                Task {
                    await cloudDB.fetchRecords()
                    }
            }, label: {
                Text("Atualizar")
            })
            
            List{
                ForEach(cloudDB.records, id: \.self){ record in
                    Text(record["text"] as? String ?? "No Text")
                }
            }
            .onAppear{
                Task{
                    await cloudDB.fetchRecords()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
