#!/bin/bash

# Enable strict mode for better error handling:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error.
# -o pipefail: Make the script exit if any command in a pipeline fails.
set -euo pipefail

# Color variables
GREEN='\e[0;32m'
RED='\e[0;31m'
BLUE='\e[0;34m'
YELLOW='\e[0;33m'
CYAN='\e[0;36m'
RESET="\e[0m"

# Print banner
echo -e "${GREEN}"
echo "╔═════════════════════════════════════╗"
echo "║ 🛠️ Bun Backend Boilerplate CLI 🛠️   ║"
echo "║ ✨ Created by: Mohammad Aman ✨     ║"
echo "║ 🚀 github.com/mohammad-1105 🚀      ║"
echo "╚═════════════════════════════════════╝"
echo -e "${RESET}"

# Check if bun is installed
if ! command -v bun &>/dev/null; then
    echo -e "${RED}Bun is not installed. Please install it from https://bun.sh${RESET}"
    exit 1
fi

# Ask questions about backend setup
read -p "$(echo -e "${BLUE}Enter the name of the project: ${RESET}")" project_name

# Check if the project name is empty
if [[ -z "$project_name" ]]; then
    echo -e "${RED}Project name cannot be empty.${RESET}"
    exit 1
fi

# Check if the project name contains invalid characters
if [[ "$project_name" =~ [^a-zA-Z0-9_-] ]]; then
    echo -e "${RED}Project name can only contain letters, numbers, underscores, and hyphens.${RESET}"
    exit 1
fi

# Check if the project name already exists
if [ -d "$project_name" ]; then
    echo -e "${RED}Project name already exists.${RESET}"
    exit 1
fi

# Ask about framework choice
echo -e "${YELLOW}Select a web framework to use:${RESET}"
echo "1) Hono (lightweight and fast)"
echo "2) Express (feature-rich and widely used)"
read -p "$(echo -e "${BLUE}Enter your choice (1-2): ${RESET}")" framework_choice

# Validate framework choice
while [[ "$framework_choice" != "1" && "$framework_choice" != "2" ]]; do
    read -p "$(echo -e "${RED}Invalid choice. Enter 1 or 2: ${RESET}")" framework_choice
done

# Set framework
case $framework_choice in
1) framework="hono" ;;
2) framework="express" ;;
esac

# Ask about version-based setup
read -p "$(echo -e "${BLUE}Do you want to use version-based API setup? (y/n): ${RESET}")" version_based

# Validate version-based setup
while [[ "$version_based" != "y" && "$version_based" != "n" ]]; do
    read -p "$(echo -e "${RED}Invalid choice. Enter y or n: ${RESET}")" version_based
done

# Ask about database
echo -e "${YELLOW}Select a database to use:${RESET}"
echo "1) MongoDB with Mongoose"
echo "2) PostgreSQL with Drizzle"
echo "3) None (skip database setup)"
read -p "$(echo -e "${BLUE}Enter your choice (1-3): ${RESET}")" db_choice

case $db_choice in
1) database="mongoose" ;;
2) database="drizzle" ;;
*) database="none" ;;
esac

# Display configuration summary
echo -e "\n${CYAN}Project configuration:${RESET}"
echo -e "• Project name: ${GREEN}$project_name${RESET}"
echo -e "• Framework: ${GREEN}$framework${RESET}"
echo -e "• Version-based API: ${GREEN}${version_based}${RESET}"
echo -e "• Database: ${GREEN}${database}${RESET}"

read -p "$(echo -e "${YELLOW}Proceed with this configuration? (y/n): ${RESET}")" confirm

if [[ "$confirm" != "y" ]]; then
    echo -e "${YELLOW}Setup cancelled. Exiting...${RESET}"
    exit 0
fi

# Message to the user
echo -e "${GREEN}Creating project...${RESET} $project_name"

# Create the project directory
mkdir "$project_name"

# Move to the project directory
cd "$project_name"

# Run bun init
bun init -y

# Create directory structure based on version-based option
if [[ "$version_based" == "y" ]]; then
    mkdir -p src/v1/{models,controllers,routes,middlewares,db,utils,config}
    mv index.ts src/index.ts
    touch src/v1/{app.ts,constants.ts}
    touch src/v1/config/index.ts
else
    mkdir -p src/{models,controllers,routes,middlewares,db,utils,config}
    mv index.ts src/index.ts
    touch src/{app.ts,constants.ts}
    touch src/config/index.ts
fi

# Setup database files
if [[ "$database" == "mongoose" ]]; then
    if [[ "$version_based" == "y" ]]; then
        # Create database connection file
        cat >src/v1/db/mongoose.ts <<EOF
import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/$project_name';

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

export default connectDB;
EOF
        # Update index file in db directory
        cat >src/v1/db/index.ts <<EOF
import connectDB from './mongoose';

