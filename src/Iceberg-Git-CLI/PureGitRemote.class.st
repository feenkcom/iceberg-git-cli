"
A git remote is a named reference to git server defined by a URL.

Remote branches exist in a remote.
"
Class {
	#name : #PureGitRemote,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'name',
		'url'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #accessing }
PureGitRemote >> branches [
	^ self repository queries remoteBranches
		select: [ :each | each remoteName = self name ]
]

{ #category : #operations }
PureGitRemote >> fetch [
	self repository operations fetch: { self name }
]

{ #category : #accessing }
PureGitRemote >> gitUrl [
	^ PureGitUrl with: self url
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

{ #category : #operations }
PureGitRemote >> pull [
	self repository operations pull: { self name }
]

{ #category : #operations }
PureGitRemote >> push [
	self repository operations push: { self name }
]

{ #category : #accessing }
PureGitRemote >> url [
	^ url
]

{ #category : #accessing }
PureGitRemote >> url: aString [
	url := aString
]
