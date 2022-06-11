//
//  ViewController.swift
//  QR Sms
//
//  Created by Emre on 28.04.2022.
//

import UIKit
import Contacts

class ViewController: UITableViewController {
    var SecilenKisi = Kisiler(isim: "", soyisim: "", numara: "")
    var kisiler = [Kisiler]()
    @IBOutlet weak var IleriButon : UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        KisileriGetir()
        IleriButon.isEnabled=false
    }
    private func KisileriGetir() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Request hatası!", error)
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey,CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                request.sortOrder = CNContactSortOrder.userDefault
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        self.kisiler.append(Kisiler(isim: contact.givenName + " " + contact.middleName, soyisim: contact.familyName, numara: contact.phoneNumbers.first?.value.stringValue ?? ""))
                    })
                } catch let error {
                    print("Kisiler getirilemedi", error)
                }
            } else {
                print("Yetki hatası")
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kisiler.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListItem",for: indexPath)
        cell.textLabel?.text = kisiler[indexPath.row].isim + " " + kisiler[indexPath.row].soyisim
        cell.detailTextLabel?.text = kisiler[indexPath.row].numara
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SecilenKisi = kisiler[indexPath.row]
        if (SecilenKisi.isim == " ") {
            IleriButon.isEnabled = false
            let alert = UIAlertController(title:"Uyarı", message:"Lütfen Bir Kisi Seçiniz",preferredStyle:.alert)
            let action = UIAlertAction(title: "Tamam", style: .default, handler:nil)
            alert.addAction(action)
            present(alert,animated: true,completion: nil)
        }
        else if(SecilenKisi.numara == ""){
            IleriButon.isEnabled = false
            let alert = UIAlertController(title:"Uyarı", message:"Kisiye Ait Telefon Numarası Yoktur",preferredStyle:.alert)
            let action = UIAlertAction(title: "Tamam", style: .default, handler:nil)
            alert.addAction(action)
            present(alert,animated: true,completion: nil)
        }
        else{
            IleriButon.isEnabled=true
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let Kisi = SecilenKisi
        let destinationVC = segue.destination as! QRCodeViewController
        destinationVC.Kisi = Kisi
    }

}