export default connectDB;
EOF
    else
        # Create database connection file
        cat >src/db/mongoose.ts <<EOF
import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/$project_name';

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

export default connectDB;
EOF
        # Update index file in db directory
        cat >src/db/index.ts <<EOF
import connectDB from './mongoose';

export default connectDB;
EOF
    fi
elif [[ "$database" == "drizzle" ]]; then
    if [[ "$version_based" == "y" ]]; then
        # Create drizzle schema file
        cat >src/v1/db/schema.ts <<EOF
// Your schemas goes here
EOF

        # Create database connection file
        cat >src/v1/db/index.ts <<EOF
// Your database connection code here
EOF
        # Create drizzle config file
        touch drizzle.config.ts
        cat >drizzle.config.ts <<EOF

import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  out: './drizzle',
  schema: './src/v1/db/schema.ts',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URI!,
  },
  verbose: true,
  strict: true
});

EOF

    else
        # Create drizzle schema file
        cat >src/db/schema.ts <<EOF
// Your schemas goes here
EOF

        # Create database connection file
        cat >src/db/index.ts <<EOF
// Your database connection code here
EOF
        # Create drizzle config file
        touch drizzle.config.ts
        cat >drizzle.config.ts <<EOF
import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  out: './drizzle',
  schema: './src/db/schema.ts',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  verbose: true,
  strict: true
});

EOF

    fi
fi

# Create main index.ts file based on framework choice
if [[ "$framework" == "hono" ]]; then
    if [[ "$version_based" == "y" ]]; then
        cat >src/index.ts <<EOF
import app from './v1/app';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const PORT = process.env.PORT || 3000;

