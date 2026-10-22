"
Stub repository for examples. It never starts a git process: {{gtMethod:GitCliStubRepository>>#runGitWithArgs:}} answers canned lines after a short delay, so that examples can provoke concurrent calls of {{gtMethod:GitCliCommitStore>>#entries}} deterministically.
"
Class {
	#name : #GitCliStubRepository,
	#superclass : #IceGitCliRepository,
	#instVars : [
		'lsTreeCalls'
	],
	#category : #'Iceberg-Git-CLI'
}

{ #category : #accessing }
GitCliStubRepository >> lsTreeCalls [
	^ lsTreeCalls ifNil: [ 0 ]
]

{ #category : #git }
GitCliStubRepository >> runGitWithArgs: args [
	| tab |
	args first = 'show' ifTrue: [ ^ #('tree123') ].
	lsTreeCalls := self lsTreeCalls + 1.
	(Delay forMilliseconds: 300) wait.
	tab := String with: Character tab.
	^ { '100644 blob abc 3' , tab , 'file.txt' }
]
