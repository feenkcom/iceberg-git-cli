Class {
	#name : #GtIceRepositoryCreator,
	#superclass : #Object,
	#instVars : [
		'location',
		'remote',
		'url',
		'subdirectory',
		'repository',
		'isBareRepository',
		'ensureProjectFile',
		'branchName'
	],
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #accessing }
GtIceRepositoryCreator class >> defaultSubdirectory [
	^ ''
]

{ #category : #public }
GtIceRepositoryCreator class >> fromUrl: aUrl to: aFileReference [
	^ self new
		remote: (IceGitRemote url: aUrl);
		location: aFileReference;
		createRepository
]

{ #category : #private }
GtIceRepositoryCreator class >> isGitRoot: aReference [
	^ aReference isDirectory
		and: [ (aReference directoriesMatching: '.git') notEmpty
				and: [ (aReference / '.git' / 'config') exists ] ]
]

{ #category : #public }
GtIceRepositoryCreator class >> on: aFileReference [
	^ self new
		location: aFileReference;
		createRepository
]

{ #category : #accessing }
GtIceRepositoryCreator >> addLocalRepository [
	self locationToUse exists 
		ifFalse: [ DirectoryDoesNotExist signalWith: self locationToUse fullPath ].
	repository := IceGitCliRepository on: self locationToUse.

	branchName ifNotNil: [ repository switchToCommitishNamed: branchName ].
	repository pluginManager repositoryWillBeCreated: repository.
	
	self doEnsureProject.
	repository workingCopy initializePackagesFromRepository.
	
	repository pluginManager repositoryWasCreated: repository.
	^ repository
]

{ #category : #private }
GtIceRepositoryCreator >> addProjectFileTo: aRepository [
	
	| newProject |
	newProject := IceBasicProject onRepository: aRepository.
	newProject sourceDirectory: self subdirectory.
	aRepository workingCopy basicSetProject: newProject.
]

{ #category : #private }
GtIceRepositoryCreator >> addPropertiesFileTo: aRepository [
	aRepository properties fileFormat: self formatToUse
]

{ #category : #accessing }
GtIceRepositoryCreator >> cloneRepository [
	location := self locationToUse.
	self executeGitClone.
	repository location: location.

	branchName ifNotNil: [ repository switchToCommitishNamed: branchName ].
	repository pluginManager repositoryWillBeCreated: repository.

	self doEnsureProject.
	repository workingCopy initializePackagesFromRepository.

	repository pluginManager repositoryWasCreated: repository.
	^ repository
]

{ #category : #accessing }
GtIceRepositoryCreator >> commitishName: aName [
	branchName := aName
]

{ #category : #actions }
GtIceRepositoryCreator >> createNewRepositoryNamed: aString [
	| locationToUse |
	self validate.
	locationToUse := self locationToUse.
	(locationToUse exists and: [ locationToUse hasChildren ])
		ifTrue: [ IceError signal: ('{1} is not empty.' format: {locationToUse fullName}) ].
	locationToUse ensureCreateDirectory.
	self subdirectory
		ifNotEmpty: [ (locationToUse resolve: self subdirectory) ensureCreateDirectory ].	
	repository := IceGitCliRepository new
		name: aString;
		location: locationToUse;
		initBare: isBareRepository;
		yourself.
	self addProjectFileTo: repository.
	self addPropertiesFileTo: repository.
	repository workingCopy refreshProject.
	^ repository
]

{ #category : #accessing }
GtIceRepositoryCreator >> createRepository [
	^ [
		self validate.
		self isCloning
			ifTrue: [ self cloneRepository ]
			ifFalse: [ self addLocalRepository ] ]
	on: IceDuplicatedRepository 
	do: [ :e | 
		"This is a HACK to allow process to recover from here"
		e signal ]
]

{ #category : #'private - accessing' }
GtIceRepositoryCreator >> defaultLocation [
	| remoteToUse |
	remoteToUse := self remoteToUse.
	^ IceLibgitRepository repositoriesLocation 
		/ remoteToUse organizer 
		/ remoteToUse projectName
]

{ #category : #accessing }
GtIceRepositoryCreator >> doEnsureProject [
	ensureProjectFile ifFalse: [ ^ self ].
	repository project isUnborn ifFalse: [ ^ self ].

	repository workingCopy
		project: (IceBasicProject onRepository: repository withSourceDirectory: self subdirectory).
	repository workingCopy refreshRepositoryProperties.	"If the properties file has no format, set it the default legacy format"
	repository workingCopy properties properties
		at: #format
		ifAbsent: [ repository workingCopy properties
				fileFormat: (TIceRepositoryWriter users
						detect: #isLegacyDefault
						ifNone: [ Smalltalk at: #IceLibgitFiletreeWriter ]) ].

	repository workingCopy refreshPackages
]

{ #category : #accessing }
GtIceRepositoryCreator >> ensureProjectFile [
	ensureProjectFile := true
]

{ #category : #accessing }
GtIceRepositoryCreator >> executeGitClone [
	location exists ifTrue: [ IceCloneLocationAlreadyExists signalFor: location ].

	location ensureCreateDirectory.
	url := self remoteToUse url.
	repository := IceGitCliRepository on: location.
	repository clone: url
]

{ #category : #accessing }
GtIceRepositoryCreator >> formatToUse [ 
	^ IceLibgitRepository defaultFileFormat
]

{ #category : #initialization }
GtIceRepositoryCreator >> initialize [
	super initialize.
	ensureProjectFile := false.
	isBareRepository := false
]

{ #category : #accessing }
GtIceRepositoryCreator >> isCloning [
	^ self remoteToUse notNil
]

{ #category : #private }
GtIceRepositoryCreator >> location [
	^location
]

{ #category : #accessing }
GtIceRepositoryCreator >> location: aFileRef [
	location := aFileRef 
]

{ #category : #'private - accessing' }
GtIceRepositoryCreator >> locationToUse [
	^ self location ifNil: [ self defaultLocation ]
]

{ #category : #accessing }
GtIceRepositoryCreator >> remote [
	^remote
]

{ #category : #accessing }
GtIceRepositoryCreator >> remote: aString [
	remote := aString
]

{ #category : #'private - accessing' }
GtIceRepositoryCreator >> remoteToUse [
	self remote ifNotNil: [ ^ self remote ].
	self url ifNotNil: [ ^ IceGitRemote url: self url ].
	^ nil
]

{ #category : #accessing }
GtIceRepositoryCreator >> subdirectory [
	^ subdirectory ifNil: [ self class defaultSubdirectory ]
]

{ #category : #accessing }
GtIceRepositoryCreator >> subdirectory: aString [
	subdirectory := aString
]

{ #category : #accessing }
GtIceRepositoryCreator >> url [
	^url
]

{ #category : #accessing }
GtIceRepositoryCreator >> url: anObject [
	url := anObject
]

{ #category : #private }
GtIceRepositoryCreator >> validate [
	self validateLocation.
	self validateAlreadyPresentAndNotGit.
	self validateNotDuplicated
]

{ #category : #private }
GtIceRepositoryCreator >> validateAlreadyPresentAndNotGit [
	"Validate if I will add a local repository (url isNil and location isNotNil)... 
	 testing the local directory actually exists"	
	(self remoteToUse isNil
		and: [ self location notNil
		and: [ self location exists
		and: [ (self class isGitRoot: self location) not ] ] ])
		ifTrue: [ 
			IceError signal: ('"{1}" is not a git directory' format: {self location fullName}) ]
]

{ #category : #private }
GtIceRepositoryCreator >> validateLocation [
	(self location isNil 
		and: [ self remoteToUse isNil ])
		ifTrue: [ IceError signal: 'No location/url or remote defined.' ]
]

{ #category : #private }
GtIceRepositoryCreator >> validateNotDuplicated [
]
