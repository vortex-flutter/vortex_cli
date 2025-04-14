# Vortex CLI

Official CLI tool for the Vortex framework - a Nuxt.js inspired framework for building Flutter applications with ease.

Vortex CLI helps you scaffold and manage your Vortex applications with simple commands for creating projects, pages, components, and more.

## Features

- **Project Scaffolding**: Create new Vortex projects with proper folder structure
- **Page Generation**: Generate stateless or stateful pages with proper routing
- **Component Management**: Create and register reusable components
- **Automatic Route Registration**: Automatically register and manage routes
- **Dependency Management**: Easily add or remove dependencies

## Installation

### From pub.dev

```bash
dart pub global activate vortex_cli
```

## Project Structure
```
<project_name>/
├── lib/            # Main application code
├── test/           # Unit and widget tests
├── pubspec.yaml    # Project dependencies and configuration
└── vortex.config.js # Vortex configuration file
```

## Project Scaffolding
To create a new Vortex project, use the following command:
```bash
vortex create <project_name>
```

## Installing Packages
To install a package, use the following command:
```bash
vortex add <package_name>
```

## Removing Packages
To remove a package, use the following command:
```bash
vortex remove <package_name>
```

## Updating Packages
To update a package, use the following command:
```bash
vortex update <package_name>
```

## Page Generation
To generate a new page, use the following command:
```bash
vortex page <page_name>
```
### Options
- `--stateless`: Generate a stateless page
- `--stateful`: Generate a stateful page
- `--dir`: Specify the directory to create the page in (default is `lib/pages`)
- `--file`: Specify the file name to create the page in (default is `<page_name>.dart`)

## Component Management
To create a new component, use the following command:
```bash
vortex component <component_name>
```

## Runner
To generate components and pages, use the following command: Vortex application, use the following command:
```bash
vortex runner
```

### Options
- `--pages-dir`: Specify the directory to create the pages in (default is `lib/pages`)
- `--verbose`: Enable verbose output

## Contributing
Contributions are welcome! Please open an issue or submit a pull request.

## Credits
This project was inspired by the Nuxt.js framework.

## Support
If you encounter any issues, please open an issue on GitHub.

## Authors
- [Kumar Yash](https://github.com/CodeSyncr)

## License
This project is licensed under the MIT License. 
