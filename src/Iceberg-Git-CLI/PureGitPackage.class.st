"
I model a Pharo Smalltalk code package in a repository
"
Class {
	#name : #PureGitPackage,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'name'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #operations }
PureGitPackage >> incomingChanges [
	^ self reader version changes
]

{ #category : #testing }
PureGitPackage >> isLoaded [
	^ RPackageOrganizer default includesPackageNamed: self name
]

{ #category : #operations }
PureGitPackage >> load [
	self reader snapshot install.
	self repository announceRepositoryModified
]

{ #category : #operations }
PureGitPackage >> mcPackage [
	^ MCPackage named: self name
]

{ #category : #accessing }
PureGitPackage >> name [
	^ name
]

{ #category : #initialization }
PureGitPackage >> name: aString [
	name := aString
]

{ #category : #operations }
PureGitPackage >> outgoingChanges [
	^ self mcPackage snapshot 
		patchRelativeToBase: self reader snapshot
]

{ #category : #printing }
PureGitPackage >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; nextPutAll: self name; nextPut: $)
]

{ #category : #accessing }
PureGitPackage >> rPackage [
	^ RPackageOrganizer default packageNamed:  self name
]

{ #category : #operations }
PureGitPackage >> reader [
	^ TonelReader on: self srcDirectory fileName: self name
]

{ #category : #operations }
PureGitPackage >> save [
	self writer writeVersion: self mcPackage.
	self repository announceRepositoryModified
]

{ #category : #accessing }
PureGitPackage >> srcDirectory [
	^ self repository srcDirectory
]

{ #category : #operations }
PureGitPackage >> writer [
	^ TonelWriter on: self srcDirectory
]
