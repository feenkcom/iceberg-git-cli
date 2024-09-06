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
PureGitTree >> entries [
	^ entries ifNil: [ entries := self repository treeEntriesFor: self id ]
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
PureGitTree >> entryNamed: name [
	^ self entries detect: [ :each | each name = name ]
]

{ #category : #accessing }
PureGitTree >> entryNamed: name ifAbsent: block [
	^ self entries 
		detect: [ :each | each name = name ]
		ifNone: block
]

{ #category : #testing }
PureGitTree >> hasEntryNamed: name [
	^ self entries anySatisfy: [ :each | each name = name ]
]

{ #category : #accessing }
PureGitTree >> id [
	^ id
]

{ #category : #accessing }
PureGitTree >> id: aString [
	id := aString
]

{ #category : #printing }
PureGitTree >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: self id.
	stream nextPut: $)
]
