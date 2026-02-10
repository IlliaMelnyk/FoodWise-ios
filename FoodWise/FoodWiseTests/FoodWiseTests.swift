import XCTest
@testable import FoodWise

final class FoodWiseTests: XCTestCase {

    func testAIReceiptParsing() throws {
        let jsonString = """
        [
            {"name": "Milk", "days": 5, "category": "Dairy"},
            {"name": "Bread", "days": 3, "category": "Bakery"}
        ]
        """
        let jsonData = jsonString.data(using: .utf8)!
        let items = try JSONDecoder().decode([AIReceiptItem].self, from: jsonData)
        XCTAssertEqual(items.count, 2, "We should have 2 items")
        
        XCTAssertEqual(items[0].name, "Milk")
        XCTAssertEqual(items[0].days, 5)
        XCTAssertEqual(items[0].category, "Dairy")
        
        XCTAssertEqual(items[1].name, "Bread")
    }
    
    func testExpiryLogic() {
            let today = Date()
            let calendar = Calendar.current
            
            let futureDate = calendar.date(byAdding: .day, value: 10, to: today)!
            let pastDate = calendar.date(byAdding: .day, value: -1, to: today)!
            let nearDate = calendar.date(byAdding: .day, value: 1, to: today)!
            
            let freshItem = KitchenItem(householdId: "1", name: "Fresh", quantity: 1, unit: "pcs", pieces: 1, expiryDate: futureDate, category: "Other", status: .active)
            let rottenItem = KitchenItem(householdId: "1", name: "Rotten", quantity: 1, unit: "pcs", pieces: 1, expiryDate: pastDate, category: "Other", status: .active)
            let warningItem = KitchenItem(householdId: "1", name: "Soon", quantity: 1, unit: "pcs", pieces: 1, expiryDate: nearDate, category: "Other", status: .active)
            
            XCTAssertEqual(freshItem.expiryStatus(for: today), "OK", "Should be OK")
            XCTAssertEqual(rottenItem.expiryStatus(for: today), "Expired", "Should be expired")
            XCTAssertEqual(warningItem.expiryStatus(for: today), "Warning", "Should warn")
        }
    
    func testKitchenSortingLogic() {
            let today = Date()
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
            
            let freshItem = KitchenItem(householdId: "1", name: "Long-lasting", quantity: 1, unit: "pcs", pieces: 1, expiryDate: nextWeek, category: "Pantry", status: .active)
            let urgentItem = KitchenItem(householdId: "1", name: "Perishable", quantity: 1, unit: "pcs", pieces: 1, expiryDate: tomorrow, category: "Dairy", status: .active)
            
            let unsortedList = [freshItem, urgentItem]
            
            let sortedList = unsortedList.sorted { $0.expiryDate < $1.expiryDate }
            
            XCTAssertEqual(sortedList.first?.name, "Perishable", "Item with earlier expiration should be first")
            XCTAssertEqual(sortedList.last?.name, "Long-lasting", "Item with later expiration should be last")
        }

    func testShoppingItemToggle() {
            var item = ShoppingItem(listId: "1", name: "Bananas", quantity: "1 bunch", isCompleted: false)
            
            item.isCompleted.toggle()
            
            XCTAssertTrue(item.isCompleted, "Item should be completed (true) after toggle")
            
            item.isCompleted.toggle()
            
            XCTAssertFalse(item.isCompleted, "Item should be incomplete (false) after second toggle")
        }

    func testAIInvalidParsing() {
            let badJsonString = """
            [
                {"name": "Mystery Item"}
            ]
            """
            let jsonData = badJsonString.data(using: .utf8)!
            
            XCTAssertThrowsError(try JSONDecoder().decode([AIReceiptItem].self, from: jsonData)) { error in
                if case .keyNotFound(let key, _) = error as? DecodingError {
                    print("Correctly caught error: Missing key '\(key.stringValue)'")
                }
            }
        }

    


