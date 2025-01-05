//
//  ContentView.swift
//  iExpense
//
//  Created by Kevin Darmawan on 04/01/25.
//

import SwiftUI
import Observation

@Observable
class User {
    var firstName = "Kevin"
    var lastName = "Darmawan"
}

struct ArchivedUser: Codable {
    var firstName: String = ""
    var lastName: String = ""
}

struct SecondView: View {
    @Binding var user: User
    @Environment(\.dismiss) var dismiss
    @AppStorage("archivedUsers") private var archivedUsersData = "[]"

    // Helper to decode archived users
    var archivedUsers: [ArchivedUser] {
        guard let data = archivedUsersData.data(using: .utf8) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([ArchivedUser].self, from: data)) ?? []
    }

    // Helper to save archived users
    func saveArchivedUsers(users: [ArchivedUser]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(users) {
            archivedUsersData = String(data: data, encoding: .utf8) ?? "[]"
        }
    }

    // Function to remove a user
    func removeUser(at offsets: IndexSet) {
        var users = archivedUsers
        users.remove(atOffsets: offsets) // Remove the user at the given index
        saveArchivedUsers(users: users) // Save the updated list
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Hello new user, \(user.firstName) \(user.lastName)!")
                List {
                    ForEach(archivedUsers, id: \.firstName) { user in
                        VStack(alignment: .leading) {
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.headline)
                        }
                    }
                    .onDelete(perform: removeUser) // Enable swipe-to-delete
                }
                
                Button("Dismiss") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("Archived Users")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton() // Add an Edit button to enable deletion
            }
        }
    }
}



struct ContentView: View {
    @AppStorage("currentNumber") private var currentNumber = 0
    @State private var user = User()
    @State private var archivedUser = ArchivedUser()
    @State private var showingScreen = false

    @AppStorage("archivedUsers") private var archivedUsersData = "[]"

    func loadArchivedUsers() -> [ArchivedUser] {
        guard let data = archivedUsersData.data(using: .utf8) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([ArchivedUser].self, from: data)) ?? []
    }

    func saveArchivedUsers(users: [ArchivedUser]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(users) {
            archivedUsersData = String(data: data, encoding: .utf8) ?? "[]"
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("User name") {
                        TextField("First Name", text: $user.firstName)
                        TextField("Last Name", text: $user.lastName)
                    }
                    Section("Archived user") {
                        TextField("First Name", text: $archivedUser.firstName)
                        TextField("Last Name", text: $archivedUser.lastName)
                    }
                }
                HStack {

                    Button("Show Archive") {
                        showingScreen.toggle()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30.0, alignment: .center)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(20)
                    .sheet(isPresented: $showingScreen) {
                        SecondView(user: $user)
                    }
                    Button("Add User") {
                        var users = loadArchivedUsers()
                        users.append(archivedUser) // Add the current archivedUser
                        saveArchivedUsers(users: users) // Save the updated list
                        archivedUser = ArchivedUser() // Reset the form
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30.0, alignment: .center)
                    .foregroundStyle(.white)
                    .background(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(20)
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
