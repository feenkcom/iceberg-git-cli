"
A git remote is a named reference to git server defined by a URL.
"
Class {
	#name : #PureGitRemote,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'name',
		'url'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitRemote >> branches [
	^ self repository queries remoteBranches
		select: [ :each | each remoteName = self name ]
]

{ #category : #accessing }
PureGitRemote >> name [
	^ name
]

{ #category : #accessing }
PureGitRemote >> name: aString [
	name := aString
]

{ #category : #printing }
PureGitRemote >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; print: name; nextPut: $)
]

{ #category : #accessing }
PureGitRemote >> url [
	^ url
]

{ #category : #accessing }
PureGitRemote >> url: aString [
	url := aString
]
