"
I support the implementation of a file system on a specific git commit.

I can use an LRU cache to speed up recurring operations.
"
Class {
	#name : #PureGitCommitFileSystemStore,
	#superclass : #FileSystemStore,
	#instVars : [
		'commit',
		'cache'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitCommitFileSystemStore >> accessTimeOf: aPath [
	^ commit timestamp asDateAndTime
]

{ #category : #private }
PureGitCommitFileSystemStore >> basenameFromEntry: aNode [
	^ aNode name
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicCreationTimeOf: aNode [
	^ commit timestamp asDateAndTime
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicEntry: aDirectoryEntry path: aPath nodesDo: aBlock [
	aDirectoryEntry entries do: aBlock
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicIsDirectory: aNode [
	^ aNode isTree
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicIsFile: aNode [
	^ aNode isTree not
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicIsWritable: aNode [
	^ false
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicModificationTime: aNode [
	^ commit timestamp asDateAndTime
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicModificationTimeOf: aNode [
	^ commit timestamp asDateAndTime
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicOpen: aPath writable: isWriteable [
	^ self
		nodeAt: aPath
		ifPresent: [ :entry | entry ]
		ifAbsent: [ isWriteable
				ifFalse: [ self signalFileDoesNotExist: aPath ]
				ifTrue: [ self shouldNotImplement ] ]
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicPosixPermissions: aNode [
	^ 8r444
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicSizeOf: aNode [
	^ self resolveBlobSize: aNode
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> binaryReadStreamOn: aFileHandle [
	^ aFileHandle entry contents readStream
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> changeTimeOf: aPath [
	^ commit timestamp asDateAndTime
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> commit [
	^ commit
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> commit: aCommit [
	commit := aCommit
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> delimiter [
	^ $/
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> entryFromNode: aNode path: aPath for: aFileystem [
	^ aFileystem referenceTo: aPath / aNode name
]

{ #category : #printing }
PureGitCommitFileSystemStore >> forReferencePrintOn: aStream [
	aStream nextPutAll: 'git://'
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> gidOf: aPath [
	^ -1
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> handleClass [
	^ PureGitCommitFileSystemHandle
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> inodeOf: aPath [
	^ -1
]

{ #category : #testing }
PureGitCommitFileSystemStore >> isReadable: aPath [
	^ true
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> nodeAt: aPath ifPresent: aPresentBlock ifAbsent: anAbsentBlock [
	| tree entry |
	tree := self resolveCommitTree: self commit.
	^ aPath isRoot
		ifTrue: [ aPresentBlock value: tree ]
		ifFalse: [ 
			entry := self resolveTreeEntry: tree atPath: aPath segments ifAbsent: anAbsentBlock.
			aPresentBlock value: (self resolveTreeEntry: entry) ]
]

{ #category : #printing }
PureGitCommitFileSystemStore >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(; nextPutAll: commit id; nextPut: $)
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> resolveBlobSize: aBlob [
	^ cache
		ifNil: [ aBlob size ]
		ifNotNil: [
			aBlob hasResolvedContents 
				ifTrue: [ aBlob size ]
				ifFalse: [ cache at: aBlob id , '.s' ifAbsentPut: [ aBlob size ] ] ]
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> resolveCommitTree: aCommit [
	^ cache
		ifNil: [ aCommit tree ]
		ifNotNil: [ cache at: aCommit treeId ifAbsentPut: [ aCommit tree ] ]
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> resolveTreeEntry: aTreeEntry [
	^ cache
		ifNil: [ aTreeEntry resolve ]
		ifNotNil: [ cache at: aTreeEntry id ifAbsentPut: [ aTreeEntry resolve ] ]
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> resolveTreeEntry: aTree atPath: path ifAbsent: anAbsentBlock [
	| subTreeEntry subTree |
	^ path size = 1
		ifTrue: [ aTree entryNamed: path first ifAbsent: anAbsentBlock ]
		ifFalse: [
			subTreeEntry := aTree entryNamed: path first ifAbsent: anAbsentBlock.
			subTreeEntry isTree ifFalse: anAbsentBlock.
			subTree := self resolveTreeEntry: subTreeEntry.
			self resolveTreeEntry: subTree atPath: path allButFirst ifAbsent: anAbsentBlock ] 
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> uidOf: aResolvable [
	^ -1
]

{ #category : #public }
PureGitCommitFileSystemStore >> useCache [
	cache := LRUCache new
]
