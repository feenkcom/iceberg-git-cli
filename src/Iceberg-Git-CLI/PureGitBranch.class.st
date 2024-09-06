"
I am a git branch, a name tracking commits.
"
Class {
	#name : #PureGitBranch,
	#superclass : #PureGitCommitish,
	#instVars : [
		'name',
		'commit'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitBranch >> branchType [
	self subclassResponsibility
]

{ #category : #accessing }
PureGitBranch >> commit [
	^ commit isString
		ifTrue: [ commit := repository resolveCommit: commit ]
		ifFalse: [ commit ]
]

{ #category : #accessing }
PureGitBranch >> commit: anObject [
	commit := anObject
]

{ #category : #accessing }
PureGitBranch >> commitId [
	^ commit isString
		ifTrue: [ commit ]
		ifFalse: [ commit id ]
]

{ #category : #accessing }
PureGitBranch >> name [
	^ name
]

{ #category : #accessing }
PureGitBranch >> name: anObject [
	name := anObject
]

{ #category : #printing }
PureGitBranch >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	name ifNotNil: [ stream nextPutAll: name ].
	stream nextPut: $)
]
