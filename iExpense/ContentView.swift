//
//  ContentView.swift
//  iExpense
//
//  Created by Kevin Darmawan on 04/01/25.
//

import SwiftUI

struct AddView: View {
    
    var expenses: Expenses
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = 0.0
    
    let types = ["Personal", "Family", "Dating"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Type in expense details")
                }
                Section {
                    TextField("Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add new expense")
            .toolbar {
                Button("Save") {
                    let expense = ExpenseItem(name: name, type: type, amount: amount)
                    expenses.items.append(expense)
                    dismiss()
                }
            }
        }
    }
}

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        items = []
    }
    
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
}

struct ContentView: View {
    
    func removeItems(at offsets: IndexSet, from section: String) {
        let itemsToDelete = offsets.map { index in
            section == "Personal"
                ? personalExpenses[index]
                : otherExpenses[index]
        }
        
        for item in itemsToDelete {
            if let index = expenses.items.firstIndex(where: { $0.id == item.id }) {
                expenses.items.remove(at: index)
            }
        }
    }
    
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var personalExpenses: [ExpenseItem] {
        expenses.items.filter { $0.type == "Personal" }
    }
    
    var otherExpenses: [ExpenseItem] {
        expenses.items.filter { $0.type != "Personal" }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Personal Expenses")) {
                        ForEach(personalExpenses) { item in
                            ExpenseRow(item: item)
                        }
                        .onDelete { offsets in
                            removeItems(at: offsets, from: "Personal")
                        }
                    }
                    
                    Section(header: Text("Other Expenses")) {
                        ForEach(otherExpenses) { item in
                            ExpenseRow(item: item)
                        }
                        .onDelete { offsets in
                            removeItems(at: offsets, from: "Business")
                        }
                    }
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                ToolbarItem {
                    Button {
                        showingAddExpense.toggle()
                    } label: {
                        Label("Add Expense", systemImage: "plus")
                    }
                    .sheet(isPresented: $showingAddExpense) {
                        AddView(expenses: expenses)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct ExpenseRow: View {
    let item: ExpenseItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if item.type == "Personal" {
                    Label("Personal", systemImage: "person.fill")
                        .font(.subheadline)
                } else if item.type == "Family" {
                    Label("Family", systemImage: "figure.2.and.child.holdinghands")
                        .font(.subheadline)
                } else if item.type == "Dating" {
                    Label("Dating", systemImage: "heart.circle")
                        .font(.subheadline)
                }
                Text(item.name)
                    .font(.headline)
            }
            Spacer()
            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .foregroundColor(amountColor(for: item.amount))
        }
    }
    
    func amountColor(for amount: Double) -> Color {
        if amount < 50_000 {
            return .green
        } else if amount < 150_000 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    ContentView()
}
