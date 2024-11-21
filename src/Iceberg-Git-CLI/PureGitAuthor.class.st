"
I model a git author with additional statistics in a specific context
"
Class {
	#name : #PureGitAuthor,
	#superclass : #Object,
	#instVars : [
		'name',
		'numberOfCommits',
		'color'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #accessing }
PureGitAuthor >> color [
	^ color
]

{ #category : #accessing }
PureGitAuthor >> color: aColor [
	color := aColor
]

{ #category : #accessing }
PureGitAuthor >> name [
	^ name
]

{ #category : #accessing }
PureGitAuthor >> name: aString [
	name := aString
]

{ #category : #accessing }
PureGitAuthor >> numberOfCommits [
	^ numberOfCommits
]

{ #category : #accessing }
PureGitAuthor >> numberOfCommits: aCount [
	numberOfCommits := aCount
]

{ #category : #printing }
PureGitAuthor >> printOn: aStream [
	super printOn: aStream.
	name
		ifNotNil: [ aStream
				nextPut: $(;
				nextPutAll: name;
				nextPut: $) ]
]
