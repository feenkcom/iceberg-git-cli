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
PureGitTree >> id [
	^ id
]

{ #category : #accessing }
PureGitTree >> id: aString [
	id := aString
]
