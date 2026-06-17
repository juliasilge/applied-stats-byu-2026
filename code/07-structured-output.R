# 07-structured-output.R
# Deck 02: Programming with LLMs (Structured output)
# Goal: extract structured fields (ingredients, steps, yield, prep time) from a
# recipe PDF using ellmer::type_*().

# %% Import package
library(ellmer)

# %% Read in the recipes from text files
recipe_txt <- here::here("data/recipes/text")
txt_waffles <- recipe_txt |>
  file.path("CinnamonPeachOatWaffles.md") |>
  readLines()
txt_waffles |> substring(1, 500) |> cat()

# %% Markdown for example output
#' Here's an example of the structured output we want to achieve for a single
#' recipe:
#'
#' {
#'   "title": "Spicy Mango Salsa Chicken",
#'   "description": "A flavorful and vibrant chicken dish...",
#'   "ingredients": [
#'     {
#'       "name": "Chicken Breast",
#'       "quantity": "4",
#'       "unit": "medium",
#'       "notes": "Boneless, skinless"
#'     },
#'     {
#'       "name": "Lime Juice",
#'       "quantity": "2",
#'       "unit": "tablespoons",
#'       "notes": "Fresh"
#'     }
#'   ],
#'   "instructions": [
#'     "Preheat grill to medium-high heat.",
#'     "In a bowl, combine ...",
#'     "Season chicken breasts with salt and pepper.",
#'     "Grill chicken breasts for 6-8 minutes per side, or until cooked through.",
#'     "Serve chicken topped with the spicy mango salsa."
#'   ]
#' }

# %% Make a type object to represent the structured output we want from the recipe
type_recipe <- type_object(
  title = type_string(),
  description = type_string(),
  ingredients = type_array(
    type_object(
      name = type_string(),
      quantity = type_number(),
      unit = type_string(required = FALSE),
      notes = type_string(required = FALSE)
    ),
  ),
  instructions = type_array(type_string())
)

# %% Pass the recipe text and the Pydantic model to get structured output
chat <- chat_anthropic()
recipe <- chat$chat_structured(txt_waffles, type = type_recipe)

# %% We get a list back, so you can access fields directly
recipe$title
recipe$ingredients
