"
I model a Pharo Smalltalk code package in a repository.

I track loaded commits.
"
Class {
	#name : #PureGitPackage,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'name'
	],
	#classVars : [
		'LoadedCommits',
		'SharedAnnouncer'
	],
	#category : #'Iceberg-Git-CLI-Pure-Code'
}

{ #category : #accessing }
PureGitPackage class >> announceChange [
	self announcer announce: Announcement new
]

{ #category : #accessing }
PureGitPackage class >> announcer [
	^ SharedAnnouncer ifNil: [ SharedAnnouncer := Announcer new ]
]

{ #category : #accessing }
PureGitPackage class >> clearLoadedCommitFor: packageName [
	self loadedCommits removeKey: packageName.
	self announceChange
]

{ #category : #accessing }
PureGitPackage class >> historyRecordLoadedCommitFor: packageName [
	^ (GtGitRepositoryRegistryHistory instance repositoryIncludingPackage: packageName)
		ifNotNil: [ :record | record headCommitId ]
]

{ #category : #accessing }
PureGitPackage class >> icebergLoadedCommitFor: packageName [
	^ (IceRepository registry detect: [ :each | each includesPackageNamed: packageName ] ifNone: [ nil ])
		ifNotNil: [ :repository | repository head commit id ]
]

{ #category : #accessing }
PureGitPackage class >> loadedCommitFor: packageName [
	self loadedCommits at: packageName ifPresent: [ :commitId | ^ commitId ].

	(self icebergLoadedCommitFor: packageName)
		ifNotNil: [ :commitId | ^ self setLoadedCommitFor: packageName to: commitId ].

	(self historyRecordLoadedCommitFor: packageName)
		ifNotNil: [ :commitId | ^ self setLoadedCommitFor: packageName to: commitId ].

	^ nil
]

{ #category : #accessing }
PureGitPackage class >> loadedCommits [
	^ LoadedCommits ifNil: [ LoadedCommits := Dictionary new ]
]

{ #category : #accessing }
PureGitPackage class >> setLoadedCommitFor: packageName to: commitId [
	self loadedCommits at: packageName put: commitId.
	self announceChange
]

{ #category : #operations }
PureGitPackage >> applyIncomingChanges [
	| loader |
	loader := MCPackageLoader new.
	self incomingChanges applyTo: loader.
	loader load.
	self setLoadedCommit.
	self repository announceRepositoryModified
]

{ #category : #private }
PureGitPackage >> handlePackageModified: aPureGitPackageModified [
	self name = aPureGitPackageModified name
		ifTrue: [ self repository announceRepositoryModified ]
]

{ #category : #operations }
PureGitPackage >> incomingChanges [
	^ IceGitCliPlatform current executor
		repository: self repository;
		log: #incomingChanges 
			do: [ self reader version changes ]
]

{ #category : #initialization }
PureGitPackage >> initialize [
	super initialize.
	self subscribeToSystemAnnouncements
]

{ #category : #testing }
PureGitPackage >> isLoaded [
	^ RPackageOrganizer default includesPackageNamed: self name
]

{ #category : #testing }
PureGitPackage >> isUpToDate [
	^ self repository head id = self loadedCommitId
]

{ #category : #operations }
PureGitPackage >> load [
	self reader snapshot install.
	self setLoadedCommit.
	self repository announceRepositoryModified
]

{ #category : #accessing }
PureGitPackage >> loadedCommit [
	^ self loadedCommitId
		ifNotNil: [ :commitId | self repository queries resolveCommit: commitId ]
]

{ #category : #accessing }
PureGitPackage >> loadedCommitId [
	^ self class loadedCommitFor: self name	
]

{ #category : #accessing }
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
	^ IceGitCliPlatform current executor
		repository: self repository;
		log: #outgoingChanges
			do: [ self mcPackage snapshot patchRelativeToBase: self reader snapshot ]
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

{ #category : #private }
PureGitPackage >> reader [
	^ TonelReader on: self srcDirectory fileName: self name
]

{ #category : #operations }
PureGitPackage >> save [
	self writer writeVersion: self mcPackage.
	self repository announceRepositoryModified
]

{ #category : #operations }
PureGitPackage >> setLoadedCommit [
	self class
		setLoadedCommitFor: self name 
		to: self repository head id
]

{ #category : #accessing }
PureGitPackage >> srcDirectory [
	^ self repository srcDirectory
]

{ #category : #private }
PureGitPackage >> subscribeToSystemAnnouncements [
	PureGitSystemListener current announcer weak
		when: PureGitPackageModified
		send: #handlePackageModified:
		to: self
]

{ #category : #private }
PureGitPackage >> writer [
	^ TonelWriter on: self srcDirectory
]
