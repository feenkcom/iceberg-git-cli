"
I represent a specific file in a repository, defined by a relative path string.
I hold/cache my file status in the repository.
"
Class {
	#name : #PureGitFile,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'path',
		'status'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitFile >> analyze [
	^ PureGitExtendedFileAnalysis new
		file: self;
		analyze
]

{ #category : #accessing }
PureGitFile >> basename [
	^ ($/ split: path) last
]

{ #category : #accessing }
PureGitFile >> blame [
	^ self repository queries blame: self path
]

{ #category : #accessing }
PureGitFile >> children [
	^ #()
]

{ #category : #accessing }
PureGitFile >> creationTime [
	^ self fileReference creationTime
]

{ #category : #operations }
PureGitFile >> delete [
	self fileReference ensureDelete.
	"should we also delete empty parent directories as they do not exist in git ?"
	self repository announceRepositoryModified
]

{ #category : #accessing }
PureGitFile >> fileReference [
	^ self repository location / self path
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
	^ self status statusInWorkTree = #modified
]

{ #category : #testing }
PureGitFile >> isStaged [
	^ #(added modified removed renamed) includes: self status statusInIndex
]

{ #category : #testing }
PureGitFile >> isTracked [
	^ self status statusInIndex ~= #unknown
]

{ #category : #accessing }
PureGitFile >> log [
	^ (self repository queries log: { 'HEAD' . '--' . self path })
		collect: [ :each |
			PureGitFileCommit new
				copyFrom: each;
				path: self path;
				yourself ]
]

{ #category : #accessing }
PureGitFile >> logPatch [
	| commitDiffPairs |
	commitDiffPairs := self repository queries 
		logPatch: { '--follow' . 'HEAD' . '--' . self path}.
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
	self repository operations restore: self path.
	self resetStatus
]

{ #category : #accessing }
PureGitFile >> size [
	^ self fileReference size
]

{ #category : #operations }
PureGitFile >> stage [
	self repository operations stage: self path.
	self resetStatus
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
	self repository operations unstage: self path.
	self resetStatus
]
