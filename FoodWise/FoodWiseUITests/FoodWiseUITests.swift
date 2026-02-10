//
//  FoodWiseUITests.swift
//  FoodWiseUITests
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import XCTest

final class FoodWiseUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddManuallyFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        let mainAddButton = app.buttons["main_add_button"]
        XCTAssertTrue(mainAddButton.waitForExistence(timeout: 5), "Main Add button is missing")
        mainAddButton.tap()
            let manualOption = app.buttons["add_manually_option"]
        XCTAssertTrue(manualOption.waitForExistence(timeout: 2))
        manualOption.tap()
    
        let nameField = app.textFields["item_name_input"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Test Avocado")
        
        let quantityField = app.textFields["item_quantity_input"]
        if quantityField.exists {
            quantityField.tap()
            quantityField.typeText("200")
        }
        
        let navBar = app.navigationBars.firstMatch
        if navBar.exists { navBar.tap() }
        
        app.swipeUp()
        
        let saveButton = app.buttons["confirm_add_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2), "Save button is missing")
        saveButton.tap()
        
        let formDisappeared = saveButton.waitForExistence(timeout: 1) == false
        XCTAssertTrue(formDisappeared, "Form did not close after saving")
    }

    func testCreateShoppingListFlow() throws {
        let app = XCUIApplication()
        app.launch()
        print(app.debugDescription)
        
        //let shoppingTab = app.tabBars.buttons["Shopping"]
        let shoppingTab = app.buttons["Shopping"]
        
        let splashScreenDismissed = shoppingTab.waitForExistence(timeout: 10)
        XCTAssertTrue(splashScreenDismissed, "Timed out waiting for Splash Screen to disappear.")
        XCTAssertTrue(shoppingTab.exists, "Shopping tab is missing.")
        
        XCTAssertTrue(shoppingTab.waitForExistence(timeout: 5), "Tab 'Shopping' was not found")
        shoppingTab.tap()
    
        
        let addListBtn = app.buttons["add_shopping_list_button"]
        XCTAssertTrue(addListBtn.waitForExistence(timeout: 5), "Add list button is missing")
        addListBtn.tap()
        
        let nameField = app.textFields["list_name_input"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2), "List name input is missing")
        nameField.tap()
        nameField.typeText("Weekend Shopping")

    
        let createBtn = app.buttons["create_list_button"]
        XCTAssertTrue(createBtn.exists)
        createBtn.tap()
        
        let doesNotExist = NSPredicate(format: "exists == false")
        expectation(for: doesNotExist, evaluatedWith: createBtn, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
    }

    func testRecipesDisplay() throws {
            let app = XCUIApplication()
            app.launch()
            
            let recipesTab = app.tabBars.buttons["Recipes"]
            if recipesTab.exists { recipesTab.tap() }
            
            let emptyView = app.otherElements["empty_fridge_view"]
            let loading = app.activityIndicators["recipes_loading_indicator"]
            
            let recipeSection = app.staticTexts["Ready to Cook "]
            
            let somethingAppeared = emptyView.waitForExistence(timeout: 10) ||
                                    loading.waitForExistence(timeout: 10) ||
                                    recipeSection.waitForExistence(timeout: 5)
            
            XCTAssertTrue(somethingAppeared, "Recipes screen is empty (neither loading, empty state, nor recipes found)")
        }

    func testStatisticsDisplay() throws {
        let app = XCUIApplication()
        app.launch()
        
        let statsTab = app.buttons["Statistics"]
        
        let splashScreenDismissed = statsTab.waitForExistence(timeout: 10)
        XCTAssertTrue(splashScreenDismissed, "Timed out waiting for Splash Screen to disappear.")
        XCTAssertTrue(statsTab.exists, "Statistics tab is missing.")
        
        if statsTab.exists {
            statsTab.tap()
        } else {
            let profileTab = app.buttons["Profile"]
            if profileTab.exists {
                profileTab.tap()
                if app.buttons["Statistics"].exists {
                    app.buttons["Statistics"].tap()
                }
            }
        }
        
        let chartTitle = app.staticTexts["waste_chart_title"]
        XCTAssertTrue(chartTitle.exists, "Chart title is missing")
    }

    func testProfileLogoutButton() throws {
        let app = XCUIApplication()
        app.launch()
        
        let profileTab = app.buttons["Profile"]
        let splashScreenDismissed = profileTab.waitForExistence(timeout: 10)
        XCTAssertTrue(splashScreenDismissed, "Timed out waiting for Splash Screen to disappear.")
        
        XCTAssertTrue(profileTab.exists, "Profile tab is missing")
        
        profileTab.tap()
        
        let logoutButton = app.buttons["logout_button"]
        if logoutButton.waitForExistence(timeout: 2) {
            XCTAssertTrue(logoutButton.isHittable)
        } else {
            print("Logout button not found - maybe you are not logged in?")
        }
    }
}
