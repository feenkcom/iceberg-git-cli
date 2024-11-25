"
I represent a specific file in a repository, defined by a relative path string.
I hold/cache my file status in the repository.
"
Class {
	#name : #PureGitFile,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'path',
		'status',
		'authors'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #accessing }
PureGitFile >> analyze [
	^ PureGitTrackedFile new
		file: self;
		analyze
]

{ #category : #accessing }
PureGitFile >> authors [
	^ authors ifNil: [ authors := self computeAuthors ]
]

{ #category : #accessing }
PureGitFile >> basename [
	^ ($/ split: path) last
]

{ #category : #accessing }
PureGitFile >> blame [
	^ self repository queries blame: self path
]

{ #category : #testing }
PureGitFile >> canBeRestored [
	^ self isTracked and: [ self isModifiedInWorkTree ]
]

{ #category : #testing }
PureGitFile >> canBeStaged [
	^ self isTracked not or: [ self isModifiedInWorkTree ]
]

{ #category : #accessing }
PureGitFile >> children [
	^ #()
]

{ #category : #accessing }
PureGitFile >> colorForAuthor: author [
	^ self authors
		at: author
		ifPresent: [ :gitAuthor | gitAuthor color ]
		ifAbsent: [ Color veryLightGray ]
]

{ #category : #private }
PureGitFile >> computeAuthors [
	| dictionary colors lightColors strongColors |
	dictionary := OrderedDictionary new.
	lightColors := BrGlamorousColors distinctTenLightColors , { Color veryLightGray }.
	strongColors := BrGlamorousColors distinctTenStrongColors , { Color gray }.
	colors := BrExplicitIdentityNormalizer new
				colors: (1 to: 10);
				defaultColor: 11.
	(self log toArray wait collect: #author) asBag sortedCounts
		do: [ :association | 
			| author colorIndex |
			(author := PureGitAuthor new)
				name: association value;
				numberOfCommits: association key.
			colorIndex := colors value: author name.
			author color: (lightColors at: colorIndex).
			author contrastColor: (strongColors at: colorIndex).
			dictionary at: author name put: author ].
	^ dictionary
]

{ #category : #accessing }
PureGitFile >> contents [
	^ self fileReference contents
]

{ #category : #accessing }
PureGitFile >> creationTime [
	^ self fileReference creationTime
]

{ #category : #operations }
PureGitFile >> delete [
	self fileReference ensureDelete.
	"should we also delete empty parent directories as they do not exist in git ?"
	self repository announceRepositoryModified.
	^ true
]

{ #category : #testing }
PureGitFile >> exists [
	^ self fileReference exists
]

{ #category : #accessing }
PureGitFile >> fileReference [
	^ self repository location / self path
]

{ #category : #testing }
PureGitFile >> isClean [
	^ self status isClean
]

{ #category : #testing }
PureGitFile >> isDirectory [
	^ false
]

{ #category : #testing }
PureGitFile >> isFile [
	^ true
]

{ #category : #testing }
PureGitFile >> isModifiedInWorkTree [
	^ self status isModifiedInWorkTree
]

{ #category : #testing }
PureGitFile >> isStaged [
	^ self status isStaged
]

{ #category : #testing }
PureGitFile >> isTracked [
	^ self status isTracked
]

{ #category : #accessing }
PureGitFile >> log [
	| commits |
	commits := self repository queries
			log: { '--first-parent' . 'HEAD' . '--' . self path }.
	^ commits collect: [ :each | 
			PureGitFileCommit new
				copyFrom: each;
				path: self path;
				yourself ]
]

{ #category : #accessing }
PureGitFile >> logPatch [
	| commitDiffPairs |
	commitDiffPairs := self repository queries 
		logPatch: { '--first-parent' . '--unified=0' . 'HEAD' . '--' . self path}.
	^ commitDiffPairs collect: [ :commitDiffPair |
		| fileCommit |
		(fileCommit := PureGitFileCommit new)
			copyFrom: commitDiffPair first;
			path: self path.
		PureGitExtendedFileCommit new
			commit: fileCommit;
			changesToParent: commitDiffPair second firstDiff;
			yourself ]
]

{ #category : #accessing }
PureGitFile >> logPatchReverse [
	| commitDiffPairs |
	commitDiffPairs := self repository queries 
		logPatch: { '--first-parent' . '--reverse' . '--unified=0' . 'HEAD' . '--' . self path}.
	^ commitDiffPairs collect: [ :commitDiffPair |
		| fileCommit |
		(fileCommit := PureGitFileCommit new)
			copyFrom: commitDiffPair first;
			path: self path.
		PureGitExtendedFileCommit new
			commit: fileCommit;
			changesToParent: commitDiffPair second firstDiff;
			yourself ]
]

{ #category : #accessing }
PureGitFile >> logReverse [
	| commits |
	commits := self repository queries
			log: { '--first-parent' . '--reverse' . 'HEAD' . '--' . self path }.
	^ commits collect: [ :each | 
			PureGitFileCommit new
				copyFrom: each;
				path: self path;
				yourself ]
]

{ #category : #accessing }
PureGitFile >> parent [
	^ self repository resolveFileReference: self fileReference parent
]

{ #category : #accessing }
PureGitFile >> path [
	^ path
]

{ #category : #accessing }
PureGitFile >> path: aPathString [
	path := aPathString
]

{ #category : #printing }
PureGitFile >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; nextPutAll: self path; nextPut: $)
]

{ #category : #private }
PureGitFile >> resetStatus [
	status := nil
]

{ #category : #operations }
PureGitFile >> restore [
	^ (self repository operations async restore: self path)
		then: [ :result | 
			self resetStatus.
			result ]
]

{ #category : #accessing }
PureGitFile >> size [
	^ self fileReference size
]

{ #category : #operations }
PureGitFile >> stage [
	^ (self repository operations async stage: self path)
		then: [ :result | 
			self resetStatus.
			result ]
]

{ #category : #accessing }
PureGitFile >> status [
	^ status ifNil: [ 
		status := (self repository queries statusFor: self path)
			ifEmpty: [ 
				(PureGitFileStatus inRepository: self repository) 
					path: path;
					beUnmodified ]
			ifNotEmpty: [ :result | result first ] ]
]

{ #category : #operations }
PureGitFile >> unstage [
	^ (self repository operations async unstage: self path)
		then: [ :result | 
			self resetStatus.
			result ]
]

{ #category : #private }
PureGitFile >> validateIncrementalHistoryContentsReconstruction [
	| commitHistory previousContents |
	commitHistory := self logPatchReverse toArray wait.
	previousContents := String empty.
	commitHistory do: [ :extendedFileCommit |
		| newContents expectedContents |
		newContents := extendedFileCommit changesToParent applyTo: previousContents.
		expectedContents := String streamContents: [ :out |
			extendedFileCommit commit contents 
				linesDo: [ :line | out nextPutAll: line; cr ] ].
		self assert: newContents equals: expectedContents.
		previousContents := newContents ]
]
