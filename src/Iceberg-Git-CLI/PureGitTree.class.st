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
PureGitTree >> id [
	^ id
]

{ #category : #accessing }
PureGitTree >> id: aString [
	id := aString
]
