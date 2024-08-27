//
//  CKmodel.swift
//  cktest
//
//  Created by João Vitor Lima Mergulhão on 27/08/24.
//

import Foundation
import  CloudKit

class CKmodel: ObservableObject{
    
    let publicDB = CKContainer(identifier: "iCloud.br.ufpe.cin.jvlm2.cktest").publicCloudDatabase
    @Published var records:[CKRecord] = []
    
    func createRecord(text: String){
        let record = CKRecord(recordType: "Message")
        record.setValue(text, forKey: "text")
        
        self.publicDB.save(record) { (savedRecord, error) in
            DispatchQueue.main.async {
                
                if error == nil {
                    print("Deu certo")
                } else {
                    print("Deu erro em alguma coisa...\n" + error!.localizedDescription)
                }
            }
        }
    }
    
    func fetchRecords() async{
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Message", predicate: predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        // porque eu não consigo acessar o campo createdTimestamp??
        
        do {
            let result = try await publicDB.records(matching: query)
 
            // Extrai os registros do resultado
            let fetchedRecords = result.matchResults.compactMap { try? $0.1.get() }
            
            // Atualiza a lista de registros na thread principal
            await MainActor.run {
                self.records = fetchedRecords
                print(records)
            }
            
        } catch {
            print("Erro ao buscar registros: \(error.localizedDescription)")
        }

    }
    
    func deleteRecord(itemToDelete: CKRecord){
        self.publicDB.delete(withRecordID: itemToDelete.recordID){ (deletedRecordID, error) in
            if error != nil{
                print(error.debugDescription)
            }
        }
    }
}
