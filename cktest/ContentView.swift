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
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .font(.body)
                .foregroundColor(.black)
            
            HStack{
                Button(action: {
                    cloudDB.createRecord(text: textValue)
                }, label: {
                    Text("Salvar")
                        .padding()
                        .frame(width: 130)
                        .background(.blue)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                })
                
                Spacer()
                
                Button(action: {
                    Task {
                        await cloudDB.fetchRecords()
                        }
                }, label: {
                    HStack{
                        Text("Atualizar")
                        Image(systemName: "arrow.clockwise")
                    }
                        .padding()
                        .frame(width: 130)
                        .background(.blue)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                })
            }
            .padding(.horizontal)
            
            List{
                ForEach(cloudDB.records, id: \.self){ record in
                    Text(record["text"] as? String ?? "No Text")
                }
                .onDelete(perform: deleteRecords(at:))
            }
            .onAppear{
                Task{
                    await cloudDB.fetchRecords()
                }
            }
        }
        .padding()
    }
    
    func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            let record = cloudDB.records[index]
            cloudDB.deleteRecord(itemToDelete: record)
        }
    }
}

#Preview {
    ContentView()
}
