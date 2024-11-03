import { type ClientSchema, a, defineData } from '@aws-amplify/backend';
import { fetchRecipes } from '../functions/fetchRecipes/resource';

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

  Recipe: a
    .model({
      recipeId: a.integer().required(),
      title: a.string().required(),
      image: a.string(),
      imageType: a.string(),
      userFavorites: a.hasMany("UserFavorite", "recipeId"),
    }).identifier(['recipeId'])
    .authorization((allow) => allow.owner()), 

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
