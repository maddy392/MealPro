# MealPro 🍴

MealPro is a modern recipe recommendation app that leverages **Spoonacular APIs** and AI-powered agents to help users discover and manage their favorite recipes. With intuitive features like searching recipes, finding similar dishes, and maintaining a list of favorites, MealPro aims to simplify meal planning and cooking.

---

## Features ✨

- **Chat-based Recipe Discovery**: Use conversational input to discover recipes, including AI-powered suggestions.
- **Similar Recipe Suggestions**: Quickly find recipes related to your favorites.
- **Favorites Management**: Add, remove, and organize your favorite recipes with a simple interface.
- **Health and Dietary Information**: Recipes include details like preparation time, health score, and dietary filters (vegan, vegetarian, gluten-free, etc.).
- **Dynamic UI Badging**: Badge on the favorites tab showing the count of favorite recipes.
- **Seamless API Integration**: Powered by **Spoonacular APIs** and AWS Lambda functions for recipe fetching and recommendations.

---

## Tech Stack 🛠️

- **Frontend**: SwiftUI (iOS 17+)
- **Backend**:
  - AWS Lambda with a streaming response using FAST API's lambda adaptor
  - Amplify Gen 2 for:
    - Data models
    - Authentication
    - AppSync APIs using Dynamo DB tables
  - AWS Bedrock Agents with Lambda Function Action Groups
	- Post-Processing Advanced Prompt Template to format the final response appropriately
- **APIs**:
  - Spoonacular API for recipe data
  - AWS Bedrock Agents for orchestrating responses
- **Storage**: AWS SSM for secure key management
- **State Management**: SwiftUI `@StateObject` and `@EnvironmentObject`

---

