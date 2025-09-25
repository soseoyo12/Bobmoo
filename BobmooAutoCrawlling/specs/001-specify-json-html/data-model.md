## Data Model

### Standard JSON Fields
- date: string (YYYY-MM-DD)
- school: string
- cafeterias: array of Cafeteria
  - name: string
  - hours: object { breakfast?: string, lunch?: string, dinner?: string }
  - meals: object { breakfast?: Meal[], lunch?: Meal[], dinner?: Meal[] }
- Meal: { course: string, mainMenu: string, price: number }

### JSON Schema (draft-07)
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["date", "school", "cafeterias"],
  "properties": {
    "date": { "type": "string", "pattern": "^\\d{4}-\\d{2}-\\d{2}$" },
    "school": { "type": "string", "minLength": 1 },
    "cafeterias": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["name", "hours", "meals"],
        "properties": {
          "name": { "type": "string" },
          "hours": {
            "type": "object",
            "properties": {
              "breakfast": { "type": "string" },
              "lunch": { "type": "string" },
              "dinner": { "type": "string" }
            },
            "additionalProperties": false
          },
          "meals": {
            "type": "object",
            "properties": {
              "breakfast": { "$ref": "#/definitions/MealArray" },
              "lunch": { "$ref": "#/definitions/MealArray" },
              "dinner": { "$ref": "#/definitions/MealArray" }
            },
            "additionalProperties": false
          }
        },
        "additionalProperties": false
      }
    }
  },
  "definitions": {
    "Meal": {
      "type": "object",
      "required": ["course", "mainMenu", "price"],
      "properties": {
        "course": { "type": "string" },
        "mainMenu": { "type": "string" },
        "price": { "type": "number", "minimum": 0 }
      },
      "additionalProperties": false
    },
    "MealArray": {
      "type": "array",
      "items": { "$ref": "#/definitions/Meal" }
    }
  },
  "additionalProperties": false
}
```
