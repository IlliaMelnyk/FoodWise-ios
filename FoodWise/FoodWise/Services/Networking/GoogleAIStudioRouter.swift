//
//  GoogleAIStudioRouter.swift
//  FoodWise
//
//  Created by Illia Melnyk on 18.12.2025.
//

import Foundation

enum GoogleAIStudioRouter: Endpoint {
    
    
    case generateCategorizedRecipes(
        allIngredients: [String],
        expiringIngredients: [String],
        preferences: [String],
        restrictions: [String]
    )
    

    case analyzeWaste(items: [String])
    
 
    case parseReceipt(rawText: String)

    var host: String { "generativelanguage.googleapis.com" }
    var path: String { "/v1beta/models/gemini-flash-lite-latest:generateContent" }
    var method: HttpMethod { .post }
    var headers: [String: String] { ["Content-Type": "application/json"] }

    var urlParameters: [String: Any]? {
        guard let apiKey = Secrets.get("GEMINI_API_KEY") else { return nil }
        return ["key": apiKey]
    }

    var body: Data? {
        switch self {
            
            
        case let .generateCategorizedRecipes(allIngredients, expiringIngredients, preferences, restrictions):
            let allStr = allIngredients.joined(separator: ", ")
            let expStr = expiringIngredients.joined(separator: ", ")
            let prefStr = preferences.joined(separator: ", ")
            let restrStr = restrictions.joined(separator: ", ")
            
            let prompt = """
                Jsi kuchařská aplikace. Mám tyto suroviny: [\(allStr)].
                Z toho tyto brzy projdou expirací: [\(expStr)].
                
                ---------------------------------------------------
                DŮLEŽITÉ - DIETNÍ PROFIL UŽIVATELE:
                Preference: [\(prefStr)]
                Restrikce/Omezení: [\(restrStr)]
                
                Všechny navržené recepty MUSÍ striktně respektovat tato pravidla.
                ---------------------------------------------------
                
                Vytvoř JSON odpověď se 3 kategoriemi receptů.
                
                DŮLEŽITÉ PRAVIDLO 1: Ingredience ("pouzite_suroviny" a "chybejici_suroviny") NIKDY nevracej jako prostý text. VŽDY je vrať jako seznam objektů, kde každý má "nazev" a "mnozstvi".
                
                DŮLEŽITÉ PRAVIDLO 2 (PRO OBRÁZKY): Ke každému receptu přidej pole "image_keywords". To musí obsahovat JEDNODUCHÝ ANGLICKÝ NÁZEV jídla (max 2-3 slova), který se použije pro vyhledání fotky (např. "Tomato soup", "Gnocchi garlic", "Scrambled eggs").
                
                Kategorie:
                1. "ready_to_cook": 3 recepty, které uvařím POUZE z mých surovin.
                2. "expiring_soon": 3 recepty, které prioritně využijí ty procházející suroviny.
                3. "need_more_ingredients": 3 recepty, kde využiju mé suroviny, ale musím dokoupit 1-2 věci.
                
                Odpověz POUZE tímto validním JSON formátem (bez markdownu):
                {
                    "ready_to_cook": [
                        {
                            "nazev": "Míchaná vajíčka na cibulce",
                            "image_keywords": "Scrambled eggs",
                            "cas": "10 min",
                            "pouzite_suroviny": [
                                { "nazev": "Vejce", "mnozstvi": "3 ks" }
                            ],
                            "postup": "..."
                        }
                    ],
                    "expiring_soon": [
                        {
                            "nazev": "...",
                            "image_keywords": "...",
                            "cas": "...",
                            "pouzite_suroviny": [],
                            "postup": "..."
                        }
                    ],
                    "need_more_ingredients": [
                        {
                            "nazev": "...",
                            "image_keywords": "...",
                            "cas": "...",
                            "pouzite_suroviny": [],
                            "chybejici_suroviny": [],
                            "postup": "..."
                        }
                    ]
                }
                """
            
            let json: [String: Any] = [
                "contents": [["parts": [["text": prompt]]]]
            ]
            return try? JSONSerialization.data(withJSONObject: json)
            
        case let .analyzeWaste(items):
            let itemsString = items.joined(separator: ", ")
            
            let prompt = """
            Jsem aplikace na plýtvání jídlem. Mám tento seznam vyhozených položek (názvy se mohou lišit tvarem, velikostí písmen nebo přídavnými jmény):
            [\(itemsString)]
            
            Tvým úkolem je:
            1. Sémanticky seskupit položky, které jsou to samé (např. "Rajče", "Rajčátka", "Hnilé rajče" -> vše je kategorie "Rajče").
            2. Ignorovat přídavná jména (červené, malé, bio...), pokud nemění podstatu potraviny.
            3. Spočítat výskyty v každé kategorii.
            4. Seřadit podle počtu sestupně.
            
            Odpověz POUZE tímto JSON formátem (bez markdownu):
            {
                "groups": [
                    { "kategorie": "Jablko", "pocet": 5 },
                    { "kategorie": "Mléko", "pocet": 2 }
                ]
            }
            """
            
            let json: [String: Any] = [
                "contents": [["parts": [["text": prompt]]]]
            ]
            return try? JSONSerialization.data(withJSONObject: json)
            
        case let .parseReceipt(rawText):
            let prompt = """
                    Jsem aplikace na správu lednice. Zde je hrubý text z účtenky (OCR):
                    \"\"\"
                    \(rawText)
                    \"\"\"
                    
                    Tvým úkolem je:
                    1. Přečíst text a identifikovat POUZE POTRAVINY a NÁPOJE.
                    2. IGNOROVAT: Ceny, názvy obchodů, DPH, adresy a NEPOTRAVINÁŘSKÉ ZBOŽÍ.
                    3. Očistit název od množství a cen. Převeď VELKÁ PÍSMENA na Normální.
                    4. Odhadnout trvanlivost ve dnech od nákupu (celé číslo).
                    5. Přiřadit kategorii: "Dairy", "Meat", "Produce", "Bakery", "Pantry", "Other".
                    
                    DŮLEŽITÉ - STRUKTURA ODPOVĚDI:
                    Odpověz POUZE validním JSON polem. Každý objekt MUSÍ mít přesně tyto klíče:
                    - "name": (String) název produktu
                    - "days": (Int) počet dní trvanlivosti (např. 5, 7, 365)
                    - "category": (String) jedna z kategorií výše
                    
                    Příklad výstupu:
                    [{"name": "Mléko", "days": 5, "category": "Dairy"}, {"name": "Jablko", "days": 7, "category": "Produce"}]
                    """
            
            let json: [String: Any] = [
                "contents": [["parts": [["text": prompt]]]]
            ]
            return try? JSONSerialization.data(withJSONObject: json)
        }
    }
}