console.log(\`🚀 Server starting on port \${PORT}\`);

Bun.serve({
  fetch: app.fetch,
  port: Number(PORT)
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});
EOF

        # Create app.ts file for Hono
        cat >src/v1/app.ts <<EOF
import { Hono } from 'hono';
import { logger } from 'hono/logger';
import { cors } from 'hono/cors';
EOF

        cat >>src/v1/app.ts <<EOF

const app = new Hono();

// Middleware
app.use('*', logger());
app.use('*', cors());

// Health check route
app.get('/health', (c) => {
  return c.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.get('/', (c) => {
  return c.json({ message: 'Welcome to the API!', version: 'v1' });
});

export default app;
EOF
    else
        # Non-versioned Hono setup
        cat >src/index.ts <<EOF
import app from './app';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const PORT = process.env.PORT || 3000;

console.log(\`🚀 Server starting on port \${PORT}\`);


Bun.serve({
  fetch: app.fetch,
  port: Number(PORT)
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});
EOF

        # Create app.ts file for Hono
        cat >src/app.ts <<EOF
import { Hono } from 'hono';
import { logger } from 'hono/logger';
import { cors } from 'hono/cors';
EOF

        cat >>src/app.ts <<EOF

const app = new Hono();

// Middleware
app.use('*', logger());
app.use('*', cors());

// Health check route
app.get('/health', (c) => {
  return c.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.get('/', (c) => {
  return c.json({ message: 'Welcome to the API!' });
});

export default app;
EOF
    fi
else
    # Express framework setup
    if [[ "$version_based" == "y" ]]; then
        cat >src/index.ts <<EOF
import app from './v1/app';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const PORT = process.env.PORT || 3000;

// Start Express server
const server = app.listen(PORT, () => {
  console.log(\`🚀 Server running on port \${PORT}\`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});
EOF

        # Create app.ts file for Express
        cat >src/v1/app.ts <<EOF
import express, { type Request, type Response } from 'express';
import cors from 'cors';
import morgan from 'morgan';

const app = express();

// Middleware
app.use(express.json());
app.use(cors());
app.use(morgan('dev'));

// Health check route
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.get('/', (req: Request, res: Response) => {
  res.json({ message: 'Welcome to the API!', version: 'v1' });
});

export default app;
EOF

    else
        # Non-versioned Express setup
        cat >src/index.ts <<EOF
import app from './app';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const PORT = process.env.PORT || 3000;

// Start Express server
const server = app.listen(PORT, () => {
  console.log(\`🚀 Server running on port \${PORT}\`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});
EOF

        # Create app.ts file for Express
        cat >src/app.ts <<EOF
import express, { Request, Response } from 'express';
import cors from 'cors';
import morgan from 'morgan';

const app = express();

// Middleware
app.use(express.json());
app.use(cors());
app.use(morgan('dev'));

// Health check route
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.get('/', (req: Request, res: Response) => {
  res.json({ message: 'Welcome to the API!' });
});

export default app;
EOF
    fi
fi

# Create config file
if [[ "$version_based" == "y" ]]; then
    cat >src/v1/config/index.ts <<EOF
export const PORT = Number(process.env.PORT) || 3000;
export const NODE_ENV = process.env.NODE_ENV || 'development';
EOF
else
    cat >src/config/index.ts <<EOF
export const PORT = Number(process.env.PORT) || 3000;
export const NODE_ENV = process.env.NODE_ENV || 'development';
EOF
fi

# Create .prettierrc and .prettierignore files
cat >.prettierrc <<EOF
{
  "singleQuote": false,
  "bracketSpacing": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "semi": true
}
EOF

cat >.prettierignore <<EOF
/.vscode
/node_modules
./dist

*.yml
*.yaml

*.env
.env
.env.*
EOF

# Create .env and .env.example files
cat >.env.example <<EOF
# Server configuration
PORT=3000
NODE_ENV=development
EOF

if [[ "$database" == "mongoose" ]]; then
    cat >>.env.example <<EOF

# MongoDB configuration
MONGODB_URI=mongodb://localhost:27017/$project_name
EOF
elif [[ "$database" == "drizzle" ]]; then
    cat >>.env.example <<EOF

# PostgreSQL configuration
DATABASE_URL=postgres://postgres:postgres@localhost:5432/$project_name
EOF
fi

# Copy example env to actual env file
cp .env.example .env

# Create .gitignore file
cat >.gitignore <<EOF
# Dependencies
node_modules
.pnp
.pnp.js

# Testing
coverage

# Misc
.DS_Store
*.pem
.eslintcache

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Bun
bun.lockb

# Editors
.vscode
.idea
EOF

# Create README file
cat >README.md <<EOF
# $project_name

A backend API built with Bun and ${framework^}.

### Created By: Mohammad Aman 🚀
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/mohammad-1105)

## Features

- Built with [Bun](https://bun.sh) - A fast all-in-one JavaScript runtime
EOF

if [[ "$framework" == "hono" ]]; then
    echo "- [Hono](https://hono.dev/) - Fast, lightweight web framework" >>README.md
else
    echo "- [Express](https://expressjs.com/) - Fast, unopinionated web framework" >>README.md
fi

if [[ "$version_based" == "y" ]]; then
    echo "- API versioning for better maintainability" >>README.md
fi

if [[ "$database" == "mongoose" ]]; then
    echo "- MongoDB with Mongoose for database operations" >>README.md
elif [[ "$database" == "drizzle" ]]; then
    echo "- PostgreSQL with Drizzle ORM for database operations" >>README.md
fi

cat >>README.md <<EOF

## Prerequisites

- [Bun](https://bun.sh) v1.0.0 or higher
EOF

if [[ "$database" == "mongoose" ]]; then
    echo "- MongoDB server" >>README.md
elif [[ "$database" == "drizzle" ]]; then
    echo "- PostgreSQL database" >>README.md
fi

cat >>README.md <<EOF

## Installation

1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   bun install
   \`\`\`
3. Set up environment variables:
   \`\`\`bash
   cp .env.example .env
   # Then edit .env file with your configuration
   \`\`\`
4. Start the development server:
   \`\`\`bash
   bun dev
   \`\`\`

## Available Scripts

- \`bun dev\`: Start the development server with hot reload
- \`bun start\`: Start the production server
EOF

# Update package.json
# First, extract the current content of package.json
JSON_CONTENT=$(cat package.json)

# Update the module path
JSON_CONTENT=$(echo "$JSON_CONTENT" | sed 's/"module": "index.ts"/"module": "src\/index.ts"/g')

# Update scripts section
JSON_CONTENT=$(echo "$JSON_CONTENT" | sed 's/"scripts": {/"scripts": {\n    "start": "bun run src\/index.ts",\n    "dev": "bun run --watch src\/index.ts",/g')

# Write updated content back to package.json
echo "$JSON_CONTENT" >package.json

# Install dependencies based on framework choice
echo -e "${CYAN}Installing dependencies...${RESET}"
bun add dotenv

if [[ "$framework" == "hono" ]]; then
    bun add hono @hono/zod-validator zod
else
    bun add express cors morgan @types/express @types/cors @types/morgan
fi

# Install database dependencies
if [[ "$database" == "mongoose" ]]; then
    echo -e "${CYAN}Installing MongoDB dependencies...${RESET}"
    bun add mongoose
elif [[ "$database" == "drizzle" ]]; then
    echo -e "${CYAN}Installing PostgreSQL with Drizzle dependencies...${RESET}"
    bun add drizzle-orm
    bun add -d drizzle-kit
fi

echo -e "\n${GREEN}✨ Project '$project_name' created successfully!${RESET}"
echo -e "${CYAN}To get started:${RESET}"
echo -e "  cd $project_name"
echo -e "  bun dev"
echo -e "\n${YELLOW}Happy coding! 🚀${RESET}"

# Open the project in VS Code by asking the user
read -p "$(echo -e "${BLUE}Do you want to open the project in VS Code? (y/n): ${RESET}")" open_in_vscode

if [[ "$open_in_vscode" == "y" ]]; then
    code .
fi
