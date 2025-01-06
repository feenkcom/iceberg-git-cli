## Iceberg-Git-CLI

This is an alternative Iceberg git CLI implementation replacing the use of Libgit2 FFI with external process invocations of the git CLI executable.

## Documentation

- [What is the rationale for a git CLI implementation ?](doc/why-git-cli.md)
- [What are some new user level features when using git CLI ?](doc/git-cli-features.md)

## Installation

```st
Metacello new
  repository: 'github://feenkcom/iceberg-git-cli:main/src';
  baseline: 'IcebergGitCli';
  load
```

