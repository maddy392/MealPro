import { type ClientSchema, a, defineData } from '@aws-amplify/backend';
import { fetchRecipes } from '../functions/fetchRecipes/resource';
import { identifyUser } from 'aws-amplify/push-notifications';

/*== STEP 1 ===============================================================
The section below creates a Todo database table with a "content" field. Try
adding a new "isDone" field as a boolean. The authorization rule below
specifies that any unauthenticated user can "create", "read", "update", 
and "delete" any "Todo" records.
=========================================================================*/
const schema = a.schema({

  UserFavorite: a.model({
    userId: a.id().required(),
    recipeId: a.integer().required(),
    recipe: a.belongsTo("Recipe", "recipeId"),
    user: a.belongsTo("User", "userId"),
  }).secondaryIndexes((index) => [
    index("userId")
  .queryField("userFavoritesByUser")
  .sortKeys(["recipeId"])])
  .authorization((allow) => allow.owner()),

  User: a.model({
    userId: a.id().required(),
    username: a.string().required(),
    favorites: a.hasMany("UserFavorite", "userId")
  }).identifier(['userId'])
  .authorization((allow) => allow.owner()),

  Nutrient: a.customType({
    name: a.string().required(),
    amount: a.float(),
    unit: a.string(),
    percentOfDailyNeeds: a.float(),
  }),

  Ingredient: a.customType({
    id: a.integer().required(),
    name: a.string().required(),
    amount: a.float(),
    unit: a.string(),
    localizedName: a.string(),
    image: a.string()
  }),

  Equipment: a.customType({
    id: a.integer().required(),
    name: a.string().required(),
    localizedName: a.string(),
    image: a.string()
  }),

  CaloricBreakdown: a.customType({
    percentProtein: a.float(),
    percentFat: a.float(),
    percentCarbs: a.float(),
  }),

  NutritionProperty: a.customType({
    name: a.string().required(),
    amount: a.float(),
    unit: a.string(),
  }),

  InstructionStep: a.customType({
    number: a.integer().required(), 
    step: a.string().required(),
    ingredients: a.ref("Ingredient").array(),
    equipment: a.ref("Equipment").array(),
  }),

  AnalyzedInstruction: a.customType({
    name: a.string(),
    steps: a.ref("InstructionStep").array(),
  }),

  Recipe: a.model({
      recipeId: a.integer().required(),
      title: a.string().required(),
      image: a.string(),
      imageType: a.string(),
      vegetarian: a.boolean(),
      vegan: a.boolean(),
      glutenFree: a.boolean(),
      dairyFree: a.boolean(),
      veryHealthy: a.boolean(),
      cheap: a.boolean(),
      veryPopular: a.boolean(),
      sustainable: a.boolean(),
      lowFodmap: a.boolean(),
      weightWatcherSmartPoints: a.integer(),
      gaps: a.string(),
      preparationMinutes: a.integer(),
      cookingMinutes: a.integer(),
      aggregateLikes: a.integer(),
      healthScore: a.integer(),
      creditsText: a.string(),
      sourceName: a.string(),
      pricePerServing: a.float(),
      readyInMinutes: a.integer(),
      servings: a.integer(),
      sourceUrl: a.url(),
      summary: a.string(),
      cuisines: a.string().array(),
      dishTypes: a.string().array(),
      diets: a.string().array(),
      occasions: a.string().array(),
      spoonacularSourceUrl: a.url(),
      spoonacularScore: a.float(),
      nutrition: a.customType({
        caloricBreakdown: a.ref("CaloricBreakdown"),
        nutrients: a.ref("Nutrient").array(),
        properties: a.ref("NutritionProperty").array(),
        ingredients: a.ref("Ingredient").array()
      }),
      analyzedInstructions: a.ref("AnalyzedInstruction").array(),
      userFavorites: a.hasMany("UserFavorite", "recipeId"),
    }).identifier(['recipeId'])
    .authorization((allow) => allow.authenticated()), 

  fetchRecipes: a
    .query()
    .arguments({
      cuisine: a.string(), 
      diet: a.string(), 
    })
    .returns(a.ref("Recipe").array())
    .handler(a.handler.function(fetchRecipes))
    .authorization((allow) => allow.authenticated())
  })

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'userPool',
  },
});

// npx ampx generate graphql-client-code --format modelgen --model-target swift --profile mealPro --out MealPro/Models

/*== STEP 2 ===============================================================
Go to your frontend source code. From your client-side code, generate a
Data client to make CRUDL requests to your table. (THIS SNIPPET WILL ONLY
WORK IN THE FRONTEND CODE FILE.)

Using JavaScript or Next.js React Server Components, Middleware, Server 
Actions or Pages Router? Review how to generate Data clients for those use
cases: https://docs.amplify.aws/gen2/build-a-backend/data/connect-to-API/
=========================================================================*/

/*
"use client"
import { generateClient } from "aws-amplify/data";
import type { Schema } from "@/amplify/data/resource";

const client = generateClient<Schema>() // use this Data client for CRUDL requests
*/

/*== STEP 3 ===============================================================
Fetch records from the database and use them in your frontend component.
(THIS SNIPPET WILL ONLY WORK IN THE FRONTEND CODE FILE.)
=========================================================================*/

/* For example, in a React component, you can use this snippet in your
  function's RETURN statement */
// const { data: todos } = await client.models.Todo.list()

// return <ul>{todos.map(todo => <li key={todo.id}>{todo.content}</li>)}</ul>