    func testWasteParsing() throws {
            let jsonString = """
            {
                "groups": [
                    { "kategorie": "Banana", "pocet": 3 },
                    { "kategorie": "Yogurt", "pocet": 1 }
                ]
            }
            """
            let jsonData = jsonString.data(using: .utf8)!
            let response = try JSONDecoder().decode(GeminiWasteResponse.self, from: jsonData)
            
            XCTAssertEqual(response.groups.count, 2)
            XCTAssertEqual(response.groups[0].categoryName, "Banana")
            XCTAssertEqual(response.groups[0].count, 3)
        }
    func testWatchDataSerialization() {
            let item = KitchenItem(householdId: "h1", name: "Test Item", quantity: 5, unit: "kg", pieces: 5, expiryDate: Date(), category: "Meat", status: .active)
            let dictionary: [String: Any] = [
                "id": item.id ?? "",
                "name": item.name,
                "expiryDate": item.expiryDate,
                "quantity": item.quantity,
                "unit": item.unit
            ]
            
            XCTAssertEqual(dictionary["name"] as? String, "Test Item")
            XCTAssertEqual(dictionary["quantity"] as? Int, 5)
            XCTAssertNotNil(dictionary["expiryDate"], "Date must not be missing")
        }
 
    func testDateFormatting() {
            let formatter = DateFormatter()
            formatter.dateFormat = "d. M."
            var components = DateComponents()
            components.year = 2025
            components.month = 12
            components.day = 24
            let christmas = Calendar.current.date(from: components)!
            
            let stringDate = formatter.string(from: christmas)
            XCTAssertEqual(stringDate, "24. 12.", "Date format does not match")
        }
    
    func testKitchenItemStatusChange() {
            let today = Date()
            let item = KitchenItem(
                householdId: "1",
                name: "Apple",
                quantity: 1,
                unit: "pcs",
                pieces: 1,
                expiryDate: today,
                category: "Produce",
                status: .active // Default state
            )

            var consumedItem = item
            consumedItem.status = .used
            
            var wastedItem = item
            wastedItem.status = .wasted
        
            XCTAssertEqual(consumedItem.status, .used, "Status should have changed to used")
            XCTAssertEqual(wastedItem.status, .wasted, "Status should have changed to wasted")
            XCTAssertNotEqual(consumedItem.status, item.status, "Status should not remain active")
        }

    func testAddItemsFromOCRLogic() {
            let viewModel = KitchenListViewModel()
            viewModel.state.products = []
            
            let aiItems = [
                AIReceiptItem(name: "Milk", days: 5, category: "Dairy"),
                AIReceiptItem(name: "Honey", days: 365, category: "Pantry")
            ]
            viewModel.addItemsFromOCR(aiItems, targetHouseholdId: "test_house_123")
            
            XCTAssertEqual(viewModel.state.products.count, 2, "2 items should be added")
            
            guard let milk = viewModel.state.products.first(where: { $0.name == "Milk" }) else {
                XCTFail("Milk not found in list")
                return
            }
            
            XCTAssertEqual(milk.category, "Dairy")
            
            let calendar = Calendar.current
            let today =  Date()
            
            let startOfToday = calendar.startOfDay(for: today)
            
            let startOfMilkExpiry = calendar.startOfDay(for: milk.expiryDate)
            let milkDaysDiff = calendar.dateComponents([.day], from: startOfToday, to: startOfMilkExpiry).day
            XCTAssertEqual(milkDaysDiff, 5, "Milk expiration should be in 5 days")
            
            guard let honey = viewModel.state.products.first(where: { $0.name == "Honey" }) else {
                XCTFail("Honey not found")
                return
            }
            
            let startOfHoneyExpiry = calendar.startOfDay(for: honey.expiryDate)
            let honeyDaysDiff = calendar.dateComponents([.day], from: startOfToday, to: startOfHoneyExpiry).day
            XCTAssertEqual(honeyDaysDiff, 365, "Honey expiration should be in 365 days")
        }
    
}
