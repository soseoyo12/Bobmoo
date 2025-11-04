response_format = {
    "type": "json_schema",
    "json_schema": {
        "name": "MealsOnly",
        "strict": True,
        "schema": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "breakfast": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "additionalProperties": False,
                        "properties": {
                            "course": {"type": "string"},
                            "mainMenu": {"type": "string"},
                            "price": {"type": "integer"}
                        },
                        "required": ["course", "mainMenu", "price"]
                    }
                },
                "lunch": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "additionalProperties": False,
                        "properties": {
                            "course": {"type": "string"},
                            "mainMenu": {"type": "string"},
                            "price": {"type": "integer"}
                        },
                        "required": ["course", "mainMenu", "price"]
                    }
                },
                "dinner": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "additionalProperties": False,
                        "properties": {
                            "course": {"type": "string"},
                            "mainMenu": {"type": "string"},
                            "price": {"type": "integer"}
                        },
                        "required": ["course", "mainMenu", "price"]
                    }
                }
            },
            "required": ["breakfast", "lunch", "dinner"]
        }
    }
}

__all__ = [
    "response_format",
]