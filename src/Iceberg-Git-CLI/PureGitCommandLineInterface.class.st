"
I use the git executable to run queries and operations on a repository
"
Class {
	#name : #PureGitCommandLineInterface,
	#superclass : #PureGitRepositoryObject,
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #private }
PureGitCommandLineInterface >> executor [
	^ (IceGitCliPlatform current executor)
		workingDirectory: self repository ensureLocation;
		yourself
]

{ #category : #private }
PureGitCommandLineInterface >> runGitWithArgs: args [
	"Run CLI git with the passed arguments and return the lines from standard output.
	Wait for the git command to complete. Signal an error when not successful."

	| operation |
	operation := thisContext sender method selector.
	^ self executor runGitWithArgs: args for: operation
]

{ #category : #private }
PureGitCommandLineInterface >> runGitWithArgsAsync: args [
	"Run CLI git with the passed arguments and return the lines from standard output as an asynchroneous stream..
	Do not wait for the git command to complete. Signal an error when not successful."

	| operation |
	operation := thisContext sender method selector.
	^ self executor runGitWithArgsAsync: args for: operation
]
