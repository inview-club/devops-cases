# Case №10 - Unusual Build from Source of the xsd Component

- [Case №10 - Unusual Build from Source of the xsd Component]
(#case-10---unusual-build-from-source-of-the-xsd-component)
  - [Authors](#authors)
  - [Goal](#goal)
  - [Stack](#stack)
  - [Checkpoints](#checkpoints)
  - [Result](#result)
  - [Contacts](#contacts)

## Authors

[![Author](https://img.shields.io/badge/cmdrcrm-000000.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/CommanderCRM)

## Goal

Usually, applications or libraries in UNIX-like systems are configured and built using autotools. This is a set of utilities that allows describing the necessary stages using predefined functions and macros. Another cross-platform and more modern option is CMake or similar. You have been asked to automate the build of the xsd code generator, which translates XML into C++, but in the repository you can see: a certain "build" is used. Try to reorganize the build process so that it can be run on CI without interactive dialogs in the terminal.

## Stack

![bash](https://img.shields.io/badge/Bash-000000?logo=gnubash&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=white)
![CMake](https://img.shields.io/badge/CMake-%23008FBA.svg?style=for-the-badge&logo=cmake&logoColor=white)

## Checkpoints

### Basic

1. **Clone the utility repository:**
    - The source code is available at this [link](https://github.com/codesynthesis-com/xsd). We are interested in the tag `4.0.0` - do a `git checkout`.
2. **Install the necessary packages for standard C++ application builds:**
    - The basic set is the meta-package `build-essential`. For distributions without `apt`, you can install the components `make`, `autotools`, `gcc`, `g++` individually or use meta-packages if available.
3. **Build xsd in the variant provided by the authors:**
    - While in the root of the repository, execute the command `make` in the terminal.
    - If any build dependencies are missing, you can get an archive with the source code of the utility and all dependencies [here](https://codesynthesis.com/download/xsd/4.0/).
4. **Enable automatic building of xsd on CI:**
    - Try to eliminate the need to input answers to questions in the terminal. You can use standard bash shell tools or modify the files used during the build (the `makefile` contains indications of where in the repository certain instructions "refer" to when needed).

### Advanced

1. **Install CMake:**
    - Typically, `cmake` is available as a package in any Linux distribution and is named exactly that. For other OSes, `brew` (macOS) or `winget` \ `choco` (Windows) are used if necessary. The source code and binary files are available on the [website](https://cmake.org/). It's better to install the 3.31 major version, as version 4 breaks compatibility with many projects due to policy changes.
2. **Migrate the xsd build to CMake:**
    - The standard replacement for finding external dependencies in `CMake` is the `FetchContent` and/or `ExternalProject` functions. Optionally, package managers like `Conan` can be used. This build system has good [documentation](https://cmake.org/cmake/help/v3.31/).

## Result

The `xsd` build can be started either via a `.sh` script or via `make` (in the advanced version - `cmake`). The process requires no action from the user other than calling one or two commands (configure+build separately or individually in the case of `cmake`).

## Contacts

Need help? Write to [our Telegram chat](https://t.me/+nSELCyIX8ltlNjU6)!
