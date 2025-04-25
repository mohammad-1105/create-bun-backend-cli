# Create Bun Backend CLI

A powerful CLI tool to generate a feature-rich Bun backend project with configurable options.

[![GitHub](https://img.shields.io/badge/GitHub-mohammad--1105-black?style=for-the-badge&logo=github)](https://github.com/mohammad-1105)
[![Bun](https://img.shields.io/badge/Runtime-Bun-black?style=for-the-badge&logo=bun)](https://bun.sh)
[![TypeScript](https://img.shields.io/badge/Language-TypeScript-blue?style=for-the-badge&logo=typescript)](https://www.typescriptlang.org/)

## Features

✅ **Framework Options**: Choose between Hono (lightweight) or Express (feature-rich)  
✅ **Database Support**: MongoDB with Mongoose or PostgreSQL with Drizzle ORM  
✅ **API Versioning**: Optional version-based API structure  
✅ **Project Configuration**: Complete setup with TypeScript, environment variables, and more  
✅ **Best Practices**: Includes health checks, proper error handling, and graceful shutdown  

## Requirements

- [Bun](https://bun.sh) installed on your system
- Bash terminal

## Installation

```bash
# Download the script
curl -o create-bun-backend.sh https://raw.githubusercontent.com/mohammad-1105/create-bun-backend-cli/main/create-bun-backend.sh

# Make it executable
chmod +x create-bun-backend.sh

# Optional: Move to a directory in your PATH
sudo mv create-bun-backend.sh /usr/local/bin/create-bun-backend
```

## Usage

```bash
# Run directly
./create-bun-backend.sh

# Or if moved to PATH
create-bun-backend
```

## Options

During setup, you'll be prompted to configure:

1. **Project Name**: Name of your project directory
2. **Web Framework**: Hono or Express
3. **API Versioning**: Option to structure API with versioning
4. **Database**: MongoDB with Mongoose, PostgreSQL with Drizzle, or None

## Generated Project Structure

```
my-project/
├── src/
│   ├── v1/ (if versioning enabled)
│   │   ├── models/
│   │   ├── controllers/
│   │   ├── routes/
│   │   ├── middlewares/
│   │   ├── db/
│   │   ├── utils/
│   │   ├── config/
│   │   ├── app.ts
│   │   └── constants.ts
│   ├── index.ts
│   └── ...
├── .env
├── .env.example
├── .gitignore
├── .prettierrc
├── .prettierignore
├── package.json
└── README.md
```

## Scripts in Generated Project

- `bun dev` - Start development server with hot reload
- `bun start` - Start production server

## Customizing Templates

You can modify the script to customize the generated templates according to your preferences:

1. Edit the template sections in the script
2. Add additional dependencies or configurations
3. Modify the directory structure

## License

MIT © [Mohammad Aman](https://github.com/mohammad-1105)

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.