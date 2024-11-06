"
I hold all modifications to a specific method in a git repository
"
Class {
	#name : #PureGitMethodVersions,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'method',
		'versions'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #'instance creation' }
PureGitMethodVersions class >> with: aCompiledMethod [
	^ self new
		method: aCompiledMethod;
		yourself
]

{ #category : #private }
PureGitMethodVersions >> computeVersions [
	| packageName organization className selector classPath gitFile snapshots definitions uniqueDefinitions previous |
	packageName := method package name.
	organization := MCOrganizationDefinition categories: {packageName}.
	className := method origin instanceSide name.
	selector := method selector.
	classPath := packageName , '/' , className , self tonelMethodClassExtension.
	gitFile := self repository resolveSrcFilePath: classPath.
	snapshots := gitFile logReverse collect: [ :commit | | snapshot commitDefinitions |
		commitDefinitions := TonelParser parseString: commit contentsByFilesystem.
		commitDefinitions do: [ :definition |
			definition isMethodDefinition ifTrue: [ definition setTimeStamp: commit ] ].
		snapshot := MCSnapshot fromDefinitions: commitDefinitions , { organization }.
		snapshot ].
	definitions := snapshots toArray wait
		flatCollect: [ :snapshot | 
			snapshot definitions
				select: [ :definition | 
					definition isMethodDefinition
						and: [ definition className = className
							and: [ definition selector = selector ] ] ] ].
	uniqueDefinitions := OrderedCollection new.
	definitions do: [ :each | uniqueDefinitions addIfNotPresent: each ].
	previous := nil.
	^ uniqueDefinitions collect: [ :definition | | diff |
		diff := GtDiffBuilder 
			computeDifferencesFrom: (previous ifNil: [ String empty ] ifNotNil: [ previous diffSource ])
			to: definition diffSource 
			using: GtSmaCCDiffSplitter forPharo.
		previous := definition.
		definition -> diff ]
]

{ #category : #private }
PureGitMethodVersions >> findMethodRepository [
	| iceRepository |
	iceRepository := IceRepository registeredRepositoryIncludingPackage: method package.
	iceRepository 
		ifNil: [ ^ NotFound signal: ('Cannot find the git repository {1} belongs to' format: { method }) ].
	^ PureGitCodeRepository on: iceRepository location
]

{ #category : #accessing }
PureGitMethodVersions >> method [
	^ method
]

{ #category : #accessing }
PureGitMethodVersions >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #printing }
PureGitMethodVersions >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(; print: method; nextPut: $)
]

{ #category : #accessing }
PureGitMethodVersions >> repository [
	^ repository ifNil: [ repository := self findMethodRepository ]
]

{ #category : #private }
PureGitMethodVersions >> tonelMethodClassExtension [
	method isExtension ifTrue: [ ^ '.extension.st' ].
	method isFromTrait ifTrue: [ ^ '.trait.st' ].
	^ '.class.st'
]

{ #category : #accessing }
PureGitMethodVersions >> versions [
	^ versions ifNil: [ versions := self computeVersions ]
]

{ #category : #accessing }
PureGitMethodVersions >> versions: aCollection [
	versions := aCollection
]
