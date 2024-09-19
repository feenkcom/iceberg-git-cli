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

{ #category : #comparing }
PureGitBranch >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ self name = anObject name and: [ self commitId = anObject commitId ]
]

{ #category : #accessing }
PureGitBranch >> branchType [
	self subclassResponsibility
]

{ #category : #operations }
PureGitBranch >> checkout [
	self repository checkout: self name
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

{ #category : #comparing }
PureGitBranch >> hash [
	^ self name hash bitXor: self commitId hash
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

{ #category : #accessing }
PureGitBranch >> shortCommitId [
	^ commit isString
		ifTrue: [ commit first: 7 ]
		ifFalse: [ commit shortCommitId ]
]
