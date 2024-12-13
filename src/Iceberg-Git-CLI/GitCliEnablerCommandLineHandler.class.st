"
Usage: enablegitcli [--help] [--save] [ --no-quit ]
	--help                   list this help message
	--save                   save the image after enabling git cli
	--no-quit                if specified, the image continues runing after enabling git cli

Documentation:
A CommandLineHandler that enables the git cli iceberg implementation
and switches over the implementation of all existing repositories.

This has no effect on the on disk git repositories themselves.
A number of validations are run before starting, some assertions might fail.
You need the git command line executable installed, accessible, configured and working.

Running without --save can be considered a dry run.
"
Class {
	#name : #GitCliEnablerCommandLineHandler,
	#superclass : #CommandLineHandler,
	#category : #'Iceberg-Git-CLI-Support'
}

{ #category : #accessing }
GitCliEnablerCommandLineHandler class >> commandName [
	^ 'enablegitcli'
]

{ #category : #accessing }
GitCliEnablerCommandLineHandler class >> description [
	^ 'Enable the git cli iceberg implementation'
]

{ #category : #activation }
GitCliEnablerCommandLineHandler >> activate [
	self activateHelp
		ifTrue: [  ^ self ].

	self enableGitCli.

	(self hasOption: 'save')
		ifTrue: [
			3 timesRepeat: [ Smalltalk garbageCollect ].
			^ Smalltalk
				snapshot: true
				andQuit: (self hasOption: 'no-quit') not ].

	(self hasOption: 'no-quit')
		ifFalse: [ self quit ]
]

{ #category : #actions }
GitCliEnablerCommandLineHandler >> enableGitCli [
	GitCliEnabler new switchAll.
	self stdout
		nextPutAll: 'git cli enabled successfully';
		lf
]
