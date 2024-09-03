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

{ #category : #accessing }
PureGitTree >> id [
	^ id
]

{ #category : #accessing }
PureGitTree >> id: aString [
	id := aString
]
