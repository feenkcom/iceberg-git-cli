Class {
	#name : #GitCliCommitStore,
	#superclass : #FileSystemStore,
	#instVars : [
		'commit',
		'entries',
		'gitFileReader'
	],
	#classVars : [
		'Registry'
	],
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #'instance creation' }
GitCliCommitStore class >> on: aCommit [
	^ self new
		commit: aCommit;
		yourself
]

{ #category : #finalization }
GitCliCommitStore class >> register: anObject [
	^self registry add: anObject
]

{ #category : #accessing }
GitCliCommitStore class >> registry [
	^Registry ifNil: [  Registry := FinalizationRegistry new]
]

{ #category : #accessing }
GitCliCommitStore >> basenameFromEntry: aNode [
	^ aNode path
]

{ #category : #accessing }
GitCliCommitStore >> basicCreationTimeOf: anEntry [ 
	^ commit datetime
]

{ #category : #accessing }
GitCliCommitStore >> basicEntry: directoryEntry path: aPath nodesDo: aBlock [
	| lines |
	lines := commit repository runGitWithArgs: {
		'ls-tree'.
		'--format=%(objectmode) %(objecttype) %(objectname) %(objectsize)%x09%(path)'.
		directoryEntry id }.
	lines do: [ :each | aBlock value: (GitCliFileEntry fromLine: each) ]
]

{ #category : #accessing }
GitCliCommitStore >> basicIsDirectory: aNode [
	^ aNode type = 'tree'
]

{ #category : #accessing }
GitCliCommitStore >> basicIsFile: aNode [
	^ aNode type = 'blob'
]

{ #category : #accessing }
GitCliCommitStore >> basicOpen: path writable: aBoolean [
	^ self
		nodeAt: path
		ifPresent: [ :entry | entry ]
		ifAbsent: [ aBoolean
				ifFalse: [ self signalFileDoesNotExist: path ]
				ifTrue: [ self shouldNotImplement ] ]
]

{ #category : #accessing }
GitCliCommitStore >> basicSizeOf: aNode [
	^ aNode size
]

{ #category : #accessing }
GitCliCommitStore >> binaryReadStreamOn: aGtGitFileHandle [
	^ self gitFileReader readStreamFor: aGtGitFileHandle entry id
]

{ #category : #'instance creation' }
GitCliCommitStore >> commit: aCommit [
	commit := aCommit
]

{ #category : #accessing }
GitCliCommitStore >> delimiter [
	^ $/
]

{ #category : #accessing }
GitCliCommitStore >> entries [
	| entryList lines |
	entries ifNotNil: [ ^ entries ].
	entries := Dictionary new.
	lines := commit repository runGitWithArgs: {
		'ls-tree'.
		'-rt'.
		'--format=%(objectmode) %(objecttype) %(objectname) %(objectsize)%x09%(path)'.
		self treeIdFromCommit }.
	entryList := lines collect: [ :each | GitCliFileEntry fromLine: each ].
	entryList do: [ :each | entries at: (self basenameFromEntry: each) put: each ].
	^ entries
]

{ #category : #accessing }
GitCliCommitStore >> entryByPath: aString ifAbsent: aBlock [
	^ self entries at: aString ifAbsent: aBlock
]

{ #category : #accessing }
GitCliCommitStore >> entryFromNode: node path: path for: aFileSystem [
	^ aFileSystem referenceTo: path / node path
]

{ #category : #finalization }
GitCliCommitStore >> finalize [
	gitFileReader
		ifNotNil: [ gitFileReader terminate.
			gitFileReader := nil ].
	super finalize
]

{ #category : #printing }
GitCliCommitStore >> forReferencePrintOn: aStream [
	aStream nextPutAll: 'git://'
]

{ #category : #accessing }
GitCliCommitStore >> gitFileReader [
	^ gitFileReader
		ifNil: [ self class register: self.
			gitFileReader := GitCliCommitFileReader new repository: commit repository ]
]

{ #category : #accessing }
GitCliCommitStore >> handleClass [
	^ GitCliFileHandle
]

{ #category : #accessing }
GitCliCommitStore >> isCaseSensitive [
	^true
]

{ #category : #accessing }
GitCliCommitStore >> nodeAt: anAbsolutePath ifPresent: aPresentBlock ifAbsent: anAbsentBlock [
	anAbsolutePath isRoot 
		ifTrue: [ ^ aPresentBlock value: self rootEntry ].
	^ aPresentBlock
		value: (self
				entryByPath: (anAbsolutePath relativeTo: Path root) pathString
				ifAbsent: [ ^ anAbsentBlock value ])
]

{ #category : #accessing }
GitCliCommitStore >> rootEntry [
	^ GitCliFileEntry new
		mode: '040000';
		type: 'tree';
		id: self treeIdFromCommit;
		size: 0;
		path: '.';
		yourself
]

{ #category : #accessing }
GitCliCommitStore >> treeIdFromCommit [
	^ (commit repository runGitWithArgs: {
		'show'.
		'-s'.
		'--format=format:%T'.
		commit id }) first
]
