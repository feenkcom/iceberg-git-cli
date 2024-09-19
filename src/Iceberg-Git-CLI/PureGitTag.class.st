"
I represent a git tag, a name attached to a specific commit.
"
Class {
	#name : #PureGitTag,
	#superclass : #PureGitCommitish,
	#instVars : [
		'name',
		'commit'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #comparing }
PureGitTag >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ self name = anObject name and: [ self commitId = anObject commitId ]
]

{ #category : #accessing }
PureGitTag >> commit [
	^ commit isString
		ifTrue: [ commit := repository resolveCommit: commit ]
		ifFalse: [ commit ]
]

{ #category : #accessing }
PureGitTag >> commit: aPureGitCommit [
	commit := aPureGitCommit
]

{ #category : #accessing }
PureGitTag >> commitId [
	^ commit isString
		ifTrue: [ commit ]
		ifFalse: [ commit id ]
]

{ #category : #comparing }
PureGitTag >> hash [
	^ self name hash bitXor: self commitId hash
]

{ #category : #accessing }
PureGitTag >> name [
	^ name
]

{ #category : #accessing }
PureGitTag >> name: aString [
	name := aString
]

{ #category : #printing }
PureGitTag >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	name ifNotNil: [ stream nextPutAll: name ].
	stream nextPut: $)
]

{ #category : #accessing }
PureGitTag >> shortCommitId [
	^ commit isString
		ifTrue: [ commit first: 7 ]
		ifFalse: [ commit shortCommitId ]
]
