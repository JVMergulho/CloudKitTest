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
    
    func createRecord(text: String) async{
        let record = CKRecord(recordType: "Message")
        record.setValue(text, forKey: "text")
        var isCodeUnique = false
        var code: String = ""
        
        while(!isCodeUnique){
            code = generateCode()
            
            let predicate = NSPredicate(format: "enterCode == %@", code)
            
            let query = CKQuery(recordType: "Message", predicate: predicate)
            
            do {
                let result = try await publicDB.records(matching: query)
                
                if result.matchResults.isEmpty {
                    isCodeUnique = true
                }
                
            } catch {
                print("Erro ao buscar registros: \(error.localizedDescription)")
            }
        }
        
        record.setValue(code, forKey: "enterCode")
        
        self.publicDB.save(record) { (savedRecord, error) in
            DispatchQueue.main.async {
                
                if error == nil {
                    print("Mensagem registrada no banco de dados")
                } else {
                    print("Deu erro em alguma coisa...\n" + error!.localizedDescription)
                }
            }
        }
    }
    
    func generateCode(length: Int = 6) -> String{
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var code = ""
        
        for _ in 0..<length{
            if let randomChar = characters.randomElement(){
                code += String(randomChar)
            }
        }
        
        return code
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
