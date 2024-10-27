"
I represent a git tree with a list of entries.

My entries are instances of PureGitTreeEntry.

I am one level in a nested tree structure.
"
Class {
	#name : #PureGitTree,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'id',
		'entries'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitTree class >> emptyTreeHash [
	^ '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
]

{ #category : #accessing }
PureGitTree >> entries [
	^ entries ifNil: [ entries := self repository queries treeEntriesFor: self id ]
]

{ #category : #accessing }
PureGitTree >> entries: aCollection [
	entries := aCollection
]

{ #category : #enumerating }
PureGitTree >> entriesDoRecursively: block [
	| parents |
	parents := Array new.
	self entries do: [ :entry |
		entry entriesDoRecursively: block parents: parents ]
]

{ #category : #enumerating }
PureGitTree >> entriesRecursively [
	| collection |
	collection := OrderedCollection new.
	self entriesDoRecursively: [ :entry :parents |
		collection add: (parents -> entry) ].
	^ collection
]

{ #category : #accessing }
PureGitTree >> entryAtPath: path ifAbsent: block [
	| subTree |
	^ path size = 1
		ifTrue: [ self entryNamed: path first ifAbsent: block ]
		ifFalse: [ subTree := self entryNamed: path first ifAbsent: block.
			subTree isTree ifFalse: block.
			subTree := subTree resolve.
			subTree entryAtPath: path allButFirst ifAbsent: block ]
]

{ #category : #accessing }
PureGitTree >> entryNamed: name [
	^ self entries detect: [ :each | each name = name ]
]

{ #category : #accessing }
PureGitTree >> entryNamed: name ifAbsent: block [
	^ self entries 
		detect: [ :each | each name = name ]
		ifNone: block
]

{ #category : #accessing }
PureGitTree >> flatPaths [
	^ self entriesRecursively collect: [ :each |
		($/ join: (each key collect: #name) , { each value name }) , ' ' ,  each value id ]
]

{ #category : #testing }
PureGitTree >> hasEntryNamed: name [
	^ self entries anySatisfy: [ :each | each name = name ]
]

{ #category : #testing }
PureGitTree >> hasResolvedEntries [
	^ entries notNil
]

{ #category : #accessing }
PureGitTree >> id [
	^ id
]

{ #category : #accessing }
PureGitTree >> id: aString [
	id := aString
]

{ #category : #testing }
PureGitTree >> isTree [
	^ true
]

{ #category : #printing }
PureGitTree >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: self id.
	stream nextPut: $)
]

{ #category : #accessing }
PureGitTree >> shortId [
	^ id first: 7
]
