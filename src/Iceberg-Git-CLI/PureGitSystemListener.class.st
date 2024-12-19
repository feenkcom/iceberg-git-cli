"
I listen to SystemAnnoucer events related to code change announcements and translate them to PureGitPackageModified announcements
"
Class {
	#name : #PureGitSystemListener,
	#superclass : #Object,
	#instVars : [
		'announcer'
	],
	#classVars : [
		'current'
	],
	#category : #'Iceberg-Git-CLI-Pure-Code'
}

{ #category : #'instance  creation' }
PureGitSystemListener class >> current [
	<gtExample>
	^ current ifNil: [ current := self new ]
]

{ #category : #'instance  creation' }
PureGitSystemListener class >> reset [
	current := nil
]

{ #category : #private }
PureGitSystemListener >> announcePackageModified: packageName [
	packageName isEmptyOrNil
		ifFalse: [ self announcer announce: (PureGitPackageModified new name: packageName) ]
]

{ #category : #accessing }
PureGitSystemListener >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #private }
PureGitSystemListener >> handleClassChange: aClassAnnouncement [
	aClassAnnouncement packagesAffected do: [ :each |
		self announcePackageModified: each name ]
]

{ #category : #private }
PureGitSystemListener >> handleMethodChange: aMethodAnnouncement [
	aMethodAnnouncement packagesAffected do: [ :each |
		self announcePackageModified: each name ]
]

{ #category : #private }
PureGitSystemListener >> handlePackageChange: aClassTagAnnouncement [
	aClassTagAnnouncement packagesAffected do: [ :each |
		self announcePackageModified: each name ]
]

{ #category : #private }
PureGitSystemListener >> handleVersionLoaded: anMCVersionLoadedStopped [
	self announcePackageModified: anMCVersionLoadedStopped label
]

{ #category : #initialization }
PureGitSystemListener >> initialize [
	super initialize.
	self registerSystemAnnouncements
]

{ #category : #convenience }
PureGitSystemListener >> logToTranscript [
	self announcer
		when: PureGitPackageModified
		send: #crShow:
		to: Transcript
]

{ #category : #private }
PureGitSystemListener >> registerSystemAnnouncements [
	SystemAnnouncer uniqueInstance weak
		when: ClassAnnouncement
			send: #handleClassChange:
			to: self;
		when: MethodAnnouncement
			send: #handleMethodChange:
			to: self;
		when: ClassTagAnnouncement
			send: #handlePackageChange:
			to: self;
		when: MCVersionLoaderStopped
			send: #handleVersionLoaded:
			to: self
]

{ #category : #convenience }
PureGitSystemListener >> stopLoggingToTranscript [
	self announcer unsubscribe: Transcript
]

{ #category : #private }
PureGitSystemListener >> unregisterSystemAnnouncements [
	SystemAnnouncer uniqueInstance unsubscribe: self
]
